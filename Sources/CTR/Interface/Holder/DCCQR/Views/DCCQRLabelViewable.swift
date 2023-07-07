/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation

/// Shared protocol between `DCCQRLabelViews` to support accessibility
protocol DCCQRLabelViewable: AnyObject {
	
	/// Set up labels to support SwitchControl accessibility
	func updateAccessibilityStatus()
}
