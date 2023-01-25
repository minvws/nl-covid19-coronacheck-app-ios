/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UIView {
	
	func setupLargeContentViewer(title: String? = nil) {
		guard #available(iOS 13.0, *) else { return }
		addInteraction(UILargeContentViewerInteraction())
		showsLargeContentViewer = true
		
		// UIButton set its own large content title, when title is set
		guard let title = title else { return }
		largeContentTitle = title
	}
}
