/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenScanViewController: ScanViewController {

	private let viewModel: TokenScanViewModel

	var errorTitle: String?

	var errorMessage: String?

	// MARK: Initializers

	init(viewModel: TokenScanViewModel) {

		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {

		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		viewModel.$title.binding = { self.title = $0 }
		viewModel.$message.binding = { self.sceneView.message = $0 }
		viewModel.$errorTitle.binding = { self.errorTitle = $0 }
		viewModel.$errorMessage.binding = { self.errorMessage = $0 }

		viewModel.$startScanning.binding = {
			if $0, self.captureSession?.isRunning == false {
				self.captureSession.startRunning()
			}
		}
		viewModel.$torchAccessibility.binding = {
			self.addTorchButton(action: #selector(self.toggleTorch), accessibilityLabel: $0)
		}
		viewModel.$showError.binding = {
			if $0 {
				if let title = self.errorTitle, let message = self.errorMessage {
					self.showError(title: title, message: message)
				}
			}
		}

		// Only show an arrow as back button
		styleBackButton(buttonText: "")
	}

	override func found(code: String) {

		viewModel.parseCode(code)
	}

	/// Show an error dialog
	/// - Parameters:
	///   - title: the title
	///   - message: the message
	private func showError(title: String = .errorTitle, message: String) {

		let alertController = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert)
		alertController.addAction(
			UIAlertAction(
				title: .ok,
				style: .default,
				handler: nil
			)
		)
		present(alertController, animated: true, completion: nil)
	}
}

