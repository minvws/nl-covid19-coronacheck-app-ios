/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import MBProgressHUD

class TokenEntryViewController: BaseViewController {

	/// Used for identifying textFields via the UITextField.tag value
	private enum TextFieldTag: Int {
		case tokenEntry = 0
		case verificationEntry = 1
	}

	private let viewModel: TokenEntryViewModel

	var tapGestureRecognizer: UITapGestureRecognizer?

	let sceneView = TokenEntryView()

	init(viewModel: TokenEntryViewModel) {

		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
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
		sceneView.tokenEntryView.inputField.tag = TextFieldTag.tokenEntry.rawValue
		sceneView.verificationEntryView.inputField.delegate = self
		sceneView.verificationEntryView.inputField.tag = TextFieldTag.verificationEntry.rawValue

		// Only show an arrow as back button
		styleBackButton(buttonText: "")
	}

	func setupBinding() {

		viewModel.$token.binding = { [weak self] token in
			self?.sceneView.tokenEntryView.inputField.text = token
			if token == nil {
				self?.sceneView.tokenEntryView.inputField.becomeFirstResponder()
				self?.sceneView.primaryButton.isEnabled = false
			}
		}

		viewModel.$showProgress.binding = { [weak self] in
			guard let strongSelf = self else {
				return
			}

			if $0 {
				let hud = MBProgressHUD.showAdded(to: strongSelf.sceneView, animated: true)
				hud.accessibilityLabel = .loading
				UIAccessibility.post(notification: .screenChanged, argument: hud)
			} else {
				MBProgressHUD.hide(for: strongSelf.sceneView, animated: true)
			}
		}

		viewModel.$errorMessage.binding = { [weak self] in
			if let message = $0 {
				self?.sceneView.errorView.error = message
				self?.sceneView.errorView.isHidden = false
				self?.sceneView.textLabel.isHidden = true
			} else {
				self?.sceneView.errorView.isHidden = true
			}
		}

		viewModel.$showError.binding = { [weak self] in
			if $0 {
				self?.showError(.errorTitle, message: .technicalErrorText)
			}
		}

		viewModel.$showVerification.binding = { [weak self] in

			guard let strongSelf = self else { return }

			let wasHidden = strongSelf.sceneView.verificationEntryView.isHidden

			strongSelf.sceneView.verificationEntryView.isHidden = !$0
			strongSelf.sceneView.secondaryButton.isHidden = !$0
			if strongSelf.sceneView.errorView.isHidden {
				strongSelf.sceneView.textLabel.isHidden = !$0
			}
			if $0 {
				strongSelf.sceneView.verificationEntryView.inputField.becomeFirstResponder()
			}

			if wasHidden && $0 {
				// Only post once
				UIAccessibility.post(notification: .screenChanged, argument: strongSelf.sceneView.verificationEntryView)
			}
		}

		viewModel.$enableNextButton.binding = { [weak self] in self?.sceneView.primaryButton.isEnabled = $0 }

		sceneView.primaryButtonTappedCommand = { [weak self] in

			guard let strongSelf = self else { return }
			strongSelf.viewModel.nextButtonPressed(
				strongSelf.sceneView.tokenEntryView.inputField.text,
				verificationInput: strongSelf.sceneView.verificationEntryView.inputField.text
			)
		}

		viewModel.$secondaryButtonTitle.binding = { [weak self] in

			self?.sceneView.secondaryTitle = $0
		}
		viewModel.$secondaryButtonEnabled.binding = { [weak self] in self?.sceneView.secondaryButton.isEnabled = $0 }
		sceneView.secondaryButtonTappedCommand = { [weak self] in
			guard let strongSelf = self else { return }
			strongSelf.sceneView.verificationEntryView.inputField.text = nil
			strongSelf.viewModel.nextButtonPressed(
				strongSelf.sceneView.tokenEntryView.inputField.text,
				verificationInput: nil
			)
		}
	}

	func setupContent() {

		sceneView.title = .holderTokenEntryTitle
		sceneView.message = .holderTokenEntryText
		sceneView.tokenEntryView.header = .holderTokenEntryTokenTitle
		sceneView.tokenEntryView.inputField.attributedPlaceholder = NSAttributedString(
			string: .holderTokenEntryTokenPlaceholder,
			attributes: [NSAttributedString.Key.foregroundColor: Theme.colors.grey1]
		)
		sceneView.verificationEntryView.header = .holderTokenEntryVerificationTitle
		sceneView.text = .holderTokenEntryVerificationInfo
		sceneView.verificationEntryView.inputField.attributedPlaceholder = NSAttributedString(
			string: .holderTokenEntryVerificationPlaceholder,
			attributes: [NSAttributedString.Key.foregroundColor: Theme.colors.grey1]
		)
		sceneView.primaryTitle = .holderTokenEntryNext
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

		// fix scrolling size (https://developer.apple.com/forums/thread/126841)
		sceneView.scrollView.contentSize = sceneView.stackView.frame.size
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
		let offset: CGFloat = traitCollection.verticalSizeClass == .compact ? 90 : 160
		sceneView.scrollView.contentInset.bottom = notification.getHeight() + offset
		let buttonOffset: CGFloat = UIDevice.current.hasNotch ? 20 : -10
		sceneView.bottomButtonConstraint?.constant = -notification.getHeight() + buttonOffset
	}

	@objc func keyBoardWillHide(notification: Notification) {

		tapGestureRecognizer?.isEnabled = false
		sceneView.scrollView.contentInset.bottom = 0.0
		sceneView.bottomButtonConstraint?.constant = -20
	}
}

// MARK: - UITextFieldDelegate

extension TokenEntryViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		textField.resignFirstResponder()
		return true
	}

	func textField(
		_ textField: UITextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String) -> Bool {

		if let text = textField.text,
		   let textRange = Range(range, in: text) {
			let updatedText = text.replacingCharacters(in: textRange, with: string)

			switch textField.tag {
			case TextFieldTag.tokenEntry.rawValue:
				viewModel.handleInput(updatedText, verificationInput: sceneView.verificationEntryView.inputField.text)

			case TextFieldTag.verificationEntry.rawValue:
				viewModel.handleInput(sceneView.tokenEntryView.inputField.text, verificationInput: updatedText)

			default: break
			}
		}

		return true
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
