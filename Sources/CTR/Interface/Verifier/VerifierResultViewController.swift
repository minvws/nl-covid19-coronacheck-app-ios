/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierResultViewController: BaseViewController {

	weak var coordinator: VerifierCoordinatorDelegate?

	var valid: Bool = false

	let sceneView = ResultView()

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

    override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		title = "Verifier Result"

		sceneView.primaryTitle = "Scan Again"
		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.coordinator?.dismiss()
		}

		if valid {
			sceneView.labelText = "V"
			sceneView.labelColor = Theme.colors.ok
		} else {
			sceneView.labelText = "X"
			sceneView.labelColor = Theme.colors.warning
		}
	}
}
