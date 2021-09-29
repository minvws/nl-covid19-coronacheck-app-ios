/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Security

protocol CertificateProvider {

	func getHostNames() -> [String]

	func getSSLCertificate() -> Data?

	func getSigningCertificate() -> SigningCertificate?
}

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
		challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> SecurityCheckerProtocol {

		if case SecurityStrategy.none = strategy {
			return SecurityCheckerNone(
				checkForAuthorityKeyIdentifierAndNameAndSuffix: false,
				challenge: challenge,
				completionHandler: completionHandler
			)
		}
		var trustedNames = [TrustConfiguration.commonNameContent]
		var trustedCertificates = [TrustConfiguration.sdNEVRootCA]
		var trustedSigners = [TrustConfiguration.sdNEVRootCACertificate]
		var checkForAuthorityKeyIdentifierAndNameAndSuffix = true

		if case SecurityStrategy.data = strategy {
			trustedCertificates.append(TrustConfiguration.sdNRootCAG3)
			trustedCertificates.append(TrustConfiguration.sdNPrivateRoot)
		}

		if case let .provider(provider) = strategy {

			trustedNames = [] // No trusted name check.
			if let sslCertificate = provider.getSSLCertificate() {
				trustedCertificates.append(sslCertificate)
			}
			trustedCertificates.append(TrustConfiguration.sdNRootCAG3)
			trustedCertificates.append(TrustConfiguration.sdNPrivateRoot)
			trustedSigners.append(TrustConfiguration.sdNRootCAG3Certificate)
			trustedSigners.append(TrustConfiguration.sdNPrivateRootCertificate)
			checkForAuthorityKeyIdentifierAndNameAndSuffix = false
		}

		return SecurityChecker(
			trustedCertificates: trustedCertificates,
			trustedNames: trustedNames,
			trustedSigners: trustedSigners,
			checkForAuthorityKeyIdentifierAndNameAndSuffix: checkForAuthorityKeyIdentifierAndNameAndSuffix,
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

	var loggingCategory: String = "SecurityCheckerConfig"

	var trustedCertificates: [Data]
	var challenge: URLAuthenticationChallenge
	var completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	var trustedNames: [String]
	var trustedSigners: [SigningCertificate]
	var openssl = OpenSSL()
	var checkForAuthorityKeyIdentifierAndNameAndSuffix: Bool

	init(
		trustedCertificates: [Data] = [],
		trustedNames: [String] = [],
		trustedSigners: [SigningCertificate] = [],
		checkForAuthorityKeyIdentifierAndNameAndSuffix: Bool,
		challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

		self.trustedCertificates = trustedCertificates
		self.trustedSigners = trustedSigners
		self.trustedNames = trustedNames
		self.challenge = challenge
		self.checkForAuthorityKeyIdentifierAndNameAndSuffix = checkForAuthorityKeyIdentifierAndNameAndSuffix
		self.completionHandler = completionHandler
	}

	// Though ATS will validate this (too) - we force an early verification against a known list
	// ahead of time (defined here, no keychain) - also to trust the (relatively loose) comparisons
	// later (as we need to work with this data; which otherwise would be untrusted).
	//
	func checkATS(serverTrust: SecTrust) -> Bool {
		let policies = [SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)]

		return SecurityCheckerWorker().checkATS(
			serverTrust: serverTrust,
			policies: policies,
			trustedCertificates: trustedCertificates)
	}

	/// Check the SSL Connection
	func checkSSL() {

		guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
			  let serverTrust = challenge.protectionSpace.serverTrust else {

			logWarning("SecurityChecker: invalid authenticationMethod")
			completionHandler(.performDefaultHandling, nil)
			return
		}
		let policies = [SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)]

		if SecurityCheckerWorker().checkSSL(
			serverTrust: serverTrust,
			policies: policies,
			trustedCertificates: trustedCertificates,
			hostname: challenge.protectionSpace.host,
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

		//		logDebug("Security Strategy: there are \(trustedSigners.count) trusted signers for \(Unmanaged.passUnretained(self).toOpaque())")

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
				authorityKeyIdentifier: !checkForAuthorityKeyIdentifierAndNameAndSuffix ? nil : signer.authorityKeyIdentifier,
				requiredCommonNameContent: !checkForAuthorityKeyIdentifierAndNameAndSuffix ? "" : signer.commonName ?? "") {
				return true
			}
		}
		return false
	}
}
