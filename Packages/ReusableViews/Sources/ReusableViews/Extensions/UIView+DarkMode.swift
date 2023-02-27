/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// Override points for querying if `self` and `Self` should render using dark mode
public extension UIView {
	
	var shouldUseDarkMode: Bool {
		guard #available(iOS 13.0, *) else { return false }
		return Self.shouldUseDarkMode(forTraitCollection: traitCollection)
	}
	
	@available(iOS 12.0, *)
	static func shouldUseDarkMode(forTraitCollection traitCollection: UITraitCollection) -> Bool {
		guard #available(iOS 13.0, *) else { return false } // we only support iOS native dark mode (which came in iOS 13).
		return traitCollection.userInterfaceStyle == .dark
	}
}
