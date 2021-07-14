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

final class PaperCertificateCoordinator: Coordinator, Logging {
	
	var childCoordinators: [Coordinator] = []
	
	var navigationController: UINavigationController
	
	weak var delegate: PaperCertificateFlowDelegate?
	
	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	init(navigationController: UINavigationController,
		 delegate: PaperCertificateFlowDelegate) {
		
		self.navigationController = navigationController
		self.delegate = delegate
	}
	
	/// Start the scene
	func start() {
		
	}
	
	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}
