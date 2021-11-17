/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

// swiftlint:disable:next type_name
class PaperProofInputCouplingCodeViewController: BaseViewController {
	
	private let viewModel: PaperProofInputCouplingCodeViewModel
	private var tapGestureRecognizer: UITapGestureRecognizer?
	
	let sceneView = PaperProofInputCouplingCodeView()
	
	init(viewModel: PaperProofInputCouplingCodeViewModel) {
		
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

		// Only show an arrow as back button
		addBackButton()
	}
	
	func setupBinding() {
		
		viewModel.$title.binding = { [weak self] title in
			self?.sceneView.title = title
		}
		
		viewModel.$header.binding = { [weak self] header in
			self?.sceneView.header = header
		}
		
		viewModel.$tokenEntryFieldTitle.binding = { [weak self] in
			self?.sceneView.tokenEntryView.header = $0
		}
		
		viewModel.$tokenEntryFieldPlaceholder.binding = { [weak self] in
			self?.sceneView.tokenEntryFieldPlaceholder = $0
		}
		
		viewModel.$nextButtonTitle.binding = { [weak self] in
			self?.sceneView.primaryTitle = $0
		}

		viewModel.$fieldErrorMessage.binding = { [weak self] header in
			if let header = header {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					UIAccessibility.post(notification: .announcement, argument: header)
				}
			}
			self?.sceneView.fieldErrorMessage = header
		}
		
		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.nextButtonTapped()
		}
		
		viewModel.$userNeedsATokenButtonTitle.binding = { [weak self] in
			self?.sceneView.userNeedsATokenButtonTitle = $0
		}

		sceneView.userNeedsATokenButtonTappedCommand = { [weak self] in
			self?.viewModel.userHasNoTokenButtonTapped()
		}

		addBackButton()
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
		view?.endEditing(true)
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
}

// MARK: - UITextFieldDelegate

extension PaperProofInputCouplingCodeViewController: UITextFieldDelegate {

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

		guard let text = textField.text,
			  let textRange = Range(range, in: text)
		else { return false }

		let updatedText = text.replacingCharacters(in: textRange, with: string)

		guard viewModel.validateInput(input: updatedText) else {
			return false
		}

		viewModel.userDidUpdateTokenField(rawTokenInput: updatedText)

		return true
	}
}
