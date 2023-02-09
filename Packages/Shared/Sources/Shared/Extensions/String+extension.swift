/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension String {

	/// Underline a part of the text
	/// - Parameters:
	///   - underlined: the part to underline
	///   - color: the color to underline with
	/// - Returns: attributed string
	public func underline(underlined: String, with color: UIColor) -> NSAttributedString {

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

	/// Set the line height
	/// - Parameter lineHeight: the line height (defaults to 22)
	/// - Returns: attributed string
	public func setLineHeight(
		_ lineHeight: CGFloat = 22.0,
		alignment: NSTextAlignment = .left,
		kerning: CGFloat = 0.0,
		textColor: UIColor = C.black()!) -> NSAttributedString {

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

	public func capitalizingFirstLetter() -> String {

		return prefix(1).capitalized + dropFirst()
	}
}

extension String {

	public func strippingWhitespace() -> String {

		return trimmingCharacters(in: .whitespacesAndNewlines)
			.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
	}
}
