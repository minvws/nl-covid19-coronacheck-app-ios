/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class BaseViewController: UIViewController {
	
	/// Enable/disable navigation back swiping. Default is true.
	var enableSwipeBack: Bool { true }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {

		if #available(iOS 13.0, *) {
			return .darkContent
		} else {
			return super.preferredStatusBarStyle
		}
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .all
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
		
		navigationController?.interactivePopGestureRecognizer?.delegate = enableSwipeBack ? self : nil
		navigationController?.interactivePopGestureRecognizer?.isEnabled = enableSwipeBack
	}

	// MARK: - Accessibility
	
	// If the user is has VoiceOver enabled, they can
	// draw a "Z" shape with two fingers to trigger a navigation pop.
	// http://ronnqvi.st/adding-accessible-behavior
	@objc override func accessibilityPerformEscape() -> Bool {
		if enableSwipeBack {
			onBack()
			return true
		} else if let leftButtonTarget = navigationItem.leftBarButtonItem?.target,
				  let leftButtonAction = navigationItem.leftBarButtonItem?.action {
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
		tintColor: UIColor = C.black()!) {
		
		let config = UIBarButtonItem.Configuration(target: self,
												   action: action,
												   content: .image(I.cross()),
												   tintColor: tintColor,
												   accessibilityIdentifier: "CloseButton",
												   accessibilityLabel: L.generalClose())
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
			accessibilityLabel: L.generalBack()
		)
		navigationItem.leftBarButtonItem = .create(config)
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
