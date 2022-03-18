/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Security

/// The security strategy
enum SecurityStrategy {

	case none
	case config // 1.3
	case data // 1.4
	case provider(CertificateProvider) // 1.5
}

struct SecurityCheckerFactory {

	static func getSecurityChecker(
		_ strategy: SecurityStrategy,
		networkConfiguration: NetworkConfiguration,
		challenge: URLAuthenticationChallenge?,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> SecurityCheckerProtocol {

		if case SecurityStrategy.none = strategy {
			return SecurityCheckerNone(
				challenge: challenge,
				completionHandler: completionHandler
			)
		}
		// Default for .config
		var trustedNames = [TrustConfiguration.commonNameContent]
		var trustedCertificates = [Data]()
		var trustedSigners = [TrustConfiguration.sdNEVRootCACertificate, TrustConfiguration.sdNRootCAG3Certificate, TrustConfiguration.sdNPrivateRootCertificate]

		if case SecurityStrategy.data = strategy {
			trustedCertificates = []
			trustedSigners = []
			for tlsCertificate in Current.remoteConfigManager.storedConfiguration.getTLSCertificates() {
				trustedCertificates.append(tlsCertificate)
			}
		}

		if case let .provider(provider) = strategy {
			trustedNames = [] // No trusted name check.
			trustedCertificates = [] // Only trust provided certificates
			trustedSigners = []
			for tlsCertificate in provider.getTLSCertificates() {
				trustedCertificates.append(tlsCertificate)
			}
			let openSSL = OpenSSL()
			for cmsCertificate in provider.getCMSCertificates() {
				if let commonName = openSSL.getCommonName(forCertificate: cmsCertificate),
				   let authKey = openSSL.getAuthorityKeyIdentifier(forCertificate: cmsCertificate) {
					for trustedCert in [TrustConfiguration.sdNEVRootCACertificate, TrustConfiguration.sdNRootCAG3Certificate, TrustConfiguration.sdNPrivateRootCertificate] {
						var copy = trustedCert
						copy.authorityKeyIdentifier = authKey
						copy.commonName = commonName
						trustedSigners.append(copy)
					}
				}
			}
		}
		return SecurityChecker(
			trustedCertificates: trustedCertificates,
			trustedNames: trustedNames,
			trustedSigners: trustedSigners,
			challenge: challenge,
			completionHandler: completionHandler
		)
	}
}

protocol SecurityCheckerProtocol {

	/// Check the SSL Connection
	func checkSSL()

	/// Validate a PKCS7 signature
	/// - Parameters:
	///   - signature: the signature to validate
	///   - content: the signed content
	/// - Returns: True if the signature is a valid PKCS7 Signature
	func validate(signature: Data, content: Data) -> Bool
}

extension SecurityCheckerProtocol {

	/// Validate a PKCS7 Signature
	/// - Parameters:
	///   - data: the signed content
	///   - signature: the PKCS7 Signature
	///   - completion: Completion handler
	func validate(data: Data, signature: Data, completion: @escaping (Bool) -> Void) {
		DispatchQueue.global().async {
			let result = validate(signature: signature, content: data)

			DispatchQueue.main.async {
				completion(result)
			}
		}
	}
}

/// Check nothing. Allow every connection. Used for testing.
class SecurityCheckerNone: SecurityChecker {

	/// Check the SSL Connection
	override func checkSSL() {

		completionHandler(.performDefaultHandling, nil)
	}

	/// Validate a PKCS7 signature
	/// - Parameters:
	///   - signature: the signature to validate
	///   - content: the signed content
	/// - Returns: True if the signature is a valid PKCS7 Signature
	override func validate(signature: Data, content: Data) -> Bool {

		return true
	}
}

/// Security check for backend communication
class SecurityChecker: SecurityCheckerProtocol, Logging {

	var trustedCertificates: [Data]
	var challenge: URLAuthenticationChallenge?
	var completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	var trustedNames: [String]
	var trustedSigners: [SigningCertificate]
	var openssl = OpenSSL()

	init(
		trustedCertificates: [Data] = [],
		trustedNames: [String] = [],
		trustedSigners: [SigningCertificate] = [],
		challenge: URLAuthenticationChallenge?,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

		self.trustedCertificates = trustedCertificates
		self.trustedSigners = trustedSigners
		self.trustedNames = trustedNames
		self.challenge = challenge
		self.completionHandler = completionHandler
	}

	// Though ATS will validate this (too) - we force an early verification against a known list
	// ahead of time (defined here, no keychain) - also to trust the (relatively loose) comparisons
	// later (as we need to work with this data; which otherwise would be untrusted).
	//
	func checkATS(serverTrust: SecTrust) -> Bool {
		
		guard let host = challenge?.protectionSpace.host else {
			return false
		}
		
		let policies = [SecPolicyCreateSSL(true, host as CFString)]

		return SecurityCheckerWorker().checkATS(
			serverTrust: serverTrust,
			policies: policies,
			trustedCertificates: trustedCertificates)
	}

	/// Check the SSL Connection
	func checkSSL() {

		guard challenge?.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
			  let serverTrust = challenge?.protectionSpace.serverTrust, let host = challenge?.protectionSpace.host else {

			logWarning("SecurityChecker: invalid authenticationMethod")
			completionHandler(.performDefaultHandling, nil)
			return
		}
		let policies = [SecPolicyCreateSSL(true, host as CFString)]

		if SecurityCheckerWorker().checkSSL(
			serverTrust: serverTrust,
			policies: policies,
			trustedCertificates: trustedCertificates,
			hostname: host,
			trustedNames: trustedNames) {
			completionHandler(.useCredential, URLCredential(trust: serverTrust))
			return
		}
		logWarning("SecurityChecker: cancelAuthenticationChallenge")
		completionHandler(.cancelAuthenticationChallenge, nil)
		return
	}

	/// Validate a PKCS7 signature
	/// - Parameters:
	///   - signature: the signature to validate
	///   - content: the signed content
	/// - Returns: True if the signature is a valid PKCS7 Signature
	func validate(signature: Data, content: Data) -> Bool {
  
		for signer in trustedSigners {

			let certificateData = signer.getCertificateData()

			if let subjectKeyIdentifier = signer.subjectKeyIdentifier,
			   !openssl.validateSubjectKeyIdentifier(subjectKeyIdentifier, forCertificateData: certificateData) {
				logError("validateSubjectKeyIdentifier(subjectKeyIdentifier) failed")
				return false
			}

			if let serial = signer.rootSerial,
			   !openssl.validateSerialNumber( serial, forCertificateData: certificateData) {
				logError("validateSerialNumber(serial) is invalid")
				return false
			}

			if openssl.validatePKCS7Signature(
				signature,
				contentData: content,
				certificateData: certificateData,
				authorityKeyIdentifier: signer.authorityKeyIdentifier,
				requiredCommonNameContent: signer.commonName ?? "") {
				return true
			}
		}
		return false
	}
}
