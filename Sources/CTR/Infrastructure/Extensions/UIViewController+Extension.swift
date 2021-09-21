/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UIViewController {
	
	/// Set up translucent navigation bar. By default, navigation bar has an opaque background
	func setupTranslucentNavigationBar() {
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.navigationBar.backgroundColor = .clear
		navigationController?.navigationBar.barTintColor = .clear
	}
	
	/// Bar button with updated size and margins
	/// - Parameters:
	///   - target: The target object—that is, the object whose action method is called
	///   - action: A selector identifying the action method to be called.
	///   - image: The button image
	///   - tintColor: The button tint color
	///   - accessibilityIdentifier: A string that identifies the button
	///   - accessibilityLabel: The localized label for VoiceOver
	/// - Returns: UIBarButtonItem. Should be set on as left or right navigation item.
	func createBarButton(
		target: Any? = nil,
		action: Selector,
		image: UIImage?,
		tintColor: UIColor? = nil,
		accessibilityIdentifier: String,
		accessibilityLabel: String) -> UIBarButtonItem {
		
		let button = UIButton(type: .custom)
		button.setImage(image, for: .normal)
		button.tintColor = tintColor
		button.accessibilityTraits = .button
		button.addTarget(target ?? self, action: action, for: .touchUpInside)
		button.contentEdgeInsets = .leftRight(4)
		button.accessibilityIdentifier = accessibilityIdentifier
		button.accessibilityLabel = accessibilityLabel
		return UIBarButtonItem(customView: button)
	}
}
