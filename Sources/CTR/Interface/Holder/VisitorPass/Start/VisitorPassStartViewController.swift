/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class VisitorPassStartViewController: TraitWrappedGenericViewController<VisitorPassStartView, VisitorPassStartViewModel> {

	override func viewDidLoad() {

		super.viewDidLoad()

		addBackButton(customAction: nil)
		
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$buttonTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }
		sceneView.primaryButtonTappedCommand = { [weak self] in self?.viewModel.navigateToTokenEntry() }
		sceneView.contentTextView.linkTouchedHandler = { [weak self] url in self?.viewModel.openUrl(url) }
	}
}
