/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Models
import Resources

class VerifierScanViewController: ScanViewController {
	
	let sceneView = VerifierScanView()

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

		viewModel.$moreInformationButtonText.binding = { [weak self] in self?.sceneView.moreInformationButtonText = $0 }
		
		viewModel.$alert.binding = { [weak self] alertContent in
			guard let alertContent else { return }
			self?.showAlert(alertContent)
		}

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
		
		viewModel.$verificationPolicy.binding = { [weak self] in
			self?.sceneView.verificationPolicy = $0
		}

		sceneView.moreInformationButtonCommand = { [viewModel] in
			viewModel.didTapMoreInformationButton()
		}
		
		addCloseButton(
			action: #selector(closeButtonTapped),
			tintColor: C.white()!
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
		
		showAlert(
			AlertContent(
				title: L.verifierScanPermissionTitle(),
				subTitle: L.verifierScanPermissionMessage(),
				okAction: AlertContent.Action(
					title: L.verifierScanPermissionSettings(),
					action: { [weak self] _ in
						self?.viewModel.gotoSettings()
					}
				),
				cancelAction: AlertContent.Action.cancel
			)
		)
	}
	
	/// Add a close button to the navigation bar.
	/// - Parameters:
	///   - action: The action when the users taps the close button
	///   - tintColor: The button tint color
	func addCloseButton(
		action: Selector,
		tintColor: UIColor = C.black()!) {
			
			let config = UIBarButtonItem.Configuration(
				target: self,
				action: action,
				content: .image(I.cross()),
				tintColor: tintColor,
				accessibilityIdentifier: "CloseButton",
				accessibilityLabel: L.generalClose()
			)
			navigationItem.leftBarButtonItem = .create(config)
		}
}
