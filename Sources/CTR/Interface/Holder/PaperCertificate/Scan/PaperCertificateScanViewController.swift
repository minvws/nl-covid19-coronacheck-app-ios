/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PaperCertificateScanViewController: ScanViewController {

	private let viewModel: PaperCertificateScanViewModel

	// MARK: Initializers

	init(viewModel: PaperCertificateScanViewModel) {

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
			guard let strongSelf = self else { return }
			strongSelf.addTorchButton(
                action: #selector(strongSelf.toggleTorch),
                enableLabel: $0.first,
                disableLabel: $0.last
            )
		}
		viewModel.$showPermissionWarning.binding = { [weak self] in
			if $0 {
				self?.showPermissionError()
			}
		}

		// Only show an arrow as back button
		styleBackButton()
	}

	override func found(code: String) {

		viewModel.parseQRMessage(code)
	}

	/// Show alert
	func showPermissionError() {

		let alertController = UIAlertController(
			title: L.holderScannerPermissionTitle(),
			message: L.holderScannerAlertDccMessage(),
			preferredStyle: .alert
		)
		alertController.addAction(
			UIAlertAction(
				title: L.holderScannerPermissionSettings(),
				style: .default,
				handler: { [weak self] _ in
					self?.viewModel.gotoSettings()
				}
			)
		)
		alertController.addAction(
			UIAlertAction(
				title: L.generalCancel(),
				style: .cancel,
				handler: nil
			)
		)
		present(alertController, animated: true, completion: nil)
	}
}
