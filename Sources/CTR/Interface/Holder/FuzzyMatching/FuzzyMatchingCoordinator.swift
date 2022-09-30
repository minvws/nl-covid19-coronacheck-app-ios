/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol FuzzyMatchingFlowDelegate: AnyObject {
	
	func fuzzyMatchingFlowDidFinish()
}

protocol FuzzyMatchingCoordinatorDelegate: AnyObject {
	
	func userWishesToSeeEventDetails()
	
	func userWishesToSeeEvents()
	
	func userWishesMoreInfoAboutWhy()
}

final class FuzzyMatchingCoordinator: Coordinator {
	
	var childCoordinators: [Coordinator] = []
	
	var navigationController: UINavigationController
	
	private weak var delegate: FuzzyMatchingFlowDelegate?
	
	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - delegate: the fuzzy matching flow delegate
	init(
		navigationController: UINavigationController,
		delegate: FuzzyMatchingFlowDelegate) {
			
			self.navigationController = navigationController
			self.delegate = delegate
		}
	
	/// Start the scene
	func start() {
		
		userWishesToSeeOnboarding()
	}
	
	// MARK: - Universal Link handling
	
	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}

extension FuzzyMatchingCoordinator: FuzzyMatchingCoordinatorDelegate {
	
	func userWishesToSeeOnboarding() {
		// Todo
	}
	
	func userWishesToSeeEventDetails() {
		// Todo
	}
	
	func userWishesToSeeEvents() {
		// Todo
	}
	
	func userWishesMoreInfoAboutWhy() {
		// Todo
	}
}
