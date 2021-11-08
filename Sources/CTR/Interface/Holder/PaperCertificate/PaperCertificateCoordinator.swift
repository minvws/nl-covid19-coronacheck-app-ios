/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol PaperProofFlowDelegate: AnyObject {
	
	func addPaperProofFlowDidFinish()

	func switchToAddRegularProof()
}

protocol PaperCertificateCoordinatorDelegate: AnyObject {

	func userWishesMoreInformationOnSelfPrintedProof()

	func userWishesMoreInformationOnNoInputToken()

	func userWishesMoreInformationOnInternationalQROnly()

	func userDidSubmitPaperCertificateToken(token: String)

	func userWantsToGoBackToDashboard()

	func userWantsToGoBackToTokenEntry()

	func userWishesToSeeScannedEvent(_ event: RemoteEvent)

	func userWishesToEnterToken()

	func userWishesToScanCertificate()

	func userWishesToCreateACertificate(message: String)

	func displayError(content: Content, backAction: @escaping () -> Void)

	func userWishesToGoBackToScanCertificate()
}

final class PaperCertificateCoordinator: Coordinator, Logging, OpenUrlProtocol {

	var childCoordinators: [Coordinator] = []
	
	var navigationController: UINavigationController = UINavigationController()

	private weak var delegate: PaperProofFlowDelegate?

	var token: String?

	var scannedQR: String?

	/// Initializer
	/// - Parameters:
	///   - delegate: flow delegate
	init(delegate: PaperProofFlowDelegate) {
		
		self.delegate = delegate
	}
	
	/// Start the scene
	func start() {
		// Not implemented. Starts in holder coordinator
	}
	
	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}

extension PaperCertificateCoordinator: PaperCertificateCoordinatorDelegate {

	func userWishesMoreInformationOnSelfPrintedProof() {

		let viewModel = PaperProofContentViewModel(
			content: Content(
				title: L.holderPaperproofSelfprintedTitle(),
				subTitle: L.holderPaperproofSelfprintedMessage(),
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: L.holderPaperproofSelfprintedAction(),
				secondaryAction: { [weak self] in
					self?.delegate?.switchToAddRegularProof()
				}
			)
		)
		let destination = PaperProofContentViewController(viewModel: viewModel)
		navigationController.pushViewController(destination, animated: true)
	}

	func userWishesMoreInformationOnNoInputToken() {

		let viewModel = PaperProofContentViewModel(
			content: Content(
				title: L.holderPaperproofNotokenTitle(),
				subTitle: L.holderPaperproofNotokenMessage(),
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

	func userWishesMoreInformationOnInternationalQROnly() {

		let viewController = InformationViewController(
			viewModel: InformationViewModel(
				coordinator: self,
				title: L.holderPaperproofInternationalQROnlyTitle(),
				message: L.holderPaperproofInternationalQROnlyMessage(),
				linkTapHander: { [weak self] url in

					self?.openUrl(url, inApp: true)
				},
				hideBodyForScreenCapture: false
			)
		)
		presentAsBottomSheet(viewController)
	}

	func userDidSubmitPaperCertificateToken(token: String) {

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

//		userDidSubmitPaperCertificateToken(token: "NDREB5")

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
			let viewController = PaperCertificateCheckViewController(
				viewModel: PaperCertificateCheckViewModel(
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

extension PaperCertificateCoordinator: Dismissable {

	func dismiss() {

		if navigationController.presentedViewController != nil {
			navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
		} else {
			navigationController.popViewController(animated: false)
		}
	}
}

extension PaperCertificateCoordinator: EventFlowDelegate {

	func eventFlowDidComplete() {

		cleanup()
		delegate?.addPaperProofFlowDidFinish()
	}

	func eventFlowDidCancel() {

		cleanup()
		if let viewController = navigationController.viewControllers
			.first(where: { $0 is PaperProofStartViewController }) {

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
