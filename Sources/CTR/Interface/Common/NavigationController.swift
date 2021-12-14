/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class NavigationController: UINavigationController {

	override var preferredStatusBarStyle: UIStatusBarStyle {

		if #available(iOS 13.0, *) {
			return topViewController?.preferredStatusBarStyle ?? .darkContent
		} else {
			return topViewController?.preferredStatusBarStyle ?? .default
		}
	}

}
