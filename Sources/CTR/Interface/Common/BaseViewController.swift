/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class BaseViewController: UIViewController {
	
	var disableSwipeBack: Bool = false {
		didSet {
			navigationController?.interactivePopGestureRecognizer?.delegate = disableSwipeBack ? nil : self
			navigationController?.interactivePopGestureRecognizer?.isEnabled = !disableSwipeBack
		}
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {

		if #available(iOS 13.0, *) {
			return .darkContent
		} else {
			return super.preferredStatusBarStyle
		}
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		if #available(iOS 13.0, *) {
			// Always adopt a light interface style.
			overrideUserInterfaceStyle = .light
		}
		
		disableSwipeBack = false
	}

	func styleBackButton() {
		addCustomBackButton(action: #selector(onBack), accessibilityLabel: L.generalBack())
	}

	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		setupAccessibilityElements()
	}

	func setupAccessibilityElements() {

		// Fix for Accessibility on older devices.
		// Explicitly set the content.
		if let navBar = navigationController?.navigationBar {
			accessibilityElements = [navBar, view as Any]
		}
	}

	/// Announce a message
	/// - Parameter message: the message to announce
	func announce(_ message: String?) {

		guard let message = message else {
			return
		}

		UIAccessibility.post(
			notification: .announcement,
			argument: message
		)
	}

	/// Add a close button to the navigation bar.
	/// - Parameters:
	///   - action: the action when the users taps the close button
	///   - accessibilityLabel: the label for Voice Over
	func addCloseButton(
		action: Selector?,
		accessibilityLabel: String = L.generalClose(),
		backgroundColor: UIColor = Theme.colors.viewControllerBackground,
		tintColor: UIColor = Theme.colors.dark) {

		let button = UIBarButtonItem(
			image: .cross,
			style: .plain,
			target: self,
			action: action
		)
        button.title = accessibilityLabel
        button.accessibilityLabel = accessibilityLabel
		button.accessibilityIdentifier = "CloseButton"
		button.accessibilityTraits = .button
		button.tintColor = tintColor
		button.imageInsets = .left(5)
		navigationItem.hidesBackButton = true
		navigationItem.leftBarButtonItem = button
	}

	/// Add a close button to the navigation bar.
	/// - Parameters:
	///   - action: the action when the users taps the close button
	///   - accessibilityLabel: the label for Voice Over
	func addCustomBackButton(
		action: Selector,
		accessibilityLabel: String) {

		let button = createBarButton(for: action, image: .backArrow)
		button.accessibilityIdentifier = "BackButton"
		button.accessibilityLabel = accessibilityLabel
		navigationItem.hidesBackButton = true
		navigationItem.leftBarButtonItem = button
	}

	/// Show alert
	func showError(_ title: String = L.generalErrorTitle(), message: String) {

		let alertController = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)
		alertController.addAction(
			UIAlertAction(
				title: L.generalOk(),
				style: .default,
				handler: nil
			)
		)
		present(alertController, animated: true, completion: nil)
	}
}

private extension BaseViewController {
	
	@objc func onBack() {
		navigationController?.popViewController(animated: true)
	}
}

extension BaseViewController: UIGestureRecognizerDelegate {

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}
