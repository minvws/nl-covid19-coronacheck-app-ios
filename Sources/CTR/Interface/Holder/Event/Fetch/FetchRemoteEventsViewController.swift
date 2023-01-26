/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class FetchRemoteEventsViewController: TraitWrappedGenericViewController<FetchRemoteEventsView, FetchRemoteEventsViewModel> {

	enum State {
		case loading(content: Content)
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		addBackButton(customAction: #selector(backButtonTapped))

		viewModel.$shouldShowProgress.binding = { [weak self] in
			self?.sceneView.shouldShowLoadingSpinner = $0
		}

		viewModel.$viewState.binding = { [weak self] in

			switch $0 {
				case let .loading(content):
					self?.sceneView.shouldShowLoadingSpinner = true
					self?.sceneView.applyContent(content)
			}
		}

		viewModel.$alert.binding = { [weak self] alertContent in
			guard let alertContent else { return }
			self?.showAlert(alertContent)
		}
	}
	
	override var enableSwipeBack: Bool { false }

	@objc func backButtonTapped() {

		viewModel.backButtonTapped()
	}
}
