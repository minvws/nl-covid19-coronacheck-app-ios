/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class MainViewController: BaseViewController {

	weak var coordinator: MainCoordinatorDelegate?

	let sceneView = MainView()

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
		title = "Corona Testbewijs"
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		sceneView.primaryTitle = "Burger"
		sceneView.secondaryTitle = "Verifier"

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.coordinator?.navigateToCustomer()
		}

		sceneView.secondaryButtonTappedCommand = { [weak self] in
			self?.coordinator?.navigateToVerifier()
		}
    }
}
