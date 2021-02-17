/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import EasyTipView
import MBProgressHUD

class ListResultsViewController: BaseViewController {
	
	private let viewModel: ListResultsViewModel

	let sceneView = ListResultsView()

	init(viewModel: ListResultsViewModel) {

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

		edgesForExtendedLayout = []

		viewModel.$title.binding = { self.sceneView.title = $0 }
		viewModel.$message.binding = { self.sceneView.message = $0 }
		viewModel.$buttonTitle.binding = { self.sceneView.primaryTitle = $0 }

		viewModel.$showAlert.binding = {
			if $0 {
				self.showAlert()
			}
		}

		viewModel.$showError.binding = {
			if let error = $0 {
				self.showError(error)
			}
		}

		viewModel.$listItem.binding = {
			if let item = $0 {
				self.sceneView.resultView.isHidden = false
				self.sceneView.resultView.header = .holderTestResultsRecent
				self.sceneView.resultView.title = .holderTestResultsNegative
				self.sceneView.resultView.message = item.date

			} else {
				self.sceneView.resultView.isHidden = true
			}
		}

		viewModel.$showProgress.binding = {

			if $0 {
				MBProgressHUD.showAdded(to: self.sceneView, animated: true)
				self.sceneView.primaryButton.isEnabled = false
			} else {
				MBProgressHUD.hide(for: self.sceneView, animated: true)
				self.sceneView.primaryButton.isEnabled = true
			}
		}

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.buttonClick()
		}

		var preferences = EasyTipView.Preferences()
		preferences.drawing.foregroundColor = Theme.colors.viewControllerBackground
		preferences.drawing.backgroundColor = Theme.colors.dark
		preferences.drawing.arrowPosition = .bottom

		tooltip = EasyTipView(text: .holderTestResultsDisclaimer, preferences: preferences)

		sceneView.resultView.disclaimerButtonTappedCommand = {

			self.tooltip?.show(forView: self.sceneView.resultView.disclaimerButton)
		}

		addCloseButton(action: #selector(closeButtonTapped), accessibilityLabel: .close)

		// Only show an arrow as back button
		styleBackButton(buttonText: "")
	}

	var tooltip: EasyTipView?

	/// User tapped on the button
	@objc private func closeButtonTapped() {

		viewModel.dismiss()
	}

	/// Add a close button to the navigation bar.
	/// - Parameters:
	///   - action: the action when the users taps the close button
	///   - accessibilityLabel: the label for Voice Over
	func addCloseButton(
		action: Selector?,
		accessibilityLabel: String) {

		let button = UIBarButtonItem(
			image: .cross,
			style: .plain,
			target: self,
			action: action
		)
		button.accessibilityIdentifier = "CloseButton"
		button.accessibilityLabel = accessibilityLabel
		button.accessibilityTraits = UIAccessibilityTraits.button
		navigationItem.hidesBackButton = true
		navigationItem.leftBarButtonItem = button
		navigationController?.navigationItem.leftBarButtonItem = button
		navigationController?.navigationBar.backgroundColor = Theme.colors.viewControllerBackground
	}

	/// Show alert
	private func showAlert() {

		let alertController = UIAlertController(
			title: .holderTestResultsAlertTitle,
			message: .holderTestResultsAlertMessage,
			preferredStyle: .alert)
		alertController.addAction(
			UIAlertAction(
				title: .holderTestResultsAlertOk,
				style: .default,
				handler: { _ in
					self.viewModel.doDismiss()
				}
			)
		)
		alertController.addAction(
			UIAlertAction(
				title: .holderTestResultsAlertCancel,
				style: .cancel,
				handler: nil
			)
		)
		present(alertController, animated: true, completion: nil)
	}

	/// Show alert
	private func showError(_ message: String) {

		let alertController = UIAlertController(
			title: .errorTitle,
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
