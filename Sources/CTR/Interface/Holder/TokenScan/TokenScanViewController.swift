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
		
		configureTranslucentNavigationBar()

		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$errorTitle.binding = { [weak self] in self?.errorTitle = $0 }
		viewModel.$errorMessage.binding = { [weak self] in self?.errorMessage = $0 }

		viewModel.$startScanning.binding = { [weak self] in
			if $0, self?.captureSession?.isRunning == false {
				self?.captureSession.startRunning()
			}
		}
		viewModel.$torchLabels.binding = { [weak self] in
			guard let strongSelf = self else { return }
			strongSelf.addTorchButton(
                action: #selector(strongSelf.toggleTorch),
                enableLabel: $0.first,
                disableLabel: $0.last
            )
		}
		viewModel.$showError.binding = { [weak self] in
			guard let strongSelf = self else {
				return
			}
			if $0 {
				if let title = strongSelf.errorTitle, let message = strongSelf.errorMessage {
					strongSelf.showError(title: title, message: message)
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
