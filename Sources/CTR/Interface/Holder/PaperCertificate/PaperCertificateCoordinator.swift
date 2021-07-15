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

enum PaperCertificateScreenResult: Equatable {

	/// Stop with paper certificate flow,
	case stop

}

protocol PaperCertificateCoordinatorDelegate: AnyObject {

	func checkScreenDidFinish(_ result: PaperCertificateScreenResult)
}

final class PaperCertificateCoordinator: Coordinator, Logging, PaperCertificateCoordinatorDelegate {
	
	var childCoordinators: [Coordinator] = []
	
	var navigationController: UINavigationController = UINavigationController()

	weak var delegate: PaperCertificateFlowDelegate?
	
	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
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
	
	func navigateToTokenEntry() {
		
		// Implement

		navigateToCheck(scannedDcc: CouplingManager.vaccinationDCC, couplingCode: "EBCDEF")
	}

	func navigateToCheck(scannedDcc: String, couplingCode: String) {

		let viewController = PaperCertificateCheckViewController(
			viewModel: PaperCertificateCheckViewModel(
				coordinator: self,
				scannedDcc: scannedDcc,
				couplingCode: couplingCode
			)
		)
		navigationController.pushViewController(viewController, animated: false)
	}

	// MARK: - PaperCertificateCoordinatorDelegate

	func checkScreenDidFinish(_ result: PaperCertificateScreenResult) {

		switch result {
			case .stop:
				delegate?.addCertificateFlowDidFinish()
		}

	}
}
