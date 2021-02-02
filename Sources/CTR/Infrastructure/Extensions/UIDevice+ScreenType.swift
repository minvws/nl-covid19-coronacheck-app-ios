/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

extension UIDevice {

	/// Does this phone have a notch?
	var hasNotch: Bool {
		
		let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
		return bottom > 0
	}
}
