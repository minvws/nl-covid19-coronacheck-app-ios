/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

public extension UIBarButtonItem {
	
	struct Configuration {
		public let target: Any?
		public let action: Selector
		public let content: Content
		public var tintColor: UIColor?
		public let accessibilityIdentifier: String
		public let accessibilityLabel: String
		
		public init (
			target: Any?,
			action: Selector,
			content: Content,
			tintColor: UIColor? = nil,
			accessibilityIdentifier: String,
			accessibilityLabel: String
		) {
			self.target = target
			self.action = action
			self.content = content
			self.tintColor = tintColor
			self.accessibilityIdentifier = accessibilityIdentifier
			self.accessibilityLabel = accessibilityLabel
		}
	}

	enum Content {
		case image(UIImage?)
		case text(String)
	}
	
	/// Bar button create method with updated size and margins.
	/// - Parameter config:
	///   - target: The target object—that is, the object whose action method is called.
	///   - action: A selector identifying the action method to be called.
	///   - content: The content (image or text)
	///   - tintColor: The button tint color.
	///   - accessibilityIdentifier: A string that identifies the button.
	///   - accessibilityLabel: The localized label for Voice Over.
	/// - Returns: UIBarButtonItem. Should be set on as left or right navigation item.
	static func create(_ config: Configuration) -> UIBarButtonItem {

		let button: UIBarButtonItem

		switch config.content {
			case let .image(image):
				button = UIBarButtonItem(
					image: image,
					style: .plain,
					target: config.target,
					action: config.action
				)
				button.imageInsets = .leftRight(4)
			case let .text(text):
				button = UIBarButtonItem(
					title: text,
					style: .plain,
					target: config.target,
					action: config.action
				)
		}
		button.tintColor = config.tintColor
		button.accessibilityTraits = .button
		button.accessibilityIdentifier = config.accessibilityIdentifier
		button.accessibilityLabel = config.accessibilityLabel
		return button
	}
}
