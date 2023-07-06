/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI

class ImportViewController: ScanViewController {
	
	let sceneView = ImportView()

	private let viewModel: ImportViewModel

	// MARK: Initializers

	init(viewModel: ImportViewModel) {

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
		
		self.continuesScanning = true
		
		setupTranslucentNavigationBar()

		viewModel.title.observe { [weak self] in self?.title = $0 }
		
		viewModel.step.observe { [weak self] in self?.sceneView.step = $0 }
		viewModel.header.observe { [weak self] in self?.sceneView.header = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.message = $0 }
		viewModel.progress.observe { [weak self] in self?.sceneView.progress = $0 }

		viewModel.shouldStopScanning.observe { [weak self] in
			if $0 {
				self?.stopScanning()
			}
		}

		viewModel.torchLabels.observe { [weak self] labels in
			guard let strongSelf = self, let enableLabel = labels.first, let disableLabel = labels.last else { return }
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
	
	override func found(code: String) {
		
		viewModel.parseQRMessage(code)
	}

	/// Show alert
	func showPermissionError() {
		
		showAlert(
			AlertContent(
				title: L.holder_scanner_permission_title(),
				subTitle: L.holder_scanner_permission_message(),
				okAction: AlertContent.Action(
					title: L.holder_scanner_permission_settings(),
					action: { [weak self] _ in
						self?.viewModel.gotoSettings()
					}
				),
				cancelAction: AlertContent.Action.cancel
			)
		)
	}
}
