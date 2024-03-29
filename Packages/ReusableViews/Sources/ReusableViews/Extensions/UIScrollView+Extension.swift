/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UIScrollView {
	
	/// Translates scroll offset Y origin to bottom. Scrolled to bottom will return value of zero.
	public var translatedBottomScrollOffset: CGFloat {
		return contentOffset.y - (contentSize.height - bounds.height)
	}
	
	/// Scroll to bottom if content is not completely visible. Is animated.
	public func scrollToBottomIfNotCompletelyVisible() {
		// Only scroll when content is scrollable
		guard contentSize.height > bounds.height else { return }
		
		// https://stackoverflow.com/a/952768/443270
		let bottomOffset = CGPoint(
			x: 0,
			y: contentSize.height - bounds.height + contentInset.bottom
		)
		setContentOffset(bottomOffset, animated: true)
	}
}
