/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class BaseViewController: UIViewController {
	
	/// Enable/disable navigation back swiping. Default is true.
	var enableSwipeBack: Bool { true }

	// Retain the config used to create the left bar button (either a close or back button)
	// because it is used by `accessibilityPerformEscape()`.
	private var cacheLeftButtonConfig: UIBarButtonItem.Configuration?
	
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
		
		// Hide standard back button for customized left / back button.
		navigationItem.hidesBackButton = true
	}

	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		setupAccessibilityElements()
		
		navigationController?.interactivePopGestureRecognizer?.delegate = enableSwipeBack ? self : nil
		navigationController?.interactivePopGestureRecognizer?.isEnabled = enableSwipeBack
	}

	// MARK: - Accessibility

	func setupAccessibilityElements() {

		// Fix for Accessibility on older devices.
		// Explicitly set the content.
		if let navBar = navigationController?.navigationBar {
			accessibilityElements = [navBar, view as Any]
		}
	}
	
	// If the user is has VoiceOver enabled, they can
	// draw a "Z" shape with two fingers to trigger a navigation pop.
	// http://ronnqvi.st/adding-accessible-behavior
	@objc override func accessibilityPerformEscape() -> Bool {
		if enableSwipeBack {
			onBack()
			return true
		} else if let leftButtonTarget = cacheLeftButtonConfig?.target,
				let leftButtonAction = cacheLeftButtonConfig?.action {
			UIApplication.shared.sendAction(leftButtonAction, to: leftButtonTarget, from: nil, for: nil)
			return true
		}
		
		return false
	}

	/// Add a close button to the navigation bar.
	/// - Parameters:
	///   - action: The action when the users taps the close button
	///   - tintColor: The button tint color
	func addCloseButton(
		action: Selector,
		tintColor: UIColor = Theme.colors.dark) {
		
		let config = UIBarButtonItem.Configuration(target: self,
												   action: action,
												   content: .image(I.cross()),
												   tintColor: tintColor,
												   accessibilityIdentifier: "CloseButton",
												   accessibilityLabel: L.generalClose())
		cacheLeftButtonConfig = config
		navigationItem.leftBarButtonItem = .create(config)
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
		
		let config = UIBarButtonItem.Configuration(
			target: self,
			action: action,
			content: .image(I.backArrow()),
			accessibilityIdentifier: "BackButton",
			accessibilityLabel: L.generalMenuClose()
		)
		cacheLeftButtonConfig = config
		navigationItem.leftBarButtonItem = .create(config)
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
