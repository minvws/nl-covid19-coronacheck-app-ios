/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import AppAuth

protocol OpenIdManaging: AnyObject {
	
	/// Request an access token
	/// - Parameters:
	///   - configuration: openID configuration
	///   - onCompletion: ompletion handler with optional access token
	///   - onError: error handler
	func requestAccessToken(
		issuerConfiguration: IssuerConfiguration,
		presentingViewController: UIViewController?,
		onCompletion: @escaping (OpenIdManagerToken) -> Void,
		onError: @escaping (Error?) -> Void)
}

protocol IssuerConfiguration: AnyObject {

	/// Get the  url
	/// - Returns: the url
	func getIssuerURL() -> URL

	/// Get the client ID
	/// - Returns: the client ID
	func getClientId() -> String

	/// Get the redirect uri
	/// - Returns: the redirect uri
	func getRedirectUri() -> URL
}

protocol OpenIdManagerToken {
	
	var idToken: String? { get }
	var accessToken: String? { get }
}

extension OIDTokenResponse: OpenIdManagerToken {
	
}

class OpenIdManager: OpenIdManaging {
	
	var isAuthorizationInProgress: Bool = false
	private let logHandler: Logging?
	
	/// Initializer
	/// - Parameter configuration: the digid configuration
	init(logHandler: Logging? = nil) {
		
		self.logHandler = logHandler
	}

	/// Request an access token
	/// - Parameters:
	///   - issuerConfiguration: openID configuration
	///   - onCompletion: ompletion handler with optional access token
	///   - onError: error handler
	func requestAccessToken(
		issuerConfiguration: IssuerConfiguration,
		presentingViewController: UIViewController?,
		onCompletion: @escaping (OpenIdManagerToken) -> Void,
		onError: @escaping (Error?) -> Void) {
			
			discoverServiceConfiguration(issuerConfiguration: issuerConfiguration) { [weak self] result in
				switch result {
					case let .success(serviceConfiguration):
						self?.requestAuthorization(
							issuerConfiguration: issuerConfiguration,
							serviceConfiguration: serviceConfiguration,
							presentingViewController: presentingViewController,
							onCompletion: onCompletion,
							onError: onError
						)
						
					case let .failure(error):
						onError(error)
				}
			}
		}
	
	private func requestAuthorization(
		issuerConfiguration: IssuerConfiguration,
		serviceConfiguration: OIDServiceConfiguration,
		presentingViewController: UIViewController?,
		onCompletion: @escaping (OpenIdManagerToken) -> Void,
		onError: @escaping (Error?) -> Void) {
			
			isAuthorizationInProgress = true
			
			let request = generateRequest(
				issuerConfiguration: issuerConfiguration,
				serviceConfiguration: serviceConfiguration
			)
			
			if let appAuthState = UIApplication.shared.delegate as? AppAuthState {
				
				if #unavailable(iOS 13) {
					NotificationCenter.default.post(name: .disablePrivacySnapShot, object: nil)
				}
				
				let callBack: OIDAuthStateAuthorizationCallback = { authState, error in
					
					NotificationCenter.default.post(name: .enablePrivacySnapShot, object: nil)
					DispatchQueue.main.async {
						
						if let lastTokenResponse = authState?.lastTokenResponse {
							onCompletion(lastTokenResponse)
						} else {
							self.logHandler?.logError("OpenIdManager: \(String(describing: error))")
							onError(error)
						}
					}
				}
				
				if let presentingViewController = presentingViewController {
					appAuthState.currentAuthorizationFlow = OIDAuthState.authState(
						byPresenting: request,
						presenting: presentingViewController,
						callback: callBack
					)
				} else {
					appAuthState.currentAuthorizationFlow = OIDAuthState.authState(
						byPresenting: request,
						externalUserAgent: OIDExternalUserAgentIOSCustomBrowser.defaultBrowser() ?? OIDExternalUserAgentIOSCustomBrowser.customBrowserSafari(),
						callback: callBack
					)
				}
			}
		}
	
	/// Discover the configuration file for the open ID connection
	/// - Parameters:
	///   - issuerConfiguration: The openID configuration
	///   - onCompletion: Service Configuration or error
	private func discoverServiceConfiguration(issuerConfiguration: IssuerConfiguration, onCompletion: @escaping (Result<OIDServiceConfiguration, Error>) -> Void) {
		
		let issuer = issuerConfiguration.getIssuerURL()
		OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { serviceConfiguration, error in
			DispatchQueue.main.async {
				if let service = serviceConfiguration {
					onCompletion(.success(service))
				} else if let error = error {
					onCompletion(.failure(error))
				}
			}
		}
	}
	
	/// Generate an Authorization Request
	/// - Parameter
	///   - issuerConfiguration: The openID configuration
	///   - serviceConfiguration: Service Configuration
	/// - Returns: Open Id Authorization Request
	private func generateRequest(issuerConfiguration: IssuerConfiguration, serviceConfiguration: OIDServiceConfiguration) -> OIDAuthorizationRequest {
		
		// builds authentication request
		let request = OIDAuthorizationRequest(
			configuration: serviceConfiguration,
			clientId: issuerConfiguration.getClientId(),
			scopes: [OIDScopeOpenID],
			redirectURL: issuerConfiguration.getRedirectUri(),
			responseType: OIDResponseTypeCode,
			additionalParameters: nil
		)
		return request
	}
}
