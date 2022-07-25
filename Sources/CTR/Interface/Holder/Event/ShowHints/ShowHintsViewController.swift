/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class ShowHintsViewController: TraitWrappedGenericViewController<ShowHintsView, ShowHintsViewModel> {
	
	override var enableSwipeBack: Bool { false }
	
	override func viewDidLoad() {

		super.viewDidLoad()
		
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$buttonTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }
		sceneView.primaryButtonTappedCommand = { [weak self] in self?.viewModel.userTappedCallToActionButton() }
		sceneView.contentTextView.linkTouchedHandler = { [weak self] url in self?.viewModel.openUrl(url) }
	}
}
