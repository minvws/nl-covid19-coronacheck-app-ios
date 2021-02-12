/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class EntryView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0
		static let headerMargin: CGFloat = 10.0
	}

	/// The header label
	let headerLabel: Label = {

		return Label(caption1: nil)
	}()

	let inputField: UITextField = {

		let field = UITextField()
		field.translatesAutoresizingMaskIntoConstraints = false
		field.returnKeyType = .send
		field.autocorrectionType = .no
		field.autocapitalizationType = .none
		return field
	}()

	let lineView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.line
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(headerLabel)
		addSubview(inputField)
		addSubview(lineView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Header
			headerLabel.topAnchor.constraint(equalTo: topAnchor),
			headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			headerLabel.bottomAnchor.constraint(
				equalTo: inputField.topAnchor,
				constant: -ViewTraits.headerMargin
			),

			inputField.leadingAnchor.constraint(equalTo: leadingAnchor),
			inputField.trailingAnchor.constraint(equalTo: trailingAnchor),
			inputField.bottomAnchor.constraint(equalTo: lineView.topAnchor),

			// Line
			lineView.heightAnchor.constraint(equalToConstant: 1),
			lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
			lineView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
}

class TokenEntryView: ScrollView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let buttonWidth: CGFloat = 212.0
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22

		// Margins
		static let margin: CGFloat = 20.0
		static let buttonMargin: CGFloat = 54.0
		static let titleTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 34.0
		static let messageTopMargin: CGFloat = 24.0
		static let entryMargin: CGFloat = 16.0
	}

	/// The title label
	let titleLabel: Label = {

		return Label(title1: nil).multiline()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	let tokenView: EntryView = {

		let view = EntryView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let verificationView: EntryView = {

		let view = EntryView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		contentView.addSubview(titleLabel)
		contentView.addSubview(messageLabel)
		contentView.addSubview(tokenView)
		contentView.addSubview(verificationView)

	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.titleTopMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.messageTopMargin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),

			tokenView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			tokenView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			tokenView.topAnchor.constraint(
				equalTo: messageLabel.bottomAnchor,
				constant: ViewTraits.margin
			),

			verificationView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			verificationView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			verificationView.topAnchor.constraint(
				equalTo: tokenView.bottomAnchor,
				constant: ViewTraits.entryMargin
			)
		])
	}

	// MARK: Public Access

	/// The onboarding title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}

	/// The onboarding message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
		}
	}
}

class TokenEntryViewModel: Logging {

	var loggingCategory: String = "TokenEntryViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	/// The proof manager
	weak var proofManager: ProofManaging?

	/// The request token
	var requestToken: RequestToken?

	/// The verification code
	var verificationCode: String?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var tokenTitle: String
	@Bindable private(set) var tokenPlaceholder: String
	@Bindable private(set) var verificationCodeTitle: String
	@Bindable private(set) var verificationCodePlaceholder: String
	@Bindable private(set) var showProgress: Bool = false
	@Bindable private(set) var showVerification: Bool = false
	@Bindable private(set) var errorMessage: String?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	init(
		coordinator: HolderCoordinatorDelegate,
		proofManager: ProofManaging) {

		self.coordinator = coordinator
		self.proofManager = proofManager

		title = .holderTokenEntryTitle
		message = .holderTokenEntryText
		tokenTitle = .holderTokenEntryTokenTitle
		tokenPlaceholder = .holderTokenEntryTokenPlaceholder
		verificationCodeTitle = .holderTokenEntryVerificationTitle
		verificationCodePlaceholder = .holderTokenEntryVerificationPlaceholder
	}

	func checkToken(_ text: String?) {

		if let input = text, !input.isEmpty {
			if let requestToken = createRequestToken(input) {
				self.requestToken = requestToken
				fetchResult(requestToken)
			} else {
				errorMessage = .holderTokenEntryErrorInvalidCode
			}
		}
	}

	func checkVerification(_ text: String?) {

		if let input = text, !input.isEmpty {
			verificationCode = text
			if let token = requestToken {
				fetchResult(token)
			}
		}
	}

	/// Fetch a test result
	/// - Parameter requestToken: the request token
	private func fetchResult(_ requestToken: RequestToken) {

		guard let provider = proofManager?.getTestProvider(requestToken) else {
			errorMessage = .holderTokenEntryErrorInvalidProvider
			return
		}

		showProgress = true
		proofManager?.fetchTestResult(
			requestToken,
			code: verificationCode,
			provider: provider) {  [weak self] response in

			self?.showProgress = false

			switch response {
				case let .success(wrapper):
					switch wrapper.status {
						case .complete, .pending:
							self?.coordinator?.navigateToListResults()
						case .verificationRequired:
							self?.showVerification = true
						case .invalid:
							self?.errorMessage = .holderTokenEntryErrorInvalidCode
						default:
							self?.logDebug("Unhandled test result status: \(wrapper.status)")
							self?.errorMessage = "Unhandled: \(wrapper.status)"
					}
				case let .failure(error):

					if let castedError = error as? ProofError, castedError == .invalidUrl {
						self?.errorMessage = .holderTokenEntryErrorInvalidProvider
					} else {
					// For now, display the network error.
					self?.errorMessage = error.localizedDescription
					}
			}
		}
	}

	/// Create a request token from a string
	/// - Parameter token: the input string
	/// - Returns: the request token
	func createRequestToken(_ input: String) -> RequestToken? {

		let parts = input.split(separator: "-")
		if parts.count >= 2 {
			if parts[0].count == 3 {
				let identifierPart = String(parts[0])
				let tokenPart = String(parts[1])
				return RequestToken(
					token: tokenPart,
					protocolVersion: "1.0",
					providerIdentifier: identifierPart
				)
			}
		}
		return nil
	}
}

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

		viewModel.$title.binding = { self.sceneView.title = $0 }
		viewModel.$message.binding = { self.sceneView.message = $0 }
		viewModel.$tokenTitle.binding = { self.sceneView.tokenView.headerLabel.text = $0 }
		viewModel.$tokenPlaceholder.binding = { self.sceneView.tokenView.inputField.placeholder = $0 }
		viewModel.$verificationCodeTitle.binding = { self.sceneView.verificationView.headerLabel.text = $0 }
		viewModel.$verificationCodePlaceholder.binding = { self.sceneView.verificationView.inputField.placeholder = $0 }

		viewModel.$showProgress.binding = {
			if $0 {
				MBProgressHUD.showAdded(to: self.sceneView, animated: true)
			} else {
				MBProgressHUD.hide(for: self.sceneView, animated: true)
			}
		}

		viewModel.$errorMessage.binding = {
			if let message = $0 {
				self.showAlert(message)
			}
		}

		viewModel.$showVerification.binding = {
			self.sceneView.verificationView.isHidden = !$0
			if $0 {
				self.sceneView.verificationView.inputField.becomeFirstResponder()
			}
		}

		setupGestureRecognizer(view: sceneView)
		sceneView.tokenView.inputField.delegate = self
		sceneView.tokenView.inputField.tag = 0
		sceneView.verificationView.inputField.delegate = self
		sceneView.verificationView.inputField.tag = 1
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
		sceneView.tokenView.inputField.becomeFirstResponder()
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
		sceneView.scrollView.contentInset.bottom = notification.getHeight()
	}

	@objc func keyBoardWillHide(notification: Notification) {

		tapGestureRecognizer?.isEnabled = false
		sceneView.scrollView.contentInset.bottom = 0.0
	}

	/// Show alert
	private func showAlert(_ message: String) {

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
