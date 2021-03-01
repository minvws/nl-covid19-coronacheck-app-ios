/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class BirthdateEntryViewModel: Logging {

	var loggingCategory: String = "BirthdateEntryViewModel"

	/// Coordination Delegate
	weak var coordinator: (BirthdateCoordinatorDelegate & Dismissable)?

	/// The title of the button
	@Bindable private(set) var isButtonEnabled: Bool = false

	/// The error message
	@Bindable private(set) var errorMessage: String?

	/// DescriptionInitializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	init(
		coordinator: (BirthdateCoordinatorDelegate & Dismissable)
	) {
		self.coordinator = coordinator
	}

	func sendButtonTapped() {
		
		guard let year = year, let month = month, let day = day,
			  !year.isEmpty, !month.isEmpty, !day.isEmpty else {
			isButtonEnabled = false
			return
		}

		let dateString = "\(year)-\(month)-\(day)"

		if let date = parseDateFormatter.date(from: dateString) {
			logDebug("Birthdate : \(date)")
			errorMessage = "\(date)"
			coordinator?.navigateToBirthdayConfirmation(date)
		} else {
			errorMessage = .holderBirthdayEntryInvaliddDate
		}
	}

	var day: String?
	var month: String?
	var year: String?

	func setDay(_ input: String?) {

		day = input
		setButtonState()
	}

	func setMonth(_ input: String?) {
		month = input
		setButtonState()
	}

	func setYear(_ input: String?) {
		year = input
		setButtonState()
	}

	func setButtonState() {
		guard let year = year, let month = month, let day = day,
			  !year.isEmpty, !month.isEmpty, !day.isEmpty else {
			isButtonEnabled = false
			return
		}
		isButtonEnabled = true
	}

	private lazy var parseDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.calendar = .current
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		dateFormatter.dateFormat = "yyyy-M-d"
		return dateFormatter
	}()

	func dismiss() {

		coordinator?.dismiss()
	}
}

class BirthdateEntryViewController: BaseViewController {

	private let viewModel: BirthdateEntryViewModel

	var tapGestureRecognizer: UITapGestureRecognizer?

	let sceneView = BirthdateEntryView()

	init(viewModel: BirthdateEntryViewModel) {

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
		setupEntryViews()

		// Bindings

		viewModel.$errorMessage.binding = {
			if let message = $0 {
				self.sceneView.errorView.error = message
				self.sceneView.errorView.isHidden = false
			} else {
				self.sceneView.errorView.isHidden = true
			}
		}

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.sendButtonTapped()
		}

		viewModel.$isButtonEnabled.binding = { self.sceneView.primaryButton.isEnabled = $0 }

		// Only show an arrow as back button
		styleBackButton(buttonText: "")

		addCloseButton(action: #selector(closeButtonTapped), accessibilityLabel: .close)
	}

	@objc func closeButtonTapped() {

		viewModel.dismiss()
	}

	/// Setup all the content
	func setupContent() {

		sceneView.title = .holderBirthdayEntryTitle
		sceneView.message = .holderBirthdayEntryText
		sceneView.primaryTitle = .holderBirthdayEntryButtonTitle
		sceneView.primaryButton.isEnabled = false
		sceneView.dayTitle = .holderBirthdayEntryDay
		sceneView.dayEntryView.inputField.placeholder = "01"
		sceneView.monthTitle = .holderBirthdayEntryMonth
		sceneView.monthEntryView.inputField.placeholder = "01"
		sceneView.yearTitle = .holderBirthdayEntryYear
		sceneView.yearEntryView.inputField.placeholder = "1990"
	}

	/// Setup the entry views
	func setupEntryViews() {

		setupGestureRecognizer(view: sceneView)
		sceneView.dayEntryView.inputField.delegate = self
		sceneView.dayEntryView.inputField.addTarget(
			self,
			action: #selector(textFieldDidChange(_:)),
			for: .editingChanged
		)
		sceneView.dayEntryView.inputField.tag = 0
		sceneView.monthEntryView.inputField.delegate = self
		sceneView.monthEntryView.inputField.addTarget(
			self,
			action: #selector(textFieldDidChange(_:)),
			for: .editingChanged
		)
		sceneView.monthEntryView.inputField.tag = 1
		sceneView.yearEntryView.inputField.delegate = self
		sceneView.yearEntryView.inputField.addTarget(
			self,
			action: #selector(textFieldDidChange(_:)),
			for: .editingChanged
		)
		sceneView.yearEntryView.inputField.tag = 2
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
		sceneView.scrollView.contentInset.bottom = notification.getHeight()
	}

	@objc func keyBoardWillHide(notification: Notification) {

		tapGestureRecognizer?.isEnabled = false
		sceneView.scrollView.contentInset.bottom = 0.0
	}
}

// MARK: - UITextFieldDelegate

extension BirthdateEntryViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		if textField.tag == 0 {
			sceneView.monthEntryView.inputField.becomeFirstResponder()
		} else if textField.tag == 1 {
			sceneView.yearEntryView.inputField.becomeFirstResponder()
		} else {
			textField.resignFirstResponder()
		}
		return true
	}

	@objc func textFieldDidChange(_ textField: UITextField) {

		if textField.tag == 0 {
			viewModel.setDay(textField.text)
		} else if textField.tag == 1 {
			viewModel.setMonth(textField.text)
		} else {
			viewModel.setYear(textField.text)
		}
	}
}
