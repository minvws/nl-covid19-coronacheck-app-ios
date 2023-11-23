/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckUI
import OpenIDConnect

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	/// The app coordinator for routing
	var appCoordinator: AppCoordinator?
	
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
		
		self.appCoordinator = AppCoordinator(scene: windowScene, navigationController: NavigationController())
		self.appCoordinator?.start()
	}
}
