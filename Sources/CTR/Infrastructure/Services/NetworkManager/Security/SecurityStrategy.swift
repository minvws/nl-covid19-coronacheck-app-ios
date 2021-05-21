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
				challenge: challenge,
				completionHandler: completionHandler
			)
		}
		var trustedNames = [TrustConfiguration.commonNameContent]
		var trustedCertificates = [TrustConfiguration.sdNEVRootCA]
		var trustedSigners = [TrustConfiguration.sdNEVRootCACertificate]
		if networkConfiguration.name == "Development" || networkConfiguration.name == "Test" {
			trustedNames.append(TrustConfiguration.testNameContent)
			trustedCertificates.append(TrustConfiguration.dstRootISRGX1)
		}

		if case SecurityStrategy.data = strategy {
			trustedCertificates.append(TrustConfiguration.sdNRootCAG3)
			trustedCertificates.append(TrustConfiguration.sdNPrivateRoot)
		}

		if case let .provider(provider) = strategy {

			trustedNames.append(contentsOf: provider.getHostNames())
			if let signingCertificate = provider.getSigningCertificate() {
				trustedSigners.append(signingCertificate)
			}
			if let sslCertificate = provider.getSSLCertificate() {
				trustedCertificates.append(sslCertificate)
			}
			trustedCertificates.append(TrustConfiguration.sdNRootCAG3)
			trustedCertificates.append(TrustConfiguration.sdNPrivateRoot)
			trustedSigners.append(TrustConfiguration.sdNRootCAG3Certificate)
			trustedSigners.append(TrustConfiguration.sdNPrivateRootCertificate)
			if networkConfiguration.name != "Production" {
				trustedSigners.append(TrustConfiguration.zorgCspPrivateRootCertificate)
			}

			return SecurityCheckerProvider(
				trustedCertificates: trustedCertificates,
				trustedNames: trustedNames,
				trustedSigners: trustedSigners,
				challenge: challenge,
				completionHandler: completionHandler
			)
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

protocol SecurityCheckerProtocol: SignatureValidating {

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

	/// Compare the Subject Alternative Name
	/// - Parameters:
	///   - san: the subject alternative name
	///   - name: the name to compare
	/// - Returns: True if the san matches
	func compareSan(_ san: String, name: String) -> Bool {

		let sanNames = san.split(separator: ",")
		for sanName in sanNames {
			// SanName can be like DNS: *.domain.nl
			let pattern = String(sanName)
				.replacingOccurrences(of: "DNS:", with: "", options: .caseInsensitive)
				.trimmingCharacters(in: .whitespacesAndNewlines)
			if wildcardMatch(name, pattern: pattern) {
				return true
			}
		}
		return false
	}

	/// Wildcard matching
	/// - Parameters:
	///   - string: the string to check
	///   - pattern: the pattern to match
	/// - Returns: True if the string matches the pattern
	func wildcardMatch(_ string: String, pattern: String) -> Bool {

		let pred = NSPredicate(format: "self LIKE %@", pattern)
		return !NSArray(object: string).filtered(using: pred).isEmpty
	}

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

	init(
		trustedCertificates: [Data] = [],
		trustedNames: [String] = [],
		trustedSigners: [SigningCertificate] = [],
		challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

		self.trustedCertificates = trustedCertificates
		self.trustedSigners = trustedSigners
		self.trustedNames = trustedNames
		self.challenge = challenge
		self.completionHandler = completionHandler
	}

	/// Check the SSL Connection
	 func checkSSL() {

		guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
			  let serverTrust = challenge.protectionSpace.serverTrust else {

			logDebug("No security strategy")
			completionHandler(.performDefaultHandling, nil)
			return
		}

		let policies = [SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)]
		SecTrustSetPolicies(serverTrust, policies as CFTypeRef)
		let certificateCount = SecTrustGetCertificateCount(serverTrust)

		var foundValidCertificate = false
		var foundValidCommonNameEndsWithTrustedName = false
		var foundValidFullyQualifiedDomainName = false

		for index in 0 ..< certificateCount {

			if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, index) {
				let serverCert = Certificate(certificate: serverCertificate)

				if let name = serverCert.commonName {
					if name.lowercased() == challenge.protectionSpace.host.lowercased() {
						foundValidFullyQualifiedDomainName = true
						logVerbose("Host matched CN \(name)")
					}
					for trustedName in trustedNames {
						if name.lowercased().hasSuffix(trustedName.lowercased()) {
							foundValidCommonNameEndsWithTrustedName = true
							logVerbose("Found a valid name \(name)")
						}
					}
				}
				if let san = openssl.getSubjectAlternativeName(serverCert.data), !foundValidFullyQualifiedDomainName {
					if compareSan(san, name: challenge.protectionSpace.host.lowercased()) {
						foundValidFullyQualifiedDomainName = true
						logVerbose("Host matched SAN \(san)")
					}
				}
				for trustedCertificate in trustedCertificates {

					if openssl.compare(serverCert.data, withTrustedCertificate: trustedCertificate) {
						logVerbose("Found a match with a trusted Certificate")
						foundValidCertificate = true
					}
				}
			}
		}

		if foundValidCertificate && foundValidCommonNameEndsWithTrustedName && foundValidFullyQualifiedDomainName {
			// all good
			logVerbose("Certificate signature is good for \(challenge.protectionSpace.host)")
			completionHandler(.useCredential, URLCredential(trust: serverTrust))
		} else {
 			logError("Invalid server trust")
			completionHandler(.cancelAuthenticationChallenge, nil)
		}
	}

	/// Validate a PKCS7 signature
	/// - Parameters:
	///   - signature: the signature to validate
	///   - content: the signed content
	/// - Returns: True if the signature is a valid PKCS7 Signature
	func validate(signature: Data, content: Data) -> Bool {

		for signer in trustedSigners {
			if openssl.validatePKCS7Signature(
				signature,
				contentData: content,
				certificateData: signer.getCertificateData()) {
				return true
			}
		}
		return false
	}
}

