/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable identifier_name

import UIKit

var Current: Environment!

private func setupCurrentEnvironment(completion: @escaping (Result<Environment, Error>) -> Void) {
	
	// Initializing the DataStoreManager is a prerequisite to initializing the Current environment.
	// We need to ensure that the internal setup of DataStoreManager does not fail (e.g. due to a failed DB migration)
	// before we continue booting the application. Otherwise it's non-recoverable.
	
	#if DEBUG
		guard !ProcessInfo().isUnitTesting else { return } // never callback
	#endif
	
	_ = DataStoreManager(.persistent, flavor: .flavor) { result in
		switch result {
			case .success(let dataStoreManager):
				
				// Initialize the global Environment:
				let currentEnvironment = environment(dataStoreManager)
				completion(.success(currentEnvironment))
				
			case .failure(let error):
				completion(.failure(error))
		}
	}
}

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	/// The app coordinator for routing
	var appCoordinator: AppCoordinator?

	/// Used for presenting last-ditch error messages before the app quits:
	var unrecoverableErrorCoordinator: UnrecoverableErrorCoordinator?
	
    /// If your app is __not__ running, the system delivers
    /// the Universal Link to this delegate method after launch:
	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the
		// provided UIWindowScene `scene`. If using a storyboard, the `window` property will automatically be
		// initialized and attached to the scene. This delegate does not imply the connecting scene or session
		// are new (see `application:configurationForConnectingSceneSession` instead).
		guard let windowScene = (scene as? UIWindowScene) else { return }
		guard !ProcessInfo().isUnitTesting else { return }
		
		setupCurrentEnvironment { (result: Result<Environment, Error>) in
			switch result {
				case let .success(environment):

					// https://www.pointfree.co/episodes/ep16-dependency-injection-made-easy
					Current = environment

					self.appCoordinator = AppCoordinator(scene: windowScene, navigationController: NavigationController())
					self.appCoordinator?.start()
					
					// Possibly we launched via a Universal Link. If so, pass it to the AppCoordinator:
					if let userActivity = connectionOptions.userActivities.first,
					   let activity = UniversalLink(userActivity: userActivity, isLunhCheckEnabled: environment.featureFlagManager.isLuhnCheckEnabled()) {
						self.appCoordinator?.receive(universalLink: activity)
					}
					
				case let .failure(error):
			}
		}
	}

    /// If your app was __already running__ (or suspended in memory), this delegate
    /// callback will receive the UserActivity when a universal link is tapped:
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let activity = UniversalLink(userActivity: userActivity, isLunhCheckEnabled: Current.featureFlagManager.isLuhnCheckEnabled()) else { return }
        appCoordinator?.receive(universalLink: activity)
    }

	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {

		if let url = URLContexts.first?.url,
		   let appAuthState = UIApplication.shared.delegate as? AppAuthState,
		   let authorizationFlow = appAuthState.currentAuthorizationFlow,
		   authorizationFlow.resumeExternalUserAgentFlow(with: url) {
			appAuthState.currentAuthorizationFlow = nil
		}
	}

	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded
		// (see `application:didDiscardSceneSessions` instead).
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
	}

	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}
}
