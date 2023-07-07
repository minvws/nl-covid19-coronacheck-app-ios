/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckUI
import CoronaCheckFoundation

extension UIView {
	
	/// Set up view type name as accessibility label for UI tests
	func setupAccessibleTypeName() {
		guard showAccessibilityLabelsForUITests else {
			return
		}
		
		accessibilityLabel = String(describing: type(of: self))
	}
	
	/// Check if accessibility labels should be shown for UI tests
	var showAccessibilityLabelsForUITests: Bool {
		return LaunchArgumentsHandler.shouldShowAccessibilityLabels()
	}
}
