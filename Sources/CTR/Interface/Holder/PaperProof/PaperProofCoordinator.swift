/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol PaperProofFlowDelegate: AnyObject {
	
	func addPaperProofFlowDidCancel()
	
	func addPaperProofFlowDidFinish()

	func switchToAddRegularProof()
}

protocol PaperProofCoordinatorDelegate: AnyObject {
	
	func userWishesToCancelPaperProofFlow()

	func userWishesMoreInformationOnNoInputToken()

	func userWishesMoreInformationOnWhichProofsCanBeUsed()

	func userDidSubmitPaperProofToken(token: String)

	func userWantsToGoBackToDashboard()

	func userWantsToGoBackToTokenEntry()

	func userWishesToSeeScannedEvent(_ event: RemoteEvent)

	func userWishesToEnterToken()

	func userWishesToScanCertificate()

	func userWishesToCreateACertificate(message: String)

	func displayError(content: Content, backAction: @escaping () -> Void)

	func userWishesToGoBackToScanCertificate()
}

final class PaperProofCoordinator: Coordinator, OpenUrlProtocol {

	var childCoordinators: [Coordinator] = []
	
	var navigationController: UINavigationController

	private weak var delegate: PaperProofFlowDelegate?

	var token: String?

	var scannedQR: String?
	
	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - delegate: the vaccination flow delegate
	init(
		navigationController: UINavigationController,
		delegate: PaperProofFlowDelegate) {

		self.navigationController = navigationController
		self.delegate = delegate
	}
	
	/// Start the scene
	func start() {
		
		let destination = PaperProofStartScanningViewController(
			viewModel: PaperProofStartScanningViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}
	
	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}

extension PaperProofCoordinator: PaperProofCoordinatorDelegate {
	
	func userWishesToCancelPaperProofFlow() {
		
		navigationController.popViewController(animated: true)
		delegate?.addPaperProofFlowDidCancel()
	}

	func userWishesMoreInformationOnNoInputToken() {

		let viewModel = PaperProofContentViewModel(
			content: Content(
				title: L.holderPaperproofNotokenTitle(),
				body: L.holderPaperproofNotokenMessage(),
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: L.holderPaperproofNotokenAction(),
				secondaryAction: { [weak self] in
					self?.delegate?.switchToAddRegularProof()
				}
			)
		)
		let destination = PaperProofContentViewController(viewModel: viewModel)
		navigationController.pushViewController(destination, animated: true)
	}

	func userWishesMoreInformationOnWhichProofsCanBeUsed() {

		let viewController = ContentViewController(
			viewModel: ContentViewModel(
				coordinator: self,
				content: Content(
					title: L.holder_paperproof_whichProofsCanBeUsed_title(),
					body: L.holder_paperproof_whichProofsCanBeUsed_body()
				),
				linkTapHander: { [weak self] url in

					self?.openUrl(url, inApp: true)
				},
				hideBodyForScreenCapture: false
			)
		)
		presentAsBottomSheet(viewController)
	}

	func userDidSubmitPaperProofToken(token: String) {

		// Store Token
		self.token = token

		// Navigate to About Scan
		let destination = PaperProofStartScanningViewController(
			viewModel: PaperProofStartScanningViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}

	func userWantsToGoBackToDashboard() {

		scannedQR = nil
		token = nil
		delegate?.addPaperProofFlowDidFinish()
	}

	func userWantsToGoBackToTokenEntry() {

		scannedQR = nil
		if let tokenEntryViewController = navigationController.viewControllers
			.first(where: { $0 is PaperProofInputCouplingCodeViewController }) {

			navigationController.popToViewController(
				tokenEntryViewController,
				animated: true
			)
		}
	}

	func userWishesToSeeScannedEvent(_ event: RemoteEvent) {

		let eventCoordinator = EventCoordinator(
			navigationController: navigationController,
			delegate: self
		)
		addChildCoordinator(eventCoordinator)
		eventCoordinator.startWithScannedEvent(event)
	}

	func userWishesToEnterToken() {

//		userDidSubmitPaperProofToken(token: "ZKGBKH")

		let destination = PaperProofInputCouplingCodeViewController(
			viewModel: PaperProofInputCouplingCodeViewModel(coordinator: self)
		)

		navigationController.pushViewController(destination, animated: true)
	}

	/// Navigate to the scanner
	func userWishesToScanCertificate() {

//		userWishesToCreateACertificate(message: CouplingManager.vaccinationDCC)

		let destination = PaperProofScanViewController(
			viewModel: PaperProofScanViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}

	func userWishesToCreateACertificate(message: String) {

		// Store
		self.scannedQR = message

		// Navigate to Check Certificate
		if let scannedDcc = scannedQR, let couplingCode = token {
			let viewController = PaperProofCheckViewController(
				viewModel: PaperProofCheckViewModel(
					coordinator: self,
					scannedDcc: scannedDcc,
					couplingCode: couplingCode
				)
			)
			navigationController.pushViewController(viewController, animated: false)
		}
	}

	func displayError(content: Content, backAction: @escaping () -> Void) {

		let viewController = ErrorStateViewController(
			viewModel: ErrorStateViewModel(
				content: content,
				backAction: backAction
			)
		)
		navigationController.pushViewController(viewController, animated: false)
	}

	func userWishesToGoBackToScanCertificate() {

		if let scanViewController = navigationController.viewControllers
			.first(where: { $0 is PaperProofScanViewController }) {

			navigationController.popToViewController(
				scanViewController,
				animated: true
			)
		}
	}

	private func presentAsBottomSheet(_ viewController: UIViewController) {

		navigationController.visibleViewController?.presentBottomSheet(viewController)
	}
}

// MARK: - Dismissable

extension PaperProofCoordinator: Dismissable {

	func dismiss() {

		if navigationController.presentedViewController != nil {
			navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
		} else {
			navigationController.popViewController(animated: false)
		}
	}
}

extension PaperProofCoordinator: EventFlowDelegate {

	func eventFlowDidComplete() {

		cleanup()
		delegate?.addPaperProofFlowDidFinish()
	}

	func eventFlowDidCompleteButVisitorPassNeedsCompletion() {

		// Should not happen.
		eventFlowDidComplete()
	}

	func eventFlowDidCancel() {

		cleanup()
		if let viewController = navigationController.viewControllers
			.first(where: { $0 is PaperProofStartScanningViewController }) {

			navigationController.popToViewController(
				viewController,
				animated: true
			)
		}
	}

	func eventFlowDidCancelFromBackSwipe() {

		cleanup()
	}

	private func removeChildCoordinator() {

		guard let coordinator = childCoordinators.last else { return }
		removeChildCoordinator(coordinator)
	}

	private func cleanup() {
		removeChildCoordinator()
		scannedQR = nil
		token = nil
	}
}
