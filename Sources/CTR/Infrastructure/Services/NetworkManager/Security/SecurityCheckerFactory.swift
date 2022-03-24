/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Security

struct SecurityCheckerFactory {
	
	static func getSecurityChecker(
		_ strategy: SecurityStrategy,
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
		
		if case SecurityStrategy.data = strategy {
			trustedCertificates = []
			for tlsCertificate in Current.remoteConfigManager.storedConfiguration.getTLSCertificates() {
				trustedCertificates.append(tlsCertificate)
			}
		}
		
		if case let .provider(provider) = strategy {
			trustedNames = [] // No trusted name check.
			trustedCertificates = [] // Only trust provided certificates
			for tlsCertificate in provider.getTLSCertificates() {
				trustedCertificates.append(tlsCertificate)
			}
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
	
	/// Check the SSL Connection
	func checkSSL()
}

/// Check nothing. Allow every connection. Used for testing.
class SecurityCheckerNone: SecurityChecker {
	
	/// Check the SSL Connection
	override func checkSSL() {
		
		completionHandler(.performDefaultHandling, nil)
	}
}

/// Security check for backend communication
class SecurityChecker: SecurityCheckerProtocol, Logging {
	
	var trustedCertificates: [Data]
	var challenge: URLAuthenticationChallenge?
	var completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	var trustedNames: [String]
	var openssl = OpenSSL()
	
	init(
		trustedCertificates: [Data] = [],
		trustedNames: [String] = [],
		challenge: URLAuthenticationChallenge?,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
			
			self.trustedCertificates = trustedCertificates
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
}
