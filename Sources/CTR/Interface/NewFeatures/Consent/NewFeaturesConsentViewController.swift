/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class NewFeaturesConsentViewController: BaseViewController {

	/// The model
	let viewModel: NewFeaturesConsentViewModel

	/// The view
	let sceneView = NewFeaturesConsentView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: NewFeaturesConsentViewModel) {

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

		setupContent()
		setupBindings()
		setupActions()
	}

	/// setup the bindings
	func setupBindings() {

		viewModel.$useSecondaryButton.binding = { [weak self] in
			if $0 {
				self?.sceneView.showSecondaryButton()
			} else {
				self?.sceneView.hideSecondaryButton()
			}
		}

		viewModel.$showErrorDialog.binding = { [weak self] in
			if $0 {
				self?.showErrorDialog()
			}
		}
	}

	/// Setup the content
	func setupContent() {

		sceneView.title = viewModel.title
		sceneView.highlight = viewModel.highlights
		sceneView.content = viewModel.content
		sceneView.primaryTitle = viewModel.primaryActionTitle
		sceneView.secondaryTitle = viewModel.secondaryActionTitle ?? ""
	}

	/// Setup the buttons
	func setupActions() {

		sceneView.primaryButtonTappedCommand = { [weak self] in

			self?.viewModel.primaryButtonTapped()
		}

		sceneView.secondaryButtonTappedCommand = { [weak self] in

			self?.viewModel.secondaryButtonTapped()
		}

		sceneView.contentTextView.linkTouched { [weak self] url in

			self?.viewModel.openUrl(url)
		}
	}

	/// Show the error dialog
	func showErrorDialog() {

		showError(viewModel.errorTitle, message: viewModel.errorMessage)
	}
}
