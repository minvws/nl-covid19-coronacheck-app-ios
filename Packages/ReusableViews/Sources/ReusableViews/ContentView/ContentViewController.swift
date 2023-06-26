/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

public class ContentViewController: TraitWrappedGenericViewController<ContentView, ContentViewModel> {
	
	override public func viewDidLoad() {

		super.viewDidLoad()

		if viewModel.showBackButton {
			addBackButton(customAction: #selector(self.backButtonTapped))
		}
		
		viewModel.$content.binding = { [weak self] in
			self?.displayContent($0)
		}
		
		sceneView.contentTextView.linkTouchedHandler = { [weak self] url in
			
			self?.viewModel.openUrl(url)
		}
	}
	
	override public var enableSwipeBack: Bool {

		viewModel.allowsSwipeBack
	}

	@objc public func backButtonTapped() {

		viewModel.backButtonTapped()
	}

	private func displayContent(_ content: Content) {

		// Texts
		sceneView.title = content.title
		sceneView.message = content.body

		// Button
		sceneView.primaryTitle = content.primaryActionTitle
		sceneView.primaryButtonTappedCommand = content.primaryAction
		sceneView.secondaryButtonTappedCommand = content.secondaryAction
		sceneView.secondaryButtonTitle = content.secondaryActionTitle
	}
}
