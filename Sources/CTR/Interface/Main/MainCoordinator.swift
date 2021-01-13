//
//  MainCoordinator.swift
//  CTR
//
//  Created by Rool Paap on 13/01/2021.
//

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
