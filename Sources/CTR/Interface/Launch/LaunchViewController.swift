/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class LaunchViewController: GenericViewController<LaunchView, LaunchViewModel> {

	override func viewDidLoad() {

		super.viewDidLoad()
		
		setupTranslucentNavigationBar()

		// Bindings
		viewModel.$message.binding = { [weak self] in
			self?.sceneView.message = $0
			UIAccessibility.post(notification: .announcement, argument: $0)
		}
		viewModel.$appIcon.binding = { [weak self] in self?.sceneView.appIcon = $0 }
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		sceneView.spinner.startAnimating()
	}

	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		// We can't start this on viewDidLoad.
		// It could present the dialog while the view is not yet on screen, resulting in an error
		viewModel.$alert.binding = { [weak self] alertContent in
			guard let alertContent else { return }
			self?.showAlert(alertContent)
		}
	}
}
