/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	/// The app coordinator for routing
	var appCoordinator: AppCoordinator?

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		styleUI()

		if #available(iOS 13.0, *) {
			// Use Scene lifecycle
		} else {
			appCoordinator = AppCoordinator(navigationController: UINavigationController())
			appCoordinator?.start()
		}

		return true
	}

	/// Setup the apperance of the navigation bar
	func styleUI() {

		// Custom navigation bar appearance
		UINavigationBar.appearance().barTintColor = .white
		UINavigationBar.appearance().titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.darkText
		]
		UINavigationBar.appearance().isTranslucent = false
		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
		UINavigationBar.appearance().backgroundColor = .clear
	}

	// MARK: UISceneSession Lifecycle

	@available(iOS 13.0, *)
	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	@available(iOS 13.0, *)
	func application(
		_ application: UIApplication,
		didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running,
		// this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}

}
