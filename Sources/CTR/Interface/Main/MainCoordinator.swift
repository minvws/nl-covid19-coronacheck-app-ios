/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

class MainCoordinator: Coordinator {

	private let window: UIWindow

	/// For use with iOS 13 and higher
	@available(iOS 13.0, *)
	init(scene: UIWindowScene) {
		window = UIWindow(windowScene: scene)
	}

	/// For use with iOS 12.
	override init() {
		self.window = UIWindow(frame: UIScreen.main.bounds)
	}

	override func start() {

		let viewController = ViewController()
		let navigationController = UINavigationController(rootViewController: viewController)

		window.rootViewController = navigationController
		window.makeKeyAndVisible()
	}
}
