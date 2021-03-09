/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import AppAuth
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	/// The app coordinator for routing
	var appCoordinator: AppCoordinator?

	// login flow
	var currentAuthorizationFlow: OIDExternalUserAgentSession?

	/// The previous brightness
	var previousBrightness: CGFloat?

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		styleUI()
		previousBrightness = UIScreen.main.brightness

		if Configuration().getEnvironment() != "production" , !ProcessInfo.processInfo.isTesting {
			FirebaseApp.configure()
		}

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
		UINavigationBar.appearance().barTintColor = .clear
		UINavigationBar.appearance().titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: Theme.colors.dark,
			NSAttributedString.Key.font: Theme.fonts.bodyMontserrat
		]
		UINavigationBar.appearance().isTranslucent = true
		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
		UINavigationBar.appearance().backgroundColor = .clear

		UINavigationBar.appearance().tintColor = Theme.colors.dark
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

	// MARK: - Open URL

	func application(
		_ app: UIApplication,
		open url: URL,
		options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

		// Incoming url
		print("CTR: AppDelegate -> url = \(url)")

		// Determine who sent the URL.
		let sendingAppID = options[.sourceApplication]
		print("CTR: AppDelegate -> source application = \(sendingAppID ?? "Unknown")")

		// Sends the URL to the current authorization flow (if any) which will
		// process it if it relates to an authorization response.
		if let authorizationFlow = self.currentAuthorizationFlow,
		   authorizationFlow.resumeExternalUserAgentFlow(with: url) {
			self.currentAuthorizationFlow = nil
			return true
		}

		// Your additional URL handling (if any)

		return false
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		if let brightness = previousBrightness {
			UIScreen.main.brightness = brightness
		}
	}

	func applicationWillResignActive(_ application: UIApplication) {
		if let brightness = previousBrightness {
			UIScreen.main.brightness = brightness
		}
	}

	func applicationWillTerminate(_ application: UIApplication) {
		if let brightness = previousBrightness {
			UIScreen.main.brightness = brightness
		}
	}
}
