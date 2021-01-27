/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import AppAuth

protocol OpenIdClientProtocol {

	/// Request an access token
	/// - Parameters:
	///   - presenter: the presenting viewconroller
	///   - onCompletion: completion handler with optional access token
	///   - onError: error handler
	func requestAccessToken(
		presenter: UIViewController,
		onCompletion: @escaping (String?) -> Void,
		onError: @escaping (Error?) -> Void)
}

class OpenIdClient: OpenIdClientProtocol, Logging {

	let loggingCategory: String = "OpenIdClient"

	/// The digid configuration
	var configuration: ConfigurationDigidProtocol

	/// authorization State
	private var authorizationState: OIDAuthState?

	/// Initializer
	/// - Parameter configuration: the digid configuration
	init(configuration: ConfigurationDigidProtocol) {

		self.configuration = configuration
	}

	/// Request an access token
	/// - Parameters:
	///   - presenter: the presenting viewconroller
	///   - onCompletion: completion handler with optional access token
	///   - onError: error handler
	func requestAccessToken(
		presenter: UIViewController,
		onCompletion: @escaping (String?) -> Void,
		onError: @escaping (Error?) -> Void) {

		// Generate the authorization request
		let request = generateRequest()

		// performs authentication request
		self.logInfo("Initiating authorization request with scope: \(request.scope ?? "nil")")

		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {

			// Store the flow
			appDelegate.currentAuthorizationFlow =

				// Request the access token
				OIDAuthState.authState(byPresenting: request, presenting: presenter) { authState, error in
					if let authState = authState {
						self.authorizationState = authState
						self.logDebug("Got access tokens. Access token: " +
								"\(authState.lastTokenResponse?.accessToken ?? "nil")")

						onCompletion(authState.lastTokenResponse?.accessToken)
					} else {
						self.authorizationState = nil
						onError(error)
					}
				}
		}
	}

	/// Generate an Authorization Request
	/// - Returns: Open Id Authorization Request
	private func generateRequest() -> OIDAuthorizationRequest {

		// builds authentication request
		let request = OIDAuthorizationRequest(
			configuration: OIDServiceConfiguration(
				authorizationEndpoint: configuration.getAuthorizationURL(),
				tokenEndpoint: configuration.getTokenURL()
			),
			clientId: configuration.getConsumerId(),
			scopes: [OIDScopeOpenID],
			redirectURL: configuration.getRedirectUri(),
			responseType: OIDResponseTypeCode,
			additionalParameters: nil
		)
		return request
	}
}
