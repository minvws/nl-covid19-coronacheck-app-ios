/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class SnapshotViewController: GenericViewController<LaunchView, SnapshotViewModel> {

	override func viewDidLoad() {

		super.viewDidLoad()

		// Bindings
		viewModel.$appIcon.binding = { [weak self] in self?.sceneView.appIcon = $0 }
		viewModel.$dismiss.binding = { [weak self] in
			if $0 {
				self?.dismiss(animated: true, completion: nil)
			}
		}
	}
}
