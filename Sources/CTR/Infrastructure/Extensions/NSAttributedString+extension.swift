/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension NSAttributedString {

	/// Set the line height
	/// - Parameter lineHeight: the line height
	/// - Returns: attributed string
	func setLineHeight(_ lineHeight: CGFloat = 20.0, alignment: NSTextAlignment = .left) -> NSAttributedString {

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakMode = .byWordWrapping
		paragraphStyle.alignment = alignment
		paragraphStyle.minimumLineHeight = lineHeight

		let attrString = NSMutableAttributedString(attributedString: self)
		attrString.addAttributes(
			[
				.paragraphStyle: paragraphStyle
			],
			range: _NSRange(
				location: 0,
				length: self.length
			)
		)
		return attrString
	}

	/// bold a part of the text
	/// - Parameters:
	///   - underlined: the part to underline
	///   - color: the color to underline with
	/// - Returns: attributed string
	func bold(_ bolds: [String], with font: UIFont) -> NSAttributedString {

		var output = NSMutableAttributedString(attributedString: self)

		for bold in bolds {

			if let boldRange = self.string.range(of: bold) {
				let attributes: [NSAttributedString.Key: Any] = [
					.font: font
				]

				output.addAttributes(attributes, range: NSRange(boldRange, in: self.string))
			}
		}

		return output
	}

	func rangeOf(string: String) -> Range<String.Index>? {
		return self.string.range(of: string)
	}
}
