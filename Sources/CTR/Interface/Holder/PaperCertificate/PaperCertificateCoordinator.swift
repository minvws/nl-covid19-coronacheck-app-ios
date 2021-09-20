/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol PaperCertificateFlowDelegate: AnyObject {
	
	func addCertificateFlowDidFinish()
}

protocol PaperCertificateCoordinatorDelegate: AnyObject {

	func userDidSubmitPaperCertificateToken(token: String)

	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool)

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

	private weak var delegate: PaperCertificateFlowDelegate?

	var token: String?

	var scannedQR: String?

	fileprivate var bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate() // swiftlint:disable:this weak_delegate

	/// Initializer
	/// - Parameters:
	///   - delegate: flow delegate
	init(delegate: PaperCertificateFlowDelegate) {
		
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

	func userDidSubmitPaperCertificateToken(token: String) {

		// Store Token
		self.token = token

		// Navigate to About Scan
		let destination = PaperCertificateAboutScanViewController(
			viewModel: PaperCertificateAboutScanViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}

	/// Show an information page
	/// - Parameters:
	///   - title: the title of the page
	///   - body: the body of the page
	///   - hideBodyForScreenCapture: hide sensitive data for screen capture
	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool) {

		let viewController = InformationViewController(
			viewModel: InformationViewModel(
				coordinator: self,
				title: title,
				message: body,
				linkTapHander: { [weak self] url in

					self?.openUrl(url, inApp: true)
				},
				hideBodyForScreenCapture: hideBodyForScreenCapture
			)
		)
		viewController.transitioningDelegate = bottomSheetTransitioningDelegate
		viewController.modalPresentationStyle = .custom
		viewController.modalTransitionStyle = .coverVertical

		navigationController.viewControllers.last?.present(viewController, animated: true, completion: nil)
	}

	func userWantsToGoBackToDashboard() {

		scannedQR = nil
		token = nil
		delegate?.addCertificateFlowDidFinish()
	}

	func userWantsToGoBackToTokenEntry() {

		scannedQR = nil
		if let tokenEntryViewController = navigationController.viewControllers
			.first(where: { $0 is PaperCertificateTokenEntryViewController }) {

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

		let destination = PaperCertificateTokenEntryViewController(
			viewModel: PaperCertificateTokenEntryViewModel(coordinator: self)
		)

		navigationController.pushViewController(destination, animated: true)
	}

	/// Navigate to the scanner
	func userWishesToScanCertificate() {

//		userWishesToCreateACertificate(message: CouplingManager.vaccinationDCC)

		let destination = PaperCertificateScanViewController(
			viewModel: PaperCertificateScanViewModel(
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
			.first(where: { $0 is PaperCertificateScanViewController }) {

			navigationController.popToViewController(
				scanViewController,
				animated: true
			)
		}
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

		removeChildCoordinator()
		scannedQR = nil
		token = nil
		delegate?.addCertificateFlowDidFinish()
	}

	func eventFlowDidCancel() {

		removeChildCoordinator()
		scannedQR = nil
		token = nil
		if let viewController = navigationController.viewControllers
			.first(where: { $0 is PaperCertificateStartViewController }) {

			navigationController.popToViewController(
				viewController,
				animated: true
			)
		}
	}

	private func removeChildCoordinator() {

		guard let coordinator = childCoordinators.last else { return }
		removeChildCoordinator(coordinator)
	}
}
