/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PaperProofCheckViewController: BaseViewController {

	enum State {
		case loading(content: Content)
		case feedback(content: Content)
	}

	private let viewModel: PaperProofCheckViewModel
	let sceneView = FetchEventsView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: PaperProofCheckViewModel) {

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

		viewModel.$shouldShowProgress.binding = { [weak self] in

			if $0 {
				self?.sceneView.spinner.startAnimating()
			} else {
				self?.sceneView.spinner.stopAnimating()
			}
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

		viewModel.$alert.binding = { [weak self] in
			self?.showAlert($0)
		}
	}

	private func setForLoadingState(_ content: Content) {

		sceneView.spinner.isHidden = false
		displayContent(content)
	}

	private func setForFeedback(_ content: Content) {

		sceneView.spinner.isHidden = true
		displayContent(content)
	}

	private func displayContent(_ content: Content) {

		// Texts
		sceneView.title = content.title
		sceneView.message = content.subTitle

		// Button
		if let actionTitle = content.primaryActionTitle {
			sceneView.primaryTitle = actionTitle
			sceneView.footerButtonView.isHidden = false
		} else {
			sceneView.primaryTitle = nil
			sceneView.footerButtonView.isHidden = true
		}
		sceneView.primaryButtonTappedCommand = content.primaryAction
		sceneView.secondaryButtonTappedCommand = content.secondaryAction
		sceneView.secondaryButtonTitle = content.secondaryActionTitle
	}
}
