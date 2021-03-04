/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class BirthdateEntryViewController: BaseViewController {

	private let viewModel: BirthdateEntryViewModel

	var tapGestureRecognizer: UITapGestureRecognizer?

	let sceneView = BirthdateEntryView()

	/// The month picker
	let pickerView: UIPickerView = {

		let picker = UIPickerView()
		picker.backgroundColor = Theme.colors.viewControllerBackground
		return picker
	}()

	/// The months for the picker
	let months: [String] = [.january, .february, .march, .april, .may, .june,
							.july, .august, .september, .october, .november, .december]

	var activeInputField: UITextField?

	// MARK: Initializer

	/// The initalizer
	/// - Parameter viewModel: the view model
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

		viewModel.$errorMessage.binding = { [weak self] in
			if let message = $0 {
				self?.sceneView.errorView.error = message
				self?.sceneView.errorView.isHidden = false
			} else {
				self?.sceneView.errorView.isHidden = true
			}
		}

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.sendButtonTapped()
		}

		viewModel.$isButtonEnabled.binding = { [weak self] in self?.sceneView.primaryButton.isEnabled = $0 }

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
		sceneView.monthEntryView.inputField.placeholder = "januari"
		sceneView.yearTitle = .holderBirthdayEntryYear
		sceneView.yearEntryView.inputField.placeholder = "1990"
	}

	/// Setup the entry views
	func setupEntryViews() {

		let toolbar = UIToolbar.generateMonthPickerToolbar(
			previousSelector: #selector(pickerPreviousAction),
			nextSelector: #selector(pickerNextAction),
			doneSelector: #selector(pickerDoneAction)
		)

		setupGestureRecognizer(view: sceneView)
		sceneView.dayEntryView.inputField.delegate = self
		sceneView.dayEntryView.inputField.addTarget(
			self,
			action: #selector(textFieldDidChange(_:)),
			for: .editingChanged
		)
		sceneView.dayEntryView.inputField.tag = 0
		sceneView.dayEntryView.inputField.inputAccessoryView = toolbar

		sceneView.monthEntryView.inputField.inputView = pickerView
		sceneView.monthEntryView.inputField.inputAccessoryView = toolbar
		pickerView.delegate = self
		pickerView.dataSource = self
		sceneView.monthEntryView.inputField.tag = 1

		sceneView.monthEntryView.inputField.tag = 1
		sceneView.yearEntryView.inputField.delegate = self
		sceneView.yearEntryView.inputField.addTarget(
			self,
			action: #selector(textFieldDidChange(_:)),
			for: .editingChanged
		)
		sceneView.yearEntryView.inputField.tag = 2
		sceneView.yearEntryView.inputField.inputAccessoryView = toolbar
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

		if !UIDevice.current.isSmallScreen {
			// On an iPhone SE do not auto show the keyboard, the title will scroll out of view.
			sceneView.dayEntryView.inputField.becomeFirstResponder()
		}
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

		autoSelectFirstMonth()
	}

	// MARK: Keyboard

	@objc func keyBoardWillShow(notification: Notification) {

		tapGestureRecognizer?.isEnabled = true
		sceneView.scrollView.contentInset.bottom = notification.getHeight() + 20 // 20: Also show the error view.
	}

	@objc func keyBoardWillHide(notification: Notification) {

		tapGestureRecognizer?.isEnabled = false
		sceneView.scrollView.contentInset.bottom = 0.0
	}
}

// MARK: - UITextFieldDelegate

extension BirthdateEntryViewController: UITextFieldDelegate {

	/// UITextFieldDelegate method
	/// - Parameter textField: the textfield that did begin editing.
	func textFieldDidBeginEditing(_ textField: UITextField) {
		// Hide the error
		self.sceneView.errorView.isHidden = true
		if textField.tag == 0 {
			activeInputField = sceneView.dayEntryView.inputField
		} else if textField.tag == 1 {
			activeInputField = sceneView.monthEntryView.inputField
		} else {
			activeInputField = sceneView.yearEntryView.inputField
		}
	}

