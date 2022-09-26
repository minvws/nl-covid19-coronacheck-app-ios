/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PaperProofCheckViewController: TraitWrappedGenericViewController<FetchRemoteEventsView, PaperProofCheckViewModel> {

	enum State {
		case loading(content: Content)
		case feedback(content: Content)
	}
	
	override func viewDidLoad() {

		super.viewDidLoad()

		viewModel.$shouldShowProgress.binding = { [weak self] in
			self?.sceneView.shouldShowLoadingSpinner = $0
		}
 
		viewModel.$viewState.binding = { [weak self] in

			switch $0 {
				case let .feedback(content):
					self?.setForFeedback(content)
				case let .loading(content):
					self?.setForLoadingState(content)
			}
		}

		viewModel.$shouldPrimaryButtonBeEnabled.binding = { [weak self] in
			self?.sceneView.primaryButton.isEnabled = $0
		}

		viewModel.$alert.binding = { [weak self] alertContent in
			guard let alertContent else { return }
			self?.showAlert(alertContent)
		}
		
		addBackButton()
	}

	private func setForLoadingState(_ content: Content) {
		
		sceneView.shouldShowLoadingSpinner = true
		sceneView.applyContent(content)
	}

	private func setForFeedback(_ content: Content) {

		sceneView.shouldShowLoadingSpinner = false
		sceneView.applyContent(content)
	}
}
