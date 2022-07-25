/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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

	func userWishesToScanCertificate()
	
	func userDidScanDCC(_ message: String)
	
	func userWishesToEnterToken()
	
	func userDidSubmitPaperProofToken(token: String)
	
	func userWishesToCreateACertificate()
	
	func userWantsToGoBackToDashboard()

	func userWantsToGoBackToEnterToken()
	
	func userWishesToSeeScannedEvent(_ event: RemoteEvent)

	func displayError(content: Content, backAction: @escaping () -> Void)
	
	func displayErrorForPaperProofCheck(content: Content)
}

final class PaperProofCoordinator: Coordinator, OpenUrlProtocol {

	var childCoordinators: [Coordinator] = []
	
	var navigationController: UINavigationController

	private weak var delegate: PaperProofFlowDelegate?

	var token: String?

	var scannedDCC: String?
	
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
	
	// MARK: - Universal Link handling
	
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

		presentContent(
			content: Content(
				title: L.holderPaperproofNotokenTitle(),
				body: L.holderPaperproofNotokenMessage(),
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: L.holderPaperproofNotokenAction(),
				secondaryAction: { [weak self] in
					self?.navigationController.popToRootViewController(animated: false)
					self?.delegate?.switchToAddRegularProof()
				}
			),
			backAction: { [weak navigationController] in
				navigationController?.popViewController(animated: true, completion: {})
			},
			allowsSwipeBack: true,
			animated: true
		)
	}

	func userWishesMoreInformationOnWhichProofsCanBeUsed() {

		let viewController = BottomSheetContentViewController(
			viewModel: BottomSheetContentViewModel(
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

	/// Navigate to the scanner
	func userWishesToScanCertificate() {
		
		// userDidScanDCC(CouplingManager.vaccinationDCC)
		// userWishesToEnterToken()
		
		if let scannedDCC = LaunchArgumentsHandler.getScannedDCC() {
			userDidScanDCC(scannedDCC)
			switch PaperProofIdentifier().identify(scannedDCC) {
				case .dutchDCC:
					userWishesToEnterToken()
				case .foreignDCC:
					if let wrapper = Current.couplingManager.convert(scannedDCC, couplingCode: nil) {
						let remoteEvent = RemoteEvent(wrapper: wrapper, signedResponse: nil)
						userWishesToSeeScannedEvent(remoteEvent)
					}
				default:
					return
			}
			return
		}
		
		let destination = PaperProofScanViewController(
			viewModel: PaperProofScanViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}
	
	func userWishesToEnterToken() {
		
		// userDidSubmitPaperProofToken(token: "ZKGBKH")
		// userWishesToCreateACertificate()
		
		if let couplingCode = LaunchArgumentsHandler.getCouplingCode() {
			userDidSubmitPaperProofToken(token: couplingCode)
			userWishesToCreateACertificate()
			return
		}
		
		let destination = PaperProofInputCouplingCodeViewController(
			viewModel: PaperProofInputCouplingCodeViewModel(coordinator: self)
		)
		
		navigationController.pushViewController(destination, animated: true)
	}
	
	func userDidSubmitPaperProofToken(token: String) {

		// Store Token
		self.token = token
	}

	func userWantsToGoBackToDashboard() {

		scannedDCC = nil
		token = nil
		delegate?.addPaperProofFlowDidFinish()
	}
	
	func userWantsToGoBackToEnterToken() {
		
		if let viewController = navigationController.viewControllers
			.first(where: { $0 is PaperProofInputCouplingCodeViewController }) {
			
			navigationController.popToViewController(
				viewController,
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
	
	func userDidScanDCC(_ message: String) {
		
		// Store
		self.scannedDCC = message
	}

	func userWishesToCreateACertificate() {

		// Navigate to Check Certificate
		if let scannedDcc = scannedDCC, let couplingCode = token {
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
		
		presentContent(content: content, backAction: backAction, allowsSwipeBack: true)
	}
	
	func displayErrorForPaperProofCheck(content: Content) {

		// Remove the check view controller. Fixes backswipe issue.
		navigationController.popViewController(animated: false)
		
		// Present the error
		displayError(content: content) { [weak self] in
			self?.userWantsToGoBackToEnterToken()
		}
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
		scannedDCC = nil
		token = nil
	}
}
