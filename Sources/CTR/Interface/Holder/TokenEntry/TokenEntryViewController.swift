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
	private let alertPresenter: (UIAlertController) -> Void
	var tapGestureRecognizer: UITapGestureRecognizer?
	
	let sceneView = TokenEntryView()
	
	init(viewModel: TokenEntryViewModel, alertPresenter: @escaping (UIAlertController) -> Void) {
		
		self.viewModel = viewModel
		self.alertPresenter = alertPresenter

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

		viewModel.$title.binding = { [weak self] title in
			self?.sceneView.title = title
		}
		
		viewModel.$message.binding = { [weak self] message in
			self?.sceneView.message = message
		}
		
		viewModel.$tokenEntryHeaderTitle.binding = { [weak self] in
			self?.sceneView.tokenEntryView.header = $0
		}
		
		viewModel.$tokenEntryPlaceholder.binding = { [weak self] in
			self?.sceneView.tokenEntryFieldPlaceholder = $0
		}
		
		viewModel.$verificationEntryHeaderTitle.binding = { [weak self] in
			self?.sceneView.verificationEntryView.header = $0
		}
		
		viewModel.$verificationInfo.binding = { [weak self] in
			self?.sceneView.text = $0
		}
		
		viewModel.$primaryTitle.binding = { [weak self] in
			self?.sceneView.primaryTitle = $0
		}
		
		viewModel.$verificationPlaceholder.binding = { [weak self] in
			self?.sceneView.verificationEntryFieldPlaceholder = $0
		}
		
		viewModel.$shouldShowProgress.binding = { [weak self] in
			guard let strongSelf = self else { return }
			
			if $0 {
				let hud = MBProgressHUD.showAdded(to: strongSelf.sceneView, animated: true)
				hud.accessibilityLabel = .loading
				UIAccessibility.post(notification: .screenChanged, argument: hud)
			} else {
				MBProgressHUD.hide(for: strongSelf.sceneView, animated: true)
			}
		}
		
		viewModel.$fieldErrorMessage.binding = { [weak self] in
			if let message = $0 {
				self?.sceneView.errorView.error = message
				self?.sceneView.errorView.isHidden = false
				self?.sceneView.textLabel.isHidden = true
			} else {
				self?.sceneView.errorView.isHidden = true
			}
		}
		
		viewModel.$showTechnicalErrorAlert.binding = { [weak self] in
			if $0 {
				self?.showError(.errorTitle, message: .technicalErrorText)
			}
		}
		
		viewModel.$shouldShowTokenEntryField.binding = { [weak self] in
			self?.sceneView.tokenEntryView.isHidden = !$0
		}
		
		viewModel.$shouldShowNextButton.binding = { [weak self] in
			self?.sceneView.primaryButton.isHidden = !$0
		}
		
		viewModel.$shouldShowVerificationEntryField.binding = { [weak self] shouldShowVerificationEntryField in
			guard let strongSelf = self else { return }
			
			let wasHidden = strongSelf.sceneView.verificationEntryView.isHidden
			
			strongSelf.sceneView.verificationEntryView.isHidden = !shouldShowVerificationEntryField
			
			if strongSelf.sceneView.errorView.isHidden {
				strongSelf.sceneView.textLabel.isHidden = !shouldShowVerificationEntryField
			}
			
			if shouldShowVerificationEntryField {
				// Don't want the following code executing during viewDidLoad because it causes
				// a glitch, so let's do it with a slight delay:
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					if !strongSelf.sceneView.verificationEntryView.isHidden {
						strongSelf.sceneView.verificationEntryView.inputField.becomeFirstResponder()
					}
				}
			}
			
			if wasHidden && shouldShowVerificationEntryField {
				// Only post once
				UIAccessibility.post(notification: .screenChanged, argument: strongSelf.sceneView.verificationEntryView)
			}
		}
		
		viewModel.$enableNextButton.binding = { [weak self] in self?.sceneView.primaryButton.isEnabled = $0 }
		
		sceneView.primaryButtonTappedCommand = { [weak self] in
			guard let strongSelf = self else { return }
			
			strongSelf.viewModel.nextButtonTapped(
				strongSelf.sceneView.tokenEntryView.inputField.text,
				verificationInput: strongSelf.sceneView.verificationEntryView.inputField.text
			)
		}
		
		viewModel.$resendVerificationButtonTitle.binding = { [weak self] in
			self?.sceneView.secondaryTitle = $0
		}
		
		viewModel.$resendVerificationButtonEnabled.binding = { [weak self] in
			self?.sceneView.resendVerificationCodeButton.isEnabled = $0
        }

        viewModel.$shouldShowResendVerificationButton.binding = { [weak self] in
            self?.sceneView.resendVerificationCodeButton.isHidden = !$0
		}
		
		sceneView.resendVerificationCodeButtonTappedCommand = { [weak self] in
			self?.displayResendVerificationConfirmationAlert()
		}
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

	// MARK: Alerts

	func displayResendVerificationConfirmationAlert() {
		
		let alertController = UIAlertController(
			title: viewModel.confirmResendVerificationAlertTitle,
			message: viewModel.confirmResendVerificationAlertMessage,
			preferredStyle: .actionSheet
		)
		alertController.addAction(UIAlertAction(
			title: viewModel.confirmResendVerificationAlertOkayButton,
			style: .default) { [weak self] _ in
				guard let self = self else { return }
				self.sceneView.verificationEntryView.inputField.text = nil
				self.viewModel.resendVerificationCodeButtonTapped()
			})
		alertController.addAction(UIAlertAction(
			title: viewModel.confirmResendVerificationAlertCancelButton,
			style: .cancel
		))

		alertPresenter(alertController)
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
					
				default:
					break
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
