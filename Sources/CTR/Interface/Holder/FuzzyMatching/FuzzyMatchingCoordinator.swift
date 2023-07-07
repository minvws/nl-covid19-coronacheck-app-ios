/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckUI

protocol FuzzyMatchingFlowDelegate: AnyObject {
	
	func fuzzyMatchingFlowDidStop()

	func fuzzyMatchingFlowDidFinish()
	
	func fuzzyMatchingUserBackedOutOfFlow()
}

protocol FuzzyMatchingCoordinatorDelegate: AnyObject {
		
	func userHasSelectedIdentityGroup(selectedBlobIds: [String])

	func userHasFinishedTheFlow()

	func userHasStoppedTheFlow()
	
	func userWishesMoreInfoAboutWhy()

	func userWishesToSeeIdentityGroups()
	
	func userWishesToSeeIdentitySelectionDetails(_ identitySelectionDetails: IdentitySelectionDetails)
	
	func userWishesToSeeSuccess(name: String)
	
	func presentError(content: Content, backAction: (() -> Void)?)
	
	func restartFlow(matchingBlobIds: [[String]])
}

final class FuzzyMatchingCoordinator: Coordinator {
	
	var childCoordinators: [Coordinator] = []
	
	let navigationController: UINavigationController
	
	let factory: FuzzyMatchingOnboardingFactoryProtocol
	
	let dataSource: IdentitySelectionDataSourceProtocol = IdentitySelectionDataSource(cache: EventGroupCache())
	
	var matchingBlobIds = [[String]]()
	
	let shouldAllowBackNavigationToExitFlow: Bool
	
	private weak var delegate: FuzzyMatchingFlowDelegate?
	
	private let shouldHideSkipButton: Bool
	
	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - matchingBlobIds: an array of an array of blob IDs with a matching identity
	///   - onboardingFactory: the onboarding content factory
	///   - delegate: the fuzzy matching flow delegate
	///   - shouldAllowBackNavigationToExitFlow: whether this flow can be exited by tapping the "back" button in navbar
	init(
		navigationController: UINavigationController,
		matchingBlobIds: [[String]],
		onboardingFactory: FuzzyMatchingOnboardingFactoryProtocol,
		delegate: FuzzyMatchingFlowDelegate,
		shouldHideSkipButton: Bool = false,
		shouldAllowBackNavigationToExitFlow: Bool = false) {
		
		self.navigationController = navigationController
		self.matchingBlobIds = matchingBlobIds
		self.factory = onboardingFactory
		self.delegate = delegate
		self.shouldHideSkipButton = shouldHideSkipButton
		self.shouldAllowBackNavigationToExitFlow = shouldAllowBackNavigationToExitFlow
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
	
	func restartFlow(matchingBlobIds: [[String]]) {
		
		self.matchingBlobIds = matchingBlobIds
		if !navigateBackToStart() {
			userWishesToSeeOnboarding()
		}
	}
	
	func userWishesToSeeOnboarding() {
		
		let backNavigationAction: () -> Void = { [weak self] in
			guard let self else { return }
			self.navigationController.popViewController(animated: true, completion: {
				self.delegate?.fuzzyMatchingUserBackedOutOfFlow()
			})
		}
		
		let viewController = PagedAnnouncementViewController(
			viewModel: PagedAnnouncementViewModel(
				delegate: self,
				pages: factory.pages,
				itemsShouldShowWithFullWidthHeaderImage: true,
				shouldShowWithVWSRibbon: false
			),
			allowsPreviousPageButton: true,
			allowsCloseButton: false,
			allowsNextPageButton: true,
			backButtonAction: navigationController.viewControllers.isNotEmpty && shouldAllowBackNavigationToExitFlow
				? backNavigationAction
				: nil
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesToSeeIdentitySelectionDetails(_ identitySelectionDetails: IdentitySelectionDetails) {
		
		let viewModel = IdentitySelectionDetailsViewModel(identitySelectionDetails: identitySelectionDetails)
		let viewController = IdentitySelectionDetailsViewController(viewModel: viewModel)
		
		presentAsBottomSheet(viewController)
	}
	
	func userWishesToSeeIdentityGroups() {
		
		if let existingListVC = navigationController.viewControllers.first(where: { $0 is ListIdentitySelectionViewController }) {
			navigationController.popToViewController(existingListVC, animated: true)
		} else {
			
			let viewModel = ListIdentitySelectionViewModel(
				coordinatorDelegate: self,
				dataSource: dataSource,
				matchingBlobIds: matchingBlobIds,
				shouldHideSkipButton: shouldHideSkipButton
			)
			let viewController = ListIdentitySelectionViewController(viewModel: viewModel)
			
			navigationController.pushViewController(viewController, animated: true)
		}
	}
	
	func userHasSelectedIdentityGroup(selectedBlobIds: [String]) {

		let viewModel = SendIdentitySelectionViewModel(
			coordinatorDelegate: self,
			dataSource: dataSource,
			matchingBlobIds: matchingBlobIds,
			selectedBlobIds: selectedBlobIds
		)
		let viewController = SendIdentitySelectionViewController(viewModel: viewModel)
		
		navigationController.pushViewController(viewController, animated: false)
	}
	
	func userWishesToSeeSuccess(name: String) {
		
		let content = Content(
			title: L.holder_identitySelection_success_title(),
			body: L.holder_identitySelection_success_body(name),
			primaryActionTitle: L.general_toMyOverview(),
			primaryAction: { [weak self] in
				self?.userHasFinishedTheFlow()
			}
		)
		
		presentContent(content: content, backAction: nil, allowsSwipeBack: false, animated: false)
	}

	func userHasStoppedTheFlow() {
		
		delegate?.fuzzyMatchingFlowDidStop()
	}
	
	func userHasFinishedTheFlow() {
		
		delegate?.fuzzyMatchingFlowDidFinish()
	}
	
	func userWishesMoreInfoAboutWhy() {
		
		let viewModel = BottomSheetContentViewModel(
			content: Content(
				title: L.holder_fuzzyMatching_why_title(),
				body: L.holder_fuzzyMatching_why_body()
			),
			screenCaptureDetector: ScreenCaptureDetector()
		)
		
		let viewController = BottomSheetContentViewController(viewModel: viewModel)
		presentAsBottomSheet(viewController)
	}
	
	func presentError(content: Content, backAction: (() -> Void)?) {
		
		presentContent(content: content, backAction: backAction)
	}
	
	@discardableResult private func navigateBackToStart() -> Bool {

		if let eventStartViewController = navigationController.viewControllers
			.first(where: { $0 is PagedAnnouncementViewController }) {

			navigationController.popToViewController(
				eventStartViewController,
				animated: true
			)
			return true
		}
		return false
	}
}

// MARK: - PagedAnnouncementDelegate

extension FuzzyMatchingCoordinator: PagedAnnouncementDelegate {
	
	func didFinishPagedAnnouncement() {
		
		// Onboarding is done. Continue with the identity groups overview
		userWishesToSeeIdentityGroups()
	}
}
