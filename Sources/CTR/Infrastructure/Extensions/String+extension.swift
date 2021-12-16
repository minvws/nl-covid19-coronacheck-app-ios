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
	/// - Returns: attributed string
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
			.foregroundColor: Theme.colors.primary,
			.underlineStyle: NSUnderlineStyle.single.rawValue
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
	/// - Parameter lineHeight: the line height (defaults to 22)
	/// - Returns: attributed string
	func setLineHeight(
		_ lineHeight: CGFloat = 22.0,
		alignment: NSTextAlignment = .left,
		kerning: CGFloat = 0.0,
		textColor: UIColor = Theme.colors.dark) -> NSAttributedString {

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakMode = .byWordWrapping
		paragraphStyle.alignment = alignment
		paragraphStyle.minimumLineHeightAdjustedForContentSize(lineHeight)

		let attributedString = NSAttributedString(
			string: self,
			attributes: [
				.paragraphStyle: paragraphStyle,
				.kern: kerning,
				.foregroundColor: textColor
			]
		)
		return attributedString
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

extension String {

	func strippingWhitespace() -> String {

		return trimmingCharacters(in: .whitespacesAndNewlines)
			.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
	}
}

extension String {

	/// Add line breaks at each column.
	/// Assumes the string is currently a single line.
	func breakingAtColumn(column: Int) -> String {
		enumerated().reduce("") { result, tuple in
			if (tuple.offset % column) == 0 && tuple.offset != 0 {
				return "\(result)\n\(tuple.element)"
			} else {
				return "\(result)\(tuple.element)"
			}
		}
	}
}
