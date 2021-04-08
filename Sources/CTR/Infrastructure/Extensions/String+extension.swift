/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension String {

	/// Underline a part of the text
	/// - Parameter underlined: the part to underline
	/// - Returns: attibuted string
	func underline(underlined: String) -> NSAttributedString {

		let underlineRange = (self as NSString).range(of: underlined)
		let attributes: [NSAttributedString.Key: Any] = [
			.underlineStyle: NSUnderlineStyle.single.rawValue
		]
		let attributedText = NSMutableAttributedString(
			string: self
		)
		attributedText.addAttributes(attributes, range: underlineRange)
		return attributedText
	}

	/// Underline a part of the text
	/// - Parameters:
	///   - underlined: the part to underline
	///   - color: the color to underline with
	/// - Returns: attributed string
	func underline(underlined: String, with color: UIColor) -> NSAttributedString {

		let underlineRange = (self as NSString).range(of: underlined)
		let attributes: [NSAttributedString.Key: Any] = [
			.underlineStyle: NSUnderlineStyle.single.rawValue,
			.foregroundColor: color
		]
		let attributedText = NSMutableAttributedString(
			string: self
		)
		attributedText.addAttributes(attributes, range: underlineRange)
		return attributedText
	}

	/// Underline a part of the text
	/// - Parameters:
	///   - underlined: the part to underline
	/// - Returns: attributed string
	func underlineAsLink(underlined: String) -> NSAttributedString {

		let underlineRange = (self as NSString).range(of: underlined)
		let attributes: [NSAttributedString.Key: Any] = [
			.link: underlined
		]
		let attributedText = NSMutableAttributedString(
			string: self
		)
		attributedText.addAttributes(attributes, range: underlineRange)
		return attributedText
	}

	/// Change the color a part of the text
	/// - Parameters:
	///   - text: the part to color
	///   - color: the color to underline with
	/// - Returns: attributed string
	func color(text: String, with color: UIColor) -> NSAttributedString {

		let underlineRange = (self as NSString).range(of: text)
		let attributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: color
		]
		let attributedText = NSMutableAttributedString(
			string: self
		)
		attributedText.addAttributes(attributes, range: underlineRange)
		return attributedText
	}

	/// Set the line height
	/// - Parameter lineHeight: the line height
	/// - Returns: attributed string
	func setLineHeight(_ lineHeight: CGFloat = 20.0, alignment: NSTextAlignment = .left, kerning: CGFloat = 0.0) -> NSAttributedString {

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakMode = .byWordWrapping
		paragraphStyle.alignment = alignment
		paragraphStyle.minimumLineHeight = lineHeight

		let attrString = NSAttributedString(
			string: self,
			attributes: [
				.paragraphStyle: paragraphStyle,
				.kern: kerning
			]
		)
		return attrString
	}
}

// See https://www.hackingwithswift.com/example-code/strings/how-to-capitalize-the-first-letter-of-a-string

extension String {

	func capitalizingFirstLetter() -> String {

		return prefix(1).capitalized + dropFirst()
	}

	mutating func capitalizeFirstLetter() {

		self = self.capitalizingFirstLetter()
	}
}
