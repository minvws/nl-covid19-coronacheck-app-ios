/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UIBarButtonItem {
	
	struct Configuration {
		let target: Any?
		let action: Selector
		var image: UIImage?
		var text: String?
		var tintColor: UIColor?
		let accessibilityIdentifier: String
		let accessibilityLabel: String
	}
	
	/// Bar button create method with updated size and margins.
	/// - Parameter config:
	///   - target: The target object—that is, the object whose action method is called.
	///   - action: A selector identifying the action method to be called.
	///   - image: The button image.
	///   - tintColor: The button tint color.
	///   - accessibilityIdentifier: A string that identifies the button.
	///   - accessibilityLabel: The localized label for Voice Over.
	/// - Returns: UIBarButtonItem. Should be set on as left or right navigation item.
	static func create(_ config: Configuration) -> UIBarButtonItem {

		let button: UIBarButtonItem

		if let text = config.text {
			button = UIBarButtonItem(
				title: text,
				style: .plain,
				target: config.target,
				action: config.action)
		} else {
			button = UIBarButtonItem(
				image: config.image,
				style: .plain,
				target: config.target,
				action: config.action)
			button.imageInsets = .leftRight(4)
		}
		button.tintColor = config.tintColor
		button.accessibilityTraits = .button
		button.accessibilityIdentifier = config.accessibilityIdentifier
		button.accessibilityLabel = config.accessibilityLabel
		return button
	}
}
