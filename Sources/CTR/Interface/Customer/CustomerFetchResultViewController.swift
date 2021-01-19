/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class CustomerFetchResultViewController: BaseViewController {

	weak var coordinator: CustomerCoordinatorDelegate?

	let sceneView = MainView()

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		title = "Burger Fetch Result"

		sceneView.primaryTitle = "Test Resultaat Positief"
		sceneView.primaryButtonColor = Theme.colors.warning

		sceneView.secondaryTitle = "Test Resultaat Negatief"
		sceneView.secondaryButtonColor = Theme.colors.ok

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.coordinator?.setTestResult(TestResult(status: .positive, timeStamp: Date()))
			self?.coordinator?.dismiss()
		}

		sceneView.secondaryButtonTappedCommand = { [weak self] in
			self?.coordinator?.setTestResult(TestResult(status: .negative, timeStamp: Date()))
			self?.coordinator?.dismiss()
		}
    }
}
