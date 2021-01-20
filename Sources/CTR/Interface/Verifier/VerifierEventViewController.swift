/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierEventViewController: BaseViewController {

	weak var coordinator: VerifierCoordinatorDelegate?

	var tapGestureRecognizer: UITapGestureRecognizer?

	var event: Event?

	let sceneView = EventView()

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

    override func viewDidLoad() {

		super.viewDidLoad()
		setupGestureRecognizer(view: sceneView)

        // Do any additional setup after loading the view.
		title = "Verifier Event"

		sceneView.titleInputView.placeholder = "Titel van het event"
		sceneView.titleInputView.text = event?.title
		sceneView.titleInputView.addTarget(
			self,
			action: #selector(titleDidChange(_:)),
			for: .editingChanged
		)
		sceneView.titleInputView.delegate = self

		sceneView.locationInputView.placeholder = "Locatie van het event"
		sceneView.locationInputView.text = event?.location
		sceneView.locationInputView.addTarget(
			self,
			action: #selector(locationDidChange(_:)),
			for: .editingChanged
		)
		sceneView.locationInputView.delegate = self

		sceneView.timeInputView.placeholder = "Tijd van het event"
		sceneView.timeInputView.text = event?.time
		sceneView.timeInputView.addTarget(
			self,
			action: #selector(timeDidChange(_:)),
			for: .editingChanged
		)
		sceneView.timeInputView.delegate = self

		sceneView.primaryTitle = "Opslaan"
		sceneView.primaryButtonTappedCommand = { [weak self] in

			if let event = self?.event {
				self?.coordinator?.setEvent(event)
			}
			self?.coordinator?.dismiss()
		}
	}

	override func viewWillAppear(_ animated: Bool) {

		subscribeToKeyboardEvents(
			#selector(keyBoardWillShow(notification:)),
			keyboardWillHide: #selector(keyBoardWillHide(notification:))
		)
		super.viewWillAppear(animated)
	}

	override func viewWillDisappear(_ animated: Bool) {

		unSubscribeToKeyboardEvents()
		super.viewWillDisappear(animated)
	}

	@objc func titleDidChange(_ textField: UITextField) {

		event?.title = textField.text ?? ""
	}

	@objc func locationDidChange(_ textField: UITextField) {

		event?.location = textField.text ?? ""
	}

	@objc func timeDidChange(_ textField: UITextField) {

		event?.time = textField.text ?? ""
	}
}

extension VerifierEventViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

extension VerifierEventViewController {

	// MARK: Keyboard

	@objc func keyBoardWillShow(notification: Notification) {

		tapGestureRecognizer?.isEnabled = true
	}

	@objc func keyBoardWillHide(notification: Notification) {

		tapGestureRecognizer?.isEnabled = false
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
}
