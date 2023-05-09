/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

extension UIDevice {

	/// Is this a device with a smaller screen? (4" screen)
	public var isSmallScreen: Bool {

		return UIScreen.main.nativeBounds.height <= 1136
	}

	/// Does this phone have a notch?
	public var hasNotch: Bool {
		
		let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
		return bottom > 0
	}
	
	public var isLandscape: Bool {
		if #available(iOS 13.0, *) {
			return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape ?? false
		} else {
			return UIApplication.shared.statusBarOrientation.isLandscape
		}
	}
}
