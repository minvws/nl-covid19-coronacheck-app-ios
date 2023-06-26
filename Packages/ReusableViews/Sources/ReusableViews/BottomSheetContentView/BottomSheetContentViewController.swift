/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

public class BottomSheetContentViewController: GenericViewController<BottomSheetContentView, BottomSheetContentViewModel> {

	public override func viewDidLoad() {

		super.viewDidLoad()

		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.body.observe { [weak self] in self?.sceneView.body = $0 }
		viewModel.secondaryButtonTitle.observe { [weak self] in
			self?.sceneView.secondaryButtonTitle = $0
		}
		viewModel.hideForCapture.observe { [weak self] in
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
