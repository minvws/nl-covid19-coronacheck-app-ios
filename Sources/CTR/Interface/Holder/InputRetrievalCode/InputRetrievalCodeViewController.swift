/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class InputRetrievalCodeViewController: BaseViewController {
	
	/// Used for identifying textFields via the UITextField.tag value
	private enum TextFieldTag: Int {
		case tokenEntry = 0
		case verificationEntry = 1
	}
	
	private let viewModel: InputRetrievalCodeViewModel
	private var tapGestureRecognizer: UITapGestureRecognizer?
	
	let sceneView = InputRetrievalCodeView()
	
	init(viewModel: InputRetrievalCodeViewModel) {
		
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
		
		setupBinding()
		
		setupGestureRecognizer(view: sceneView)
		sceneView.tokenEntryView.inputField.delegate = self
		sceneView.tokenEntryView.inputField.tag = TextFieldTag.tokenEntry.rawValue
		sceneView.verificationEntryView.inputField.delegate = self
		sceneView.verificationEntryView.inputField.tag = TextFieldTag.verificationEntry.rawValue
		
		// Only show an arrow as back button
		addBackButton()
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
			if $0 {
				self?.sceneView.spinner.isHidden = false
				self?.sceneView.spinner.startAnimating()
				UIAccessibility.post(notification: .announcement, argument: L.generalLoading())
			} else {
				self?.sceneView.spinner.stopAnimating()
				self?.sceneView.spinner.isHidden = true
			}
		}
		
		viewModel.$fieldErrorMessage.binding = { [weak self] message in
			self?.sceneView.fieldErrorMessage = message
			if message != nil {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					UIAccessibility.post(notification: .layoutChanged, argument: self?.sceneView.errorView)
				}
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					self?.scrollToBottomIfNotCompletelyVisible()
				}
			}
		}
		
		viewModel.$networkErrorAlert.binding = { [weak self] in
			self?.showAlert($0)
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
		
		viewModel.$shouldEnableNextButton.binding = { [weak self] in self?.sceneView.primaryButton.isEnabled = $0 }
		
		sceneView.primaryButtonTappedCommand = { [weak self] in
			guard let strongSelf = self else { return }
			
			strongSelf.viewModel.nextButtonTapped(
				strongSelf.sceneView.tokenEntryView.inputField.text,
				verificationInput: strongSelf.sceneView.verificationEntryView.inputField.text
			)
		}
		
		viewModel.$resendVerificationButtonTitle.binding = { [weak self] in
			self?.sceneView.resendVerificationCodeButtonTitle = $0
		}

		viewModel.$userNeedsATokenButtonTitle.binding = { [weak self] in
			self?.sceneView.userNeedsATokenButtonTitle = $0
		}

		viewModel.$shouldShowUserNeedsATokenButton.binding = { [weak self] in
			self?.sceneView.userNeedsATokenButton.isHidden = !$0
		}
		
		viewModel.$shouldShowResendVerificationButton.binding = { [weak self] in
			self?.sceneView.resendVerificationCodeButton.isHidden = !$0
		}
		
		sceneView.resendVerificationCodeButtonTappedCommand = { [weak self] in
			self?.displayResendVerificationConfirmationAlert()
		}

		sceneView.userNeedsATokenButtonTappedCommand = { [weak self] in
			self?.viewModel.userHasNoTokenButtonTapped()
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

		let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
		let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
		let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0

		// Create a property animator to manage the animation
		let animator = UIViewPropertyAnimator(
			duration: animationDuration,
			curve: UIView.AnimationCurve(rawValue: animationCurve) ?? .linear
		) {
			let buttonOffset: CGFloat = UIDevice.current.hasNotch ? 20 : -10
			self.sceneView.footerButtonView.bottomButtonConstraint?.constant = -keyboardHeight + buttonOffset

			// Required to trigger NSLayoutConstraint changes
			// to animate
			self.view?.layoutIfNeeded()
		}

		animator.addCompletion { _ in
			self.tapGestureRecognizer?.isEnabled = true
		}

		// Start the animation
		animator.startAnimation()
	}

	@objc func keyBoardWillHide(notification: Notification) {

		tapGestureRecognizer?.isEnabled = false

		let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
		let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0

		// Create a property animator to manage the animation
		let animator = UIViewPropertyAnimator(
			duration: animationDuration,
			curve: UIView.AnimationCurve(rawValue: animationCurve) ?? .linear
		) {
			self.sceneView.footerButtonView.bottomButtonConstraint?.constant = -20

			self.view?.layoutIfNeeded()
		}

		// Start the animation
		animator.startAnimation()
	}
	
	private func scrollToBottomIfNotCompletelyVisible() {

		let scrollView = sceneView.scrollView

		// Only scroll when content is scrollable
		guard scrollView.contentSize.height > scrollView.bounds.height else { return }
		
		// https://stackoverflow.com/a/952768/443270
		let bottomOffset = CGPoint(
			x: 0,
			y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom
		)
		scrollView.setContentOffset(bottomOffset, animated: true)
	}
	
	// MARK: Alerts
	
	func displayResendVerificationConfirmationAlert() {

		guard let title = viewModel.confirmResendVerificationAlertTitle,
			  let subTitle = viewModel.confirmResendVerificationAlertMessage,
			  let okTitle = viewModel.confirmResendVerificationAlertOkayButton else {
			return
		}

		let alert = AlertContent(
			title: title,
			subTitle: subTitle,
			cancelAction: nil,
			cancelTitle: viewModel.confirmResendVerificationAlertCancelButton,
			okAction: { [weak self] _ in
				guard let self = self else { return }
				self.sceneView.verificationEntryView.inputField.text = nil
				self.viewModel.resendVerificationCodeButtonTapped()
			},
			okTitle: okTitle,
			okActionIsPreferred: true
		)

		showAlert(alert)
	}
}

// MARK: - UITextFieldDelegate

extension InputRetrievalCodeViewController: UITextFieldDelegate {

	func textFieldDidBeginEditing(_ textField: UITextField) {

		// Wait until after the keyboard has presented, then do some frame calculations:
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in

			// Standardise the frames of textField & the gradient line (above the Primary button) inside the frame of self.view:
			let textfieldFrame = view.convert(textField.frame, from: textField.superview)
			let gradientLineFrame = view.convert(sceneView.footerButtonView.gradientView.frame, from: sceneView.footerButtonView.gradientView.superview)

			if textfieldFrame.maxY > gradientLineFrame.minY {
				let correction = textfieldFrame.maxY - gradientLineFrame.minY

				// Okay so shift the scrollView up by the correction:
				UIView.animate(withDuration: 0.2) {
					sceneView.scrollView.contentOffset.y += correction
				}
			}
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		textField.resignFirstResponder()

		if sceneView.primaryButton.isEnabled {
			// Simulate a tap on the next button:
			sceneView.primaryButton.sendActions(for: .touchUpInside)
		}

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
					viewModel.userDidUpdateTokenField(rawTokenInput: updatedText, currentValueOfVerificationInput: sceneView.verificationEntryView.inputField.text)
					
				case TextFieldTag.verificationEntry.rawValue:
					viewModel.userDidUpdateVerificationField(rawVerificationInput: updatedText, currentValueOfTokenInput: sceneView.tokenEntryView.inputField.text)
					
				default:
					break
			}
		}
		
		return true
	}
}