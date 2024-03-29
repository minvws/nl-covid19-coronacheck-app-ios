/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	/// The app coordinator for routing
	var appCoordinator: AppCoordinator?
	
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
			
		styleUI()
		
		if #unavailable(iOS 13.0) {
			self.appCoordinator = AppCoordinator(navigationController: NavigationController())
			self.appCoordinator?.start()
		}
		return true
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
	
	// MARK: - Open URL
	
	/// For handling __Deep Links__ only, - not relevant for Universal Links.
	func application(
		_ app: UIApplication,
		open url: URL,
		options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
			
		return false
	}
	
	// MARK: - Private
	
	/// Setup the appearance of the navigation bar
	private func styleUI() {
		
		// Custom navigation bar appearance
		let color = C.black()!
		let titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: color,
			NSAttributedString.Key.font: Fonts.bodyMontserratFixed
		]
		
		UINavigationBar.appearance().titleTextAttributes = titleTextAttributes
		UINavigationBar.appearance().tintColor = color
		UINavigationBar.appearance().barTintColor = C.white()
		
		// Tint default buttons of UIAlertController
		UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = C.primaryBlue()
		
		if #available(iOS 15.0, *) {
			// By default iOS 15 has no shadow bottom separator
			UINavigationBar.appearance().standardAppearance.titleTextAttributes = titleTextAttributes
			UINavigationBar.appearance().scrollEdgeAppearance?.titleTextAttributes = titleTextAttributes
		} else {
			// White navigation bar without bottom separator
			UINavigationBar.appearance().isTranslucent = false
			UINavigationBar.appearance().shadowImage = UIImage()
			UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
		}
	}
}
