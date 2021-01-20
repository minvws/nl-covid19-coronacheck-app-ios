/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierStartViewController: BaseViewController {

	weak var coordinator: VerifierCoordinatorDelegate?

	let sceneView = MainView()

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		title = "Verifier Start"

		sceneView.primaryTitle = "Event"
		sceneView.secondaryTitle = "Generate Event QR"
		sceneView.tertiaryTitle = "Scan Customer"

		sceneView.primaryButtonTappedCommand = { [weak self] in

			self?.coordinator?.navigateToEvent()
		}

		sceneView.secondaryButtonTappedCommand = { [weak self] in

			self?.coordinator?.navigateToEventQR()
		}

		sceneView.tertiaryButtonTappedCommand = { [weak self] in

			self?.coordinator?.navigateToCustomerScan()
		}
    }
}
