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
}
