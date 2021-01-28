/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AppUpdateViewController: BaseViewController {

	/// The model
	private let viewModel: AppUpdateViewModel

	/// The view
	let sceneView = AppUpdateView()

	/// Initializer
	/// - Parameter viewModel: view model
    init(viewModel: AppUpdateViewModel) {

        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

	/// Required initialzer
	/// - Parameter coder: the code
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	/// Show always in portrait
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

    override func viewDidLoad() {

        super.viewDidLoad()

		// Binding
		viewModel.$showCannotOpenAppStoreAlert.binding = {
			if $0 {
				self.showCannotOpenUrl()
			}
		}
		viewModel.$message.binding = {
			self.sceneView.messageLabel.text = $0
		}

		// Fixed texts & actions
		sceneView.titleLabel.text = .updateAppTitle
		sceneView.primaryButton.setTitle(.updateAppButton, for: .normal)
		sceneView.primaryButton.touchUpInside(self, action: #selector(updateButtonTapped))
    }

	/// User tapped on the button
    @objc private func updateButtonTapped() {

		viewModel.updateButtonTapped()
    }

	/// Show alert that we can't open the url
	private func showCannotOpenUrl() {

		let alertController = UIAlertController(
			title: .errorTitle,
			message: .updateAppErrorMessage,
			preferredStyle: .alert)
		alertController.addAction(
			UIAlertAction(
				title: .ok,
				style: .default,
				handler: nil)
		)
		present(alertController, animated: true, completion: nil)
	}
}
