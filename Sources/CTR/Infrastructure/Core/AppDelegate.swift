/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import AppAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate, Logging, AppAuthState {

	/// The app coordinator for routing
	var appCoordinator: AppCoordinator?

	// login flow
	var currentAuthorizationFlow: OIDExternalUserAgentSession?

    /// set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		if !ProcessInfo.processInfo.isTesting {
			// Setup Logging
			LogHandler.setup()
		}
			
		styleUI()

		if #available(iOS 13.0, *) {
			// Use Scene lifecycle
		} else {
			appCoordinator = AppCoordinator(navigationController: NavigationController())
			appCoordinator?.start()
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

    /// For handling __Deep Links__ only, - not relevant for Universal Links.
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

		// Incoming url
		logVerbose("CTR: AppDelegate -> url = \(url)")

		// Determine who sent the URL.
		let sendingAppID = options[.sourceApplication]
		logVerbose("CTR: AppDelegate -> source application = \(sendingAppID ?? "Unknown")")

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

    /// Entry point for Universal links in iOS 11/12 only (see SceneDelegate for iOS 13+)
    /// Used for both running and cold-booted apps
    func application(_: UIApplication, continue userActivity: NSUserActivity, restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        // Parse an activity from the userActivity
		guard let universalLink = UniversalLink(userActivity: userActivity, isLunhCheckEnabled: Current.featureFlagManager.isLuhnCheckEnabled()) else { return false }

        return appCoordinator?.receive(universalLink: universalLink) ?? false
    }

	// MARK: Orientation

	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return self.orientationLock
	}

	// MARK: 3rd Party Keyboard

	func application(
		_ application: UIApplication,
		shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {

		// Reject 3rd Party Keyboards.
		return extensionPointIdentifier != .keyboard
	}

    // MARK: - Private

    /// Setup the appearance of the navigation bar
	private func styleUI() {
		
		// Custom navigation bar appearance
		let color = C.black()!
		UINavigationBar.appearance().titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: color,
			NSAttributedString.Key.font: Theme.fonts.bodyMontserratFixed
		]
		UINavigationBar.appearance().tintColor = color
		UINavigationBar.appearance().barTintColor = Theme.colors.viewControllerBackground
		
		// Tint default buttons of UIAlertController
		UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = C.primaryBlue()
		
		if #available(iOS 15.0, *) {
			// By default iOS 15 has no shadow bottom separator
			UINavigationBar.appearance().standardAppearance.titleTextAttributes = [.foregroundColor: color]
			UINavigationBar.appearance().scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: color]
		} else {
			// White navigation bar without bottom separator
			UINavigationBar.appearance().isTranslucent = false
			UINavigationBar.appearance().shadowImage = UIImage()
			UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
		}
	}
}
