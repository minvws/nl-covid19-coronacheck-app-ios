//
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
	func setLineHeight(_ lineHeight: CGFloat = 20.0) -> NSAttributedString {

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakMode = .byWordWrapping
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
}
