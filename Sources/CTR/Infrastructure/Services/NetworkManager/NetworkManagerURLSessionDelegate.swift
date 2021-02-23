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
	case provider // 1.5
}

final class NetworkManagerURLSessionDelegate: NSObject, URLSessionDelegate, Logging {

	let loggingCategory = "NetworkManagerURLSessionDelegate"

	/// The network configuration
	private let networkConfiguration: NetworkConfiguration

	private (set) var securityStrategy: SecurityStrategy = .none

	/// Initialise session delegate with certificate used for SSL pinning
	init(_ configuration: NetworkConfiguration) {

		self.networkConfiguration = configuration
	}

	/// Set the security strategy
	/// - Parameter strategy: the security strategy
	func setSecurityStrategy(_ strategy: SecurityStrategy) {

		securityStrategy = strategy
	}

	func urlSession(
		_ session: URLSession,
		didReceive challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

		guard securityStrategy != .none,
			  challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
			  let serverTrust = challenge.protectionSpace.serverTrust else {

			logDebug("No security strategy")
			completionHandler(.performDefaultHandling, nil)
			return
		}

		let policies = [SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)]
		SecTrustSetPolicies(serverTrust, policies as CFTypeRef)
		let certificateCount = SecTrustGetCertificateCount(serverTrust)

		for index in 0 ..< certificateCount {

			if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, index) {
				logDebug("serverCertificate: \(serverCertificate)")

				let cert = Certificate(certificate: serverCertificate)
				if let commonName = cert.commonName {
					logDebug("commonName: \(commonName)")
				}
//				if let issuer = cert.issuer {
//					logDebug("issuer: \(String(decoding: issuer, as: UTF8.self))")
//				}

				if let serialNumber = cert.serialNumber {
					logDebug("serialNumber: \(serialNumber.base64EncodedString())")
				}
			}
		}

		// all good
		logDebug("Certificate signature is good")
		completionHandler(.useCredential, URLCredential(trust: serverTrust))

		//		guard let localFingerprints = networkConfiguration.sslSignatures(forHost: challenge.protectionSpace.host),
		//			  challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
		//			  let serverTrust = challenge.protectionSpace.serverTrust else {
		//
		//			logDebug("No pinning of certificate")
		//			completionHandler(.performDefaultHandling, nil)
		//			return
		//		}
		//
		//		let policies = [SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)]
		//		SecTrustSetPolicies(serverTrust, policies as CFTypeRef)
		//
		//		let certificateCount = SecTrustGetCertificateCount(serverTrust)
		//
		//		guard
		//			SecTrustEvaluateWithError(serverTrust, nil),
		//			certificateCount > 0,
		//			let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, certificateCount - 1), // get topmost certificate in chain
		//			let fingerprint = Certificate(certificate: serverCertificate).signature else {
		//			logError("Invalid server trust")
		//			completionHandler(.cancelAuthenticationChallenge, nil)
		//			return
		//		}
		//
		//		guard localFingerprints.contains(fingerprint) else {
		//			logError("Certificate signatures don't match")
		//			completionHandler(.cancelAuthenticationChallenge, nil)
		//			return
		//		}
		//
		//		// all good
		//		logDebug("Certificate signature is good")
		//		completionHandler(.useCredential, URLCredential(trust: serverTrust))
	}

	func checkFqdnMatchesCN() {

	}

	func checkDistinguishedNameEndsWith() {

	}

	func checkFqdnEndsWith() {

	}

	func checkSubjectKeyIdentifier() {

	}

	func checkCertificates() {

		


	}
}
