/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UIViewController {
	
	/// Set up translucent navigation bar. By default, navigation bar has an opaque background
	func setupTranslucentNavigationBar() {
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.navigationBar.backgroundColor = .clear
		navigationController?.navigationBar.barTintColor = .clear
	}
	
	func createBarButton(for action: Selector, image: UIImage?, tintColor: UIColor? = nil) -> UIBarButtonItem {
		let button = UIButton(type: .custom)
		button.setImage(image, for: .normal)
		button.tintColor = tintColor
		button.accessibilityTraits = .button
		button.addTarget(self, action: action, for: .touchUpInside)
		button.contentEdgeInsets = .leftRight(5)
		return UIBarButtonItem(customView: button)
	}
}
