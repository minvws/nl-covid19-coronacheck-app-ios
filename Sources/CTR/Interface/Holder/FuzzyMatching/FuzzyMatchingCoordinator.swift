/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

protocol FuzzyMatchingFlowDelegate: AnyObject {
	
	func fuzzyMatchingFlowDidFinish()
}

protocol FuzzyMatchingCoordinatorDelegate: AnyObject {
	
	func userWishesToSeeEventDetails()
	
	func userWishesToSeeIdentitiyGroups()
	
	func userWishesMoreInfoAboutWhy()
	
	func userHasFinishedTheFlow()
}

final class FuzzyMatchingCoordinator: Coordinator {
	
	var childCoordinators: [Coordinator] = []
	
	var navigationController: UINavigationController
	
	var factory: FuzzyMatchingOnboardingFactoryProtocol
	
	private weak var delegate: FuzzyMatchingFlowDelegate?
	
	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - factory: the onboarding content factory
	///   - delegate: the fuzzy matching flow delegate
	init(
		navigationController: UINavigationController,
		factory: FuzzyMatchingOnboardingFactoryProtocol,
		delegate: FuzzyMatchingFlowDelegate) {
		
		self.navigationController = navigationController
		self.factory = factory
		self.delegate = delegate
	}
	
	/// Start the scene
	func start() {
		
//		userWishesToSeeOnboarding()
		userWishesToSeeIdentitiyGroups()
	}
	
	// MARK: - Universal Link handling
	
	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}

extension FuzzyMatchingCoordinator: FuzzyMatchingCoordinatorDelegate {
	
	func userWishesToSeeOnboarding() {
		
		let viewController = PagedAnnouncementViewController(
			viewModel: PagedAnnouncementViewModel(
				delegate: self,
				pages: factory.pages,
				itemsShouldShowWithFullWidthHeaderImage: true,
				shouldShowWithVWSRibbon: false
			),
			allowsBackButton: true,
			allowsCloseButton: false,
			allowsNextButton: true
		)
		
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesToSeeEventDetails() {
		// Todo
	}
	
	func userWishesToSeeIdentitiyGroups() {
		
		let blobIds = [["/EventGroup/p1", "/EventGroup/p3", "/EventGroup/p6"], ["/EventGroup/p2", "/EventGroup/p4"], ["/EventGroup/p5"]]
		
		let viewModel = IdentitySelectionViewModel(coordinatorDelegate: self, nestedBlobIds: blobIds)
		let viewController = IdentitySelectionViewController(viewModel: viewModel)
		
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userHasFinishedTheFlow() {
		
		delegate?.fuzzyMatchingFlowDidFinish()
	}
	
	func userWishesMoreInfoAboutWhy() {
		
		let viewModel = BottomSheetContentViewModel(
			content: Content(
				title: L.holder_fuzzyMatching_why_title(),
				body: L.holder_fuzzyMatching_why_body()
			)
		)
		
		let viewController = BottomSheetContentViewController(viewModel: viewModel)
		presentAsBottomSheet(viewController)
	}
}

extension FuzzyMatchingCoordinator: PagedAnnouncementDelegate {
	
	func didFinishPagedAnnouncement() {
		
		// Onboarding is done. Continue with the identity groups overview
		userWishesToSeeIdentitiyGroups()
	}
}
