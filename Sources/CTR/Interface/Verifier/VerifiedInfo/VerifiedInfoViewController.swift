/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class VerifiedInfoViewController: GenericViewController<VerifiedInfoView, VerifiedInfoViewModel> {

	override func viewDidLoad() {

		super.viewDidLoad()

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$primaryTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }
		viewModel.$primaryButtonIcon.binding = { [weak self] in self?.sceneView.primaryButtonIcon = $0 }
		
		sceneView.primaryButton.touchUpInside(viewModel, action: #selector(VerifiedInfoViewModel.onTap))
		
		addBackButton()
	}
}
