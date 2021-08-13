/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class LoginTVSViewController: BaseViewController {

	private let viewModel: LoginTVSViewModel
	private let sceneView = FetchEventsView()

	struct AlertContent {
		let title: String
		let subTitle: String
		let okTitle: String
	}

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: LoginTVSViewModel) {

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

		// Hide button part
		sceneView.showLineView = false
		sceneView.primaryTitle = L.generalCancel()
		sceneView.primaryButtonTappedCommand = { [weak self] in self?.viewModel.cancel() }

		// Binding

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }

		viewModel.$shouldShowProgress.binding = { [weak self] in

			if $0 {
				self?.sceneView.spinner.startAnimating()
			} else {
				self?.sceneView.spinner.stopAnimating()
			}
		}

		viewModel.$alert.binding = { [weak self] in self?.showAlert($0) }
		viewModel.login()
	}

	func showAlert(_ alertContent: AlertContent?) {

		guard let content = alertContent else {
			return
		}

		let alertController = UIAlertController(
			title: content.title,
			message: content.subTitle,
			preferredStyle: .alert
		)
		alertController.addAction(
			UIAlertAction(
				title: content.okTitle,
				style: .default,
				handler: nil
			)
		)
		present(alertController, animated: true, completion: nil)
	}
}
