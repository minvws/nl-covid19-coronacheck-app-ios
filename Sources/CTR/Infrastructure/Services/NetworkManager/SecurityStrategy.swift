/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Security

/// The security strategy
enum SecurityStrategy: Equatable {

	case none
	case config // 1.3
	case data // 1.4
	case provider(TestProvider) // 1.5
}

struct SecurityCheckerFactory {

	static func getSecurityChecker(
		_ strategy: SecurityStrategy,
		networkConfiguration: NetworkConfiguration,
		challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> SecurityCheckerProtocol {

		guard strategy != .none else {
			return SecurityCheckerNone(
				trustedCertificates: [],
				trustedNames: [],
				challenge: challenge,
				completionHandler: completionHandler
			)
		}
		var trustedNames = [TrustConfiguration.commonNameContent]
		var trustedCertificates = [TrustConfiguration.sdNEVRootCA]
		if networkConfiguration.name == "Development" || networkConfiguration.name == "Test" {
			trustedNames.append(TrustConfiguration.testNameContent)
			trustedCertificates.append(TrustConfiguration.dstRootCAX3)
		}

		if strategy == .data {
			trustedCertificates.append(TrustConfiguration.sdNRootCAG3)
			trustedCertificates.append(TrustConfiguration.sdNPrivateRoot)
		}

		if case let .provider(provider) = strategy {

			if let host = provider.resultURL?.host {
				trustedNames = [host]
			}
			if let certData = provider.getCertificateData() {
				trustedCertificates.append(certData)
			}
			trustedCertificates.append(TrustConfiguration.sdNRootCAG3)
			trustedCertificates.append(TrustConfiguration.sdNPrivateRoot)

			return SecurityCheckerProvider(
				trustedCertificates: trustedCertificates,
				trustedNames: trustedNames,
				challenge: challenge,
				completionHandler: completionHandler
			)
		}

		return SecurityChecker(
			trustedCertificates: trustedCertificates,
			trustedNames: trustedNames,
			challenge: challenge,
			completionHandler: completionHandler
		)
	}
}

protocol SecurityCheckerProtocol {

	func checkSSL()
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
}

class SecurityCheckerNone: SecurityChecker {

	override func checkSSL() {
		
		completionHandler(.performDefaultHandling, nil)
	}
}

class SecurityChecker: SecurityCheckerProtocol, Logging {

	var loggingCategory: String = "SecurityCheckerConfig"

	var trustedCertificates: [Data]
	var challenge: URLAuthenticationChallenge
	var completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	var trustedNames: [String]
	var openssl = OpenSSL()

	init(
		trustedCertificates: [Data],
		trustedNames: [String],
		challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

		self.trustedCertificates = trustedCertificates
		self.trustedNames = trustedNames
		self.challenge = challenge
		self.completionHandler = completionHandler
	}

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
						logDebug("Host matched CN \(name)")
					}
					for trustedName in trustedNames {
						if name.lowercased().hasSuffix(trustedName.lowercased()) {
							foundValidCommonNameEndsWithTrustedName = true
							logDebug("Found a valid name \(name)")
						}
					}
				}
				if let san = openssl.getSubjectAlternativeName(serverCert.data), !foundValidFullyQualifiedDomainName {
					if compareSan(san, name: challenge.protectionSpace.host.lowercased()) {
						foundValidFullyQualifiedDomainName = true
						logDebug("Host matched SAN \(san)")
					}
				}
				for trustedCertificate in trustedCertificates {

					if openssl.compare(serverCert.data, withTrustedCertificate: trustedCertificate) {
						logDebug("Found a match with a trusted Certificate")
						foundValidCertificate = true
					}
				}
			}
		}

		if foundValidCertificate && foundValidCommonNameEndsWithTrustedName && foundValidFullyQualifiedDomainName {
			// all good
			logDebug("Certificate signature is good for \(challenge.protectionSpace.host)")
			completionHandler(.useCredential, URLCredential(trust: serverTrust))
		} else {
 			logError("Invalid server trust")
			completionHandler(.cancelAuthenticationChallenge, nil)
		}
	}
}

class SecurityCheckerProvider: SecurityChecker {

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
						logDebug("Host matched CN \(name)")
					}
				}
				if let san = openssl.getSubjectAlternativeName(serverCert.data), !foundValidFullyQualifiedDomainName {
					if compareSan(san, name: challenge.protectionSpace.host.lowercased()) {
						foundValidFullyQualifiedDomainName = true
						logDebug("Host matched SAN \(san)")
					}
				}
				for trustedCertificate in trustedCertificates {

					if openssl.compare(serverCert.data, withTrustedCertificate: trustedCertificate) {
						logDebug("Found a match with a trusted Certificate")
						foundValidCertificate = true
					}
				}
			}
		}

		if foundValidCertificate && foundValidFullyQualifiedDomainName {
			// all good
			logDebug("Certificate signature is good for \(challenge.protectionSpace.host)")
			completionHandler(.useCredential, URLCredential(trust: serverTrust))
		} else {
			logError("Invalid server trust")
			completionHandler(.cancelAuthenticationChallenge, nil)
		}
	}
}
