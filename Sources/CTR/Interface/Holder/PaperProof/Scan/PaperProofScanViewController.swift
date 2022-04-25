/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PaperProofScanViewController: ScanViewController {
	
	let sceneView = PaperProofScanView()

	private let viewModel: PaperProofScanViewModel

	// MARK: Initializers

	init(viewModel: PaperProofScanViewModel) {

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
		
		setupTranslucentNavigationBar()

		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
	
		viewModel.$alert.binding = { [weak self] in self?.showAlert($0) }

		viewModel.$shouldResumeScanning.binding = { [weak self] in
			if let value = $0, value {
				self?.resumeScanning()
			}
		}

		viewModel.$torchLabels.binding = { [weak self] in
			guard let strongSelf = self, let enableLabel = $0.first, let disableLabel = $0.last else { return }
			strongSelf.addTorchButton(
                action: #selector(strongSelf.toggleTorch),
                enableLabel: enableLabel,
                disableLabel: disableLabel
            )
		}
		viewModel.$showPermissionWarning.binding = { [weak self] in
			if $0 {
				self?.showPermissionError()
			}
		}

		// Only show an arrow as back button
		addBackButton()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		attachCameraViewAndStartRunning(sceneView.scanView.cameraView)
	}

	override func found(code: String) {

		viewModel.parseQRMessage(code)
	}

	/// Show alert
	func showPermissionError() {

		let alertController = UIAlertController(
			title: L.holder_scanner_permission_title(),
			message: L.holder_scanner_permission_message(),
			preferredStyle: .alert
		)
		alertController.addAction(
			UIAlertAction(
				title: L.holder_scanner_permission_settings(),
				style: .default,
				handler: { [weak self] _ in
					self?.viewModel.gotoSettings()
				}
			)
		)
		alertController.addAction(
			UIAlertAction(
				title: L.general_cancel(),
				style: .cancel,
				handler: nil
			)
		)
		present(alertController, animated: true, completion: nil)
	}
}
