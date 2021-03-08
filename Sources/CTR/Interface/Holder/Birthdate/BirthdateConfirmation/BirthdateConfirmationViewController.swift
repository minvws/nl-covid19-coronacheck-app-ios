/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class BirthdateConfirmationViewController: BaseViewController {

	private let viewModel: BirthdateConfirmationViewModel

	let sceneView = BirthdateConfirmationView()

	init(viewModel: BirthdateConfirmationViewModel) {

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

		setupContent()
		setupBinding()

		addCloseButton(action: #selector(closeButtonTapped), accessibilityLabel: .close)
	}

	@objc func closeButtonTapped() {

		viewModel.dismiss()
	}

	func setupBinding() {

		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$isButtonEnabled.binding = { [weak self] in self?.sceneView.primaryButton.isEnabled = $0 }
		viewModel.$confirm.binding = { [weak self] in self?.sceneView.consent = $0 }
		self.sceneView.consentButton.valueChanged(self, action: #selector(consentValueChanged))

		viewModel.$showDialog.binding = { [weak self] in
			
			if let window = self?.view.window {
				if $0 {
					self?.sceneView.confirmationView.embed(in: window)
				} else {
					self?.sceneView.confirmationView.removeFromSuperview()
				}
			}
		}

		self.sceneView.secondaryButtonTappedCommand = { [weak self] in
			self?.viewModel.secondaryButtonTapped()
		}
		self.sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.primaryButtonTapped()
		}
		self.sceneView.confirmationView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.confirmButtonTapped()
		}
	}

	func setupContent() {

		sceneView.title = .holderBirthdayConfirmationTitle
		sceneView.primaryTitle = .holderBirthdayConfirmationButtonTitle
		sceneView.secondaryTitle = .holderBirthdayConfirmationAdjustTitle
		sceneView.confirmationView.title = .holderBirthdayConfirmationFinished
		sceneView.confirmationView.primaryTitle = .ok
	}

	/// User tapped on the consent button
	@objc func consentValueChanged(_ sender: ConsentButton) {

		sceneView.primaryButton.isEnabled = sender.isSelected
	}
}
