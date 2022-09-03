/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Security

final class NetworkManagerURLSessionDelegate: NSObject, URLSessionDelegate {

	/// The security strategy
	private (set) var securityStrategy: SecurityStrategy
	private (set) var remoteConfig: () -> RemoteConfiguration
	
	/// Initialise session delegate with certificate used for SSL pinning
	init(strategy: SecurityStrategy, remoteConfig: @escaping () -> RemoteConfiguration) {

		self.securityStrategy = strategy
		self.remoteConfig = remoteConfig
	}

	/// The security checker (certificate ssl check, PKSC7 signature check)
	var checker: SecurityCheckerProtocol?

	/// URLSessionDelegate method
	/// - Parameters:
	///   - session: the current url session
	///   - challenge: the authentication challenge
	///   - completionHandler: completion handler
	func urlSession(
		_ session: URLSession,
		didReceive challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

		checker = SecurityCheckerFactory.getSecurityChecker(
			securityStrategy,
			challenge: challenge,
			remoteConfig: remoteConfig(),
			completionHandler: completionHandler
		)
		checker?.checkSSL()
	}
	
	/// Clean up strong reference to the security checker. `URLSession` can then be deinitialized
	func cleanup() {
		
		checker = nil
	}
}