	/// UITextFieldDelegate method
	/// - Parameter textField: the textfield that did change
	@objc func textFieldDidChange(_ textField: UITextField) {

		if textField.tag == 0 {
			activeInputField = sceneView.dayEntryView.inputField
			viewModel.setDay(textField.text)
		} else if textField.tag == 1 {
			activeInputField = sceneView.monthEntryView.inputField
			viewModel.setMonth(textField.text)
		} else {
			activeInputField = sceneView.yearEntryView.inputField
			viewModel.setYear(textField.text)
		}
	}

	/// UITextFieldDelegate method
	/// - Parameters:
	///   - textField: the textfield being editied
	///   - range: the range of edited text
	///   - string: the new text for the edited range
	/// - Returns: True if we should replace the characters in the range with the new text
	func textField(
		_ textField: UITextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String) -> Bool {

		guard let textFieldText = textField.text,
			  let rangeOfTextToReplace = Range(range, in: textFieldText) else {
			return false
		}
		let substringToReplace = textFieldText[rangeOfTextToReplace]
		let count = textFieldText.count - substringToReplace.count + string.count

		if textField.tag == 0 {
			return count <= 2
		}
		if textField.tag == 2 {
			return count <= 4
		}
		return true
	}
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension BirthdateEntryViewController: UIPickerViewDataSource, UIPickerViewDelegate {

	/// UIPickerViewDataSource method
	/// - Parameter pickerView: the picker view
	/// - Returns: Number of components
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		1
	}

	/// UIPickerViewDataSource method
	/// - Parameters:
	///   - pickerView: the picker view
	///   - component: the component
	/// - Returns: number of rows in components
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

		months.count
	}

	/// UIPickerViewDelegate method
	/// - Parameters:
	///   - pickerView: the picker view
	///   - row: the row
	///   - component: the component
	/// - Returns: the tirle for the row in component
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

		activeInputField = sceneView.monthEntryView.inputField
		return months[row]
	}

	/// UIPickerViewDelegate method
	/// - Parameters:
	///   - pickerView: the picker view
	///   - row: the row
	///   - component: the component
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

		sceneView.monthEntryView.inputField.text = months[row].lowercased()
		viewModel.setMonth("\(row + 1)")
	}

	/// User tapped on the previous button
	@objc func pickerPreviousAction() {

		autoSelectFirstMonth()

		if activeInputField == sceneView.dayEntryView.inputField {
			sceneView.yearEntryView.inputField.becomeFirstResponder()
			activeInputField = sceneView.yearEntryView.inputField
		} else if activeInputField == sceneView.monthEntryView.inputField {
			sceneView.dayEntryView.inputField.becomeFirstResponder()
			activeInputField = sceneView.dayEntryView.inputField
		} else if activeInputField == sceneView.yearEntryView.inputField {
			sceneView.monthEntryView.inputField.becomeFirstResponder()
			activeInputField = sceneView.monthEntryView.inputField
		}
	}

	/// User tapped on the next button
	@objc func pickerNextAction() {

		autoSelectFirstMonth()

		if activeInputField == sceneView.dayEntryView.inputField {
			sceneView.monthEntryView.inputField.becomeFirstResponder()
			activeInputField = sceneView.monthEntryView.inputField
		} else if activeInputField == sceneView.monthEntryView.inputField {
			sceneView.yearEntryView.inputField.becomeFirstResponder()
			activeInputField = sceneView.yearEntryView.inputField
		} else if activeInputField == sceneView.yearEntryView.inputField {
			sceneView.dayEntryView.inputField.becomeFirstResponder()
			activeInputField = sceneView.dayEntryView.inputField
		}
	}

	/// User tapped on the done button
	@objc func pickerDoneAction(_ pickerView: UIPickerView) {

		autoSelectFirstMonth()

		activeInputField?.resignFirstResponder()
		activeInputField = nil
	}

	func autoSelectFirstMonth() {

		guard activeInputField == sceneView.monthEntryView.inputField else {
			return
		}

		if pickerView.selectedRow(inComponent: 0) == 0 {
			sceneView.monthEntryView.inputField.text = months[0].lowercased()
			viewModel.setMonth("1")
		}
	}
}
