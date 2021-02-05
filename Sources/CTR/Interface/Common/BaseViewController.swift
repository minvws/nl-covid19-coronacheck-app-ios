/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class BaseViewController: UIViewController {

	// MARK: Object lifecycle
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
		setup()
	}

	// MARK: Setup
	func setup() {

		// Subclasses should implement this method
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
		styleBackButton()
	}

	func styleBackButton() {

		let backbutton = UIBarButtonItem(
			title: .previous,
			style: .plain,
			target: nil,
			action: nil
		)

		navigationController?.navigationBar.backIndicatorImage = .backArrow
		navigationController?.navigationBar.backIndicatorTransitionMaskImage = .backArrow

		backbutton.setTitleTextAttributes(
			[
				NSAttributedString.Key.font: Theme.fonts.bodyBold,
				NSAttributedString.Key.foregroundColor: Theme.colors.dark
			],
			for: .normal
		)

		navigationItem.backBarButtonItem = backbutton
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
}
