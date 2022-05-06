/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import AppAuth

protocol OpenIdManaging: AnyObject {
	
	/// Request an access token
	/// - Parameters:
	///   - onCompletion: completion handler with optional access token
	///   - onError: error handler
	func requestAccessToken(
		onCompletion: @escaping (TVSAuthorizationToken) -> Void,
		onError: @escaping (Error?) -> Void)
}

class OpenIdManager: OpenIdManaging, Logging {
	
	let loggingCategory: String = "OpenIdClient"
	
	/// The digid configuration
	var configuration: ConfigurationDigidProtocol
	
	var isAuthorizationInProgress: Bool = false
	
	required init() {
		configuration = Configuration()
	}
	
	/// Initializer
	/// - Parameter configuration: the digid configuration
	init(configuration: ConfigurationDigidProtocol) {
		
		self.configuration = configuration
	}
	
	/// Request an access token
	/// - Parameters:
	///   - onCompletion: completion handler with optional access token
	///   - onError: error handler
	func requestAccessToken(
		onCompletion: @escaping (TVSAuthorizationToken) -> Void,
		onError: @escaping (Error?) -> Void) {
			
			discoverServiceConfiguration { [weak self] result in
				switch result {
					case let .success(serviceConfiguration):
						self?.requestAuthorization(
							serviceConfiguration,
							onCompletion: onCompletion,
							onError: onError
						)
						
					case let .failure(error):
						onError(error)
				}
			}
		}
	
	private func requestAuthorization(
		_ serviceConfiguration: OIDServiceConfiguration,
		onCompletion: @escaping (TVSAuthorizationToken) -> Void,
		onError: @escaping (Error?) -> Void) {
			
			isAuthorizationInProgress = true
			
			let request = generateRequest(serviceConfiguration: serviceConfiguration)
			self.logVerbose("OpenIdManager: authorization request: \(request)")
			
			if let appAuthState = UIApplication.shared.delegate as? AppAuthState {
				
				if #unavailable(iOS 13) {
					NotificationCenter.default.post(name: .disablePrivacySnapShot, object: nil)
				}
				
				let callBack: OIDAuthStateAuthorizationCallback = { authState, error in
					
					self.logVerbose("OpenIdManager: authState: \(String(describing: authState))")
					NotificationCenter.default.post(name: .enablePrivacySnapShot, object: nil)
					DispatchQueue.main.async {
						
						if let lastTokenResponse = authState?.lastTokenResponse,
						   let idTokenString = lastTokenResponse.idToken,
						   let idToken = OIDIDToken(idTokenString: idTokenString) {
							
							self.logVerbose("OpenIdManager: We got the idToken")
							
							onCompletion(TVSAuthorizationToken(
								idTokenString: idTokenString,
								expiration: idToken.expiresAt
							))
						} else {
							self.logError("OpenIdManager: \(String(describing: error))")
							onError(error)
						}
					}
				}
				
				appAuthState.currentAuthorizationFlow = OIDAuthState.authState(
					byPresenting: request,
					externalUserAgent: OIDExternalUserAgentIOSCustomBrowser.defaultBrowser() ?? OIDExternalUserAgentIOSCustomBrowser.customBrowserSafari(),
					callback: callBack
				)
			}
		}
	
	/// Discover the configuration file for the open ID connection
	/// - Parameter onCompletion: Service Configuration or error
	private func discoverServiceConfiguration(_ onCompletion: @escaping (Result<OIDServiceConfiguration, Error>) -> Void) {
		
		let issuer = configuration.getTVSURL()
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
	/// - Parameter serviceConfiguration: Service Configuration
	/// - Returns: Open Id Authorization Request
	private func generateRequest(serviceConfiguration: OIDServiceConfiguration) -> OIDAuthorizationRequest {
		
		// builds authentication request
		let request = OIDAuthorizationRequest(
			configuration: serviceConfiguration,
			clientId: configuration.getConsumerId(),
			scopes: [OIDScopeOpenID],
			redirectURL: configuration.getRedirectUri(),
			responseType: OIDResponseTypeCode,
			additionalParameters: nil
		)
		return request
	}
}
