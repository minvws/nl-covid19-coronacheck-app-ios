/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
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

//	override func viewDidLoad() {
//
//		super.viewDidLoad()
//
//		edgesForExtendedLayout = []
//
//		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
//		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
//		viewModel.$buttonTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }
//
//		viewModel.$showAlert.binding = { [weak self] in
//			if $0 {
//				self?.showAlert()
//			}
//		}
//
//		viewModel.$showError.binding = { [weak self] in
//			if $0 {
//				self?.showError(.errorTitle, message: .technicalErrorText)
//			}
//		}
//
//		viewModel.$errorMessage.binding = { [weak self] in
//			if let message = $0 {
//				self?.showError(.errorTitle, message: message)
//			}
//		}
//
//		viewModel.$listItem.binding = { [weak self] in
//			if let item = $0 {
//				self?.sceneView.resultView.isHidden = false
//				self?.sceneView.resultView.header = .holderTestResultsRecent
//				self?.sceneView.resultView.title = .holderTestResultsNegative
//				self?.sceneView.resultView.message = item.date
//				self?.sceneView.resultView.info = item.holder
//
//			} else {
//				self?.sceneView.resultView.isHidden = true
//			}
//		}
//
//		viewModel.$shouldShowProgress.binding = { [weak self] in
//
//			guard let strongSelf = self else {
//				return
//			}
//
//			if $0 {
//				MBProgressHUD.showAdded(to: strongSelf.sceneView, animated: true)
//				strongSelf.announce(.loading)
//				strongSelf.sceneView.primaryButton.isEnabled = false
//			} else {
//				MBProgressHUD.hide(for: strongSelf.sceneView, animated: true)
//				UIAccessibility.post(notification: .screenChanged, argument: strongSelf.sceneView.primaryButton)
//				strongSelf.sceneView.primaryButton.isEnabled = true
//			}
//		}
//
//		sceneView.primaryButtonTappedCommand = { [weak self] in
//
//			self?.viewModel.buttonTapped()
//		}
//
//		sceneView.resultView.disclaimerButtonTappedCommand = { [weak self] in
//
//			self?.viewModel.disclaimerTapped()
//		}
//
//		addCustomBackButton(action: #selector(closeButtonTapped), accessibilityLabel: .close)
//
//		// Only show an arrow as back button
//		styleBackButton(buttonText: "")
//	}
//
//	override func viewWillAppear(_ animated: Bool) {
//
//		super.viewWillAppear(animated)
//		viewModel.checkResult()
//	}
//
//	/// User tapped on the button
//	@objc func closeButtonTapped() {
//
//		viewModel.dismiss()
//	}
//
//	/// Show alert
//	private func showAlert() {
//
//		let alertController = UIAlertController(
//			title: .holderTestResultsAlertTitle,
//			message: .holderTestResultsAlertMessage,
//			preferredStyle: .alert)
//		alertController.addAction(
//			UIAlertAction(
//				title: .holderTestResultsAlertOk,
//				style: .cancel,
//				handler: { _ in
//					self.viewModel.doDismiss()
//				}
//			)
//		)
//		alertController.addAction(
//			UIAlertAction(
//				title: .holderTestResultsAlertCancel,
//				style: .default,
//				handler: nil
//			)
//		)
//		present(alertController, animated: true, completion: nil)
//	}
}
