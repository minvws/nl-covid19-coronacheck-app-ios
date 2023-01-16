/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class NavigationController: UINavigationController {

	convenience init() {
		self.init(nibName: nil, bundle: nil)
		navigationBar.prefersLargeTitles = UIDevice.current.userInterfaceIdiom != .pad
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {

		if #available(iOS 13.0, *) {
			return topViewController?.preferredStatusBarStyle ?? .darkContent
		} else {
			return topViewController?.preferredStatusBarStyle ?? .default
		}
	}
}
