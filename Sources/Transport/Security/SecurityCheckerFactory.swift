/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Security
import Shared

struct SecurityCheckerFactory {
	
	static func getSecurityChecker(
		_ strategy: SecurityStrategy,
		challenge: URLAuthenticationChallenge?,
		remoteConfig: RemoteConfiguration,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> SecurityCheckerProtocol {
			
#if DEBUG
		if case SecurityStrategy.none = strategy {
			return SecurityCheckerNone(
				challenge: challenge,
				completionHandler: completionHandler
			)
		}
#endif
		// Default for .config
		var trustedName: String? = TrustConfiguration.commonNameContent
		var trustedCertificates = [Data]()
		
		if case SecurityStrategy.data = strategy {
			trustedCertificates = []
			for tlsCertificate in remoteConfig.getTLSCertificates() {
				trustedCertificates.append(tlsCertificate)
			}
		}
		
		if case let .provider(provider) = strategy {
			trustedName = nil // No trusted name check.
			trustedCertificates = [] // Only trust provided certificates
			for tlsCertificate in provider.getTLSCertificates() {
				trustedCertificates.append(tlsCertificate)
			}
		}
		return SecurityChecker(
			trustedCertificates: trustedCertificates,
			trustedName: trustedName,
			challenge: challenge,
			completionHandler: completionHandler
		)
	}
}

protocol SecurityCheckerProtocol {
	
	/// Check the SSL Connection
	func checkSSL()
}

#if DEBUG
/// Check nothing. Allow every connection. Used for testing.
class SecurityCheckerNone: SecurityChecker {
	
	/// Check the SSL Connection
	override func checkSSL() {
		
		completionHandler(.performDefaultHandling, nil)
	}
}
#endif

/// Security check for backend communication
class SecurityChecker: SecurityCheckerProtocol {
	
	var trustedCertificates: [Data]
	var challenge: URLAuthenticationChallenge?
	var completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	var trustedName: String?
	var worker = SecurityCheckerWorker()
	
	init(
		trustedCertificates: [Data] = [],
		trustedName: String? = nil,
		challenge: URLAuthenticationChallenge?,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
			
			self.trustedCertificates = trustedCertificates
			self.trustedName = trustedName
			self.challenge = challenge
			self.completionHandler = completionHandler
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
		
		if worker.checkSSL(
			serverTrust: serverTrust,
			policies: policies,
			trustedCertificates: trustedCertificates,
			hostname: host,
			trustedName: trustedName) {
			completionHandler(.useCredential, URLCredential(trust: serverTrust))
			return
		}
		logWarning("SecurityChecker: cancelAuthenticationChallenge")
		completionHandler(.cancelAuthenticationChallenge, nil)
		return
	}
}
