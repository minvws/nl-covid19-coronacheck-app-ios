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
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> SecurityChecker {

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
		if networkConfiguration.name == "Development" {
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

			print("Setting up Security Checker for \(provider.name)")
		}

		return SecurityChecker(
			trustedCertificates: trustedCertificates,
			trustedNames: trustedNames,
			challenge: challenge,
			completionHandler: completionHandler
		)

//
//		switch strategy {
//			case .config, .data:
//				return SecurityChecker(
//					trustedCertificates: trustedCertificates,
//					trustedNames: trustedNames,
//					challenge: challenge,
//					completionHandler: completionHandler
//				)
////			case .provider:
////				return SecurityChecker(
////					trustedCertificates: [
////						TrustConfiguration.sdNRootCAG3,
////						TrustConfiguration.sdNPrivateRoot,
////						TrustConfiguration.sdNEVRootCA
////					],
////					trustedNames: [],
////					challenge: challenge,
////					completionHandler: completionHandler
////				)
//			default:
//				return SecurityCheckerNone(
//					trustedCertificates: [],
//					trustedNames: [],
//					challenge: challenge,
//					completionHandler: completionHandler
//				)
//		}
	}
}

protocol SecurityCheckerProtocol {

	func check()
}

class SecurityCheckerNone: SecurityChecker {

	override func check() {
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

	 func check() {

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
