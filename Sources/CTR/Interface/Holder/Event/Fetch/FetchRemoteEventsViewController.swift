/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class FetchRemoteEventsViewController: BaseViewController {

	enum State {
		case loading(content: Content)
		case feedback(content: Content)
	}

	private let viewModel: FetchRemoteEventsViewModel
	private let sceneView = FetchRemoteEventsView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: FetchRemoteEventsViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	/// Required initialzer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
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
					self?.setForLoadingState(content)
				case let .feedback(content):
					self?.setForFeedback(content)
			}
		}

		viewModel.$alert.binding = { [weak self] in
			self?.showAlert($0)
		}

		sceneView.contentTextView.linkTouchedHandler = { [weak self] url in

			self?.viewModel.openUrl(url)
		}
	}
	
	override var enableSwipeBack: Bool { false }

	@objc func backButtonTapped() {

		viewModel.backButtonTapped()
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
