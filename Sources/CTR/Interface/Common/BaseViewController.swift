/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class BaseViewController: UIViewController {
	
	/// Disable navigation back swiping. Disable in -viewDidAppear.
	var enableSwipeBack: Bool = true {
		didSet {
			navigationController?.interactivePopGestureRecognizer?.delegate = enableSwipeBack ? self : nil
			navigationController?.interactivePopGestureRecognizer?.isEnabled = enableSwipeBack
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
	}

	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		setupAccessibilityElements()
		
		enableSwipeBack = true
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
	///   - action: The action when the users taps the close button
	///   - tintColor: The button tint color
	func addCloseButton(
		action: Selector,
		tintColor: UIColor = Theme.colors.dark) {
		
		let button = createBarButton(action: action,
									 image: I.cross(),
									 tintColor: tintColor,
									 accessibilityIdentifier: "CloseButton",
									 accessibilityLabel: L.generalClose())
		navigationItem.leftBarButtonItem = button
	}

	/// Add a back button to the navigation bar.
	/// - Parameters:
	///   - customAction: The custom action for back navigation
	func addBackButton(
		customAction: Selector? = nil) {

		var action = #selector(onBack)
		if let customAction = customAction {
			action = customAction
		}
		
		let button = createBarButton(action: action,
									 image: I.backArrow(),
									 accessibilityIdentifier: "BackButton",
									 accessibilityLabel: L.generalBack())
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
