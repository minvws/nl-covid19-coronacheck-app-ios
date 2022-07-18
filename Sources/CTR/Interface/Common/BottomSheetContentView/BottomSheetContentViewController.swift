/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class BottomSheetContentViewController: GenericViewController<BottomSheetContentView, BottomSheetContentViewModel> {

	override func viewDidLoad() {

		super.viewDidLoad()

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$body.binding = { [weak self] in self?.sceneView.body = $0 }
		viewModel.$secondaryButtonTitle.binding = { [weak self] in
			self?.sceneView.secondaryButtonTitle = $0
		}
		viewModel.$hideForCapture.binding = { [weak self] in
			self?.sceneView.handleScreenCapture(shouldHide: $0)
		}

		sceneView.messageLinkTapHandler = { [weak viewModel] url in
			viewModel?.userDidTapURL(url: url)
		}
		sceneView.secondaryButtonTappedCommand = { [weak viewModel] in
			viewModel?.userDidTapSecondaryButton()
		}
	}
}
