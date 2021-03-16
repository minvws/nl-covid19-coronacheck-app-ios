/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import MBProgressHUD

class TokenEntryViewController: BaseViewController {

	private let viewModel: TokenEntryViewModel

	var tapGestureRecognizer: UITapGestureRecognizer?

	let sceneView = TokenEntryView()

	init(viewModel: TokenEntryViewModel) {

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

		setupGestureRecognizer(view: sceneView)
		sceneView.tokenEntryView.inputField.delegate = self
		sceneView.tokenEntryView.inputField.tag = 0
		sceneView.verificationEntryView.inputField.delegate = self
		sceneView.verificationEntryView.inputField.tag = 1

			// Only show an arrow as back button
		styleBackButton(buttonText: "")
	}

	func setupBinding() {

		viewModel.$token.binding = { [weak self] token in
			self?.sceneView.tokenEntryView.inputField.text = token
			if token == nil {
				self?.sceneView.tokenEntryView.inputField.becomeFirstResponder()

			}
		}

		viewModel.$showProgress.binding = { [weak self] in
			guard let strongSelf = self else {
				return
			}
			if $0 {
				MBProgressHUD.showAdded(to: strongSelf.sceneView, animated: true)
			} else {
				MBProgressHUD.hide(for: strongSelf.sceneView, animated: true)
			}
		}

		viewModel.$errorMessage.binding = { [weak self] in
			if let message = $0 {
				self?.sceneView.errorView.error = message
				self?.sceneView.errorView.isHidden = false
			} else {
				self?.sceneView.errorView.isHidden = true
			}
		}

		viewModel.$showError.binding = { [weak self] in
			if $0 {
				self?.showError(.technicalErrorTitle, message: .technicalErrorText)
			}
		}

		viewModel.$showVerification.binding = { [weak self] in
			self?.sceneView.verificationEntryView.isHidden = !$0
			if $0 {
				self?.sceneView.verificationEntryView.inputField.becomeFirstResponder()
			}
		}
	}

	func setupContent() {

		sceneView.title = .holderTokenEntryTitle
		sceneView.message = .holderTokenEntryText
		sceneView.tokenEntryView.header = .holderTokenEntryTokenTitle
		sceneView.tokenEntryView.inputField.placeholder = .holderTokenEntryTokenPlaceholder
		sceneView.verificationEntryView.header = .holderTokenEntryVerificationTitle
		sceneView.verificationEntryView.inputField.placeholder = .holderTokenEntryVerificationPlaceholder
		sceneView.verificationEntryView.info = .holderTokenEntryVerificationInfo
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		// Listen to Keyboard events.
		subscribeToKeyboardEvents(
			#selector(keyBoardWillShow(notification:)),
			keyboardWillHide: #selector(keyBoardWillHide(notification:))
		)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func viewWillDisappear(_ animated: Bool) {

		unSubscribeToKeyboardEvents()

		super.viewWillDisappear(animated)
	}

	func setupGestureRecognizer(view: UIView) {

		tapGestureRecognizer = UITapGestureRecognizer(
			target: self,
			action: #selector(handleSingleTap(sender:))
		)
		if let gesture = tapGestureRecognizer {
			gesture.isEnabled = false
			view.addGestureRecognizer(gesture)
		}
	}

	@objc func handleSingleTap(sender: UITapGestureRecognizer) {

		if view != nil {
			view.endEditing(true)
		}
	}

	// MARK: Keyboard

	@objc func keyBoardWillShow(notification: Notification) {

		tapGestureRecognizer?.isEnabled = true
		sceneView.scrollView.contentInset.bottom = notification.getHeight() + 30 // 30: Also show the error view.
	}

	@objc func keyBoardWillHide(notification: Notification) {

		tapGestureRecognizer?.isEnabled = false
		sceneView.scrollView.contentInset.bottom = 0.0
	}
}

// MARK: - UITextFieldDelegate

extension TokenEntryViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		textField.resignFirstResponder()
		return true
	}

	func textFieldDidEndEditing(_ textField: UITextField) {

		if textField.tag == 0 {
			viewModel.checkToken(textField.text)
		} else {
			viewModel.checkVerification(textField.text)
		}
	}
}

extension Notification {

	func getHeight() -> CGFloat {

		var height: CGFloat = 0.0
		if let keyboardFrame = self.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
			height += keyboardFrame.height
		}
		return height
	}
}
