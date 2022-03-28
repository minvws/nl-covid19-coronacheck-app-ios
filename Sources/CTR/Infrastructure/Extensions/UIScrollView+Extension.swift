/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UIScrollView {
	
	/// Translates scroll offset Y origin to bottom. Scrolled to bottom will return value of zero.
	var translatedBottomScrollOffset: CGFloat {
		return contentOffset.y - (contentSize.height - bounds.height)
	}
	
	/// Scroll to bottom. Is animated.
	func scrollToBottom() {
		// https://stackoverflow.com/a/952768/443270
		let bottomOffset = CGPoint(
			x: 0,
			y: contentSize.height - bounds.height + contentInset.bottom
		)
		setContentOffset(bottomOffset, animated: true)
	}
}