/// TestProvider security. Allows more certificates than allowed for backend stuff
class SecurityCheckerProvider: SecurityChecker {

	/// Check the SSL Connection
	override func checkSSL() {

		guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
			  let serverTrust = challenge.protectionSpace.serverTrust else {

			logDebug("No security strategy")
			completionHandler(.performDefaultHandling, nil)
			return
		}

		let policies = [SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)]
		SecTrustSetPolicies(serverTrust, policies as CFTypeRef)
		let certificateCount = SecTrustGetCertificateCount(serverTrust)

		var foundValidCertificate = false
		var foundValidFullyQualifiedDomainName = false

		for index in 0 ..< certificateCount {

			if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, index) {
				let serverCert = Certificate(certificate: serverCertificate)

				if let name = serverCert.commonName, !foundValidFullyQualifiedDomainName {
					if name.lowercased() == challenge.protectionSpace.host.lowercased() {
						foundValidFullyQualifiedDomainName = true
						logVerbose("Host matched CN \(name)")
					}
				}
				if let san = openssl.getSubjectAlternativeName(serverCert.data), !foundValidFullyQualifiedDomainName {
					if compareSan(san, name: challenge.protectionSpace.host.lowercased()) {
						foundValidFullyQualifiedDomainName = true
						logVerbose("Host matched SAN \(san)")
					}
				}
				for trustedCertificate in trustedCertificates {

					if openssl.compare(serverCert.data, withTrustedCertificate: trustedCertificate) {
						logVerbose("Found a match with a trusted Certificate")
						foundValidCertificate = true
					}
				}
			}
		}

		if foundValidCertificate && foundValidFullyQualifiedDomainName {
			// all good
			logVerbose("Certificate signature is good for \(challenge.protectionSpace.host)")
			completionHandler(.useCredential, URLCredential(trust: serverTrust))
		} else {
			logError("Invalid server trust")
			completionHandler(.cancelAuthenticationChallenge, nil)
		}
	}
}
