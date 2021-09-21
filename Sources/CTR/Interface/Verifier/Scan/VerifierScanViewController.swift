/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierScanViewController: ScanViewController {
	
	struct AlertContent {
		let title: String
		let subTitle: String
		let okTitle: String
	}

	private let viewModel: VerifierScanViewModel

	init(viewModel: VerifierScanViewModel) {

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

		viewModel.$moreInformationButtonText.binding = { [weak self] in self?.sceneView.moreInformationButtonText = $0 }
		
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

		sceneView.moreInformationButtonCommand = { [viewModel] in
			viewModel.didTapMoreInformationButton()
		}
		
		addCloseButton(
			action: #selector(closeButtonTapped),
			backgroundColor: .clear,
			tintColor: .white
		)
	}

	override func found(code: String) {

		viewModel.parseQRMessage(code)
	}

	/// User tapped on the button
	@objc func closeButtonTapped() {

		viewModel.dismiss()
	}

	/// Show alert
	func showPermissionError() {

		let alertController = UIAlertController(
			title: L.verifierScanPermissionTitle(),
			message: L.verifierScanPermissionMessage(),
			preferredStyle: .alert
		)
		alertController.addAction(
			UIAlertAction(
				title: L.verifierScanPermissionSettings(),
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
