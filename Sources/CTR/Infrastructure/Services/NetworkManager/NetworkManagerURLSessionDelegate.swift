/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Security

final class NetworkManagerURLSessionDelegate: NSObject, URLSessionDelegate {

	/// The network configuration
	private let networkConfiguration: NetworkConfiguration

	/// The security strategy, defaults to none.
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
			networkConfiguration: networkConfiguration,
			challenge: challenge,
			completionHandler: completionHandler
		)
		checker?.checkSSL()
	}
}
