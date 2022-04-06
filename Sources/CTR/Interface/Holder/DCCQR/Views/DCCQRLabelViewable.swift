/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// Shared protocol between `DCCQRLabelViews` to support accessibility
protocol DCCQRLabelViewable: AnyObject {
	
	/// The dcc field
	var field: String? { get set }
	
	/// The dcc value
	var value: String? { get set }
	
	/// Set up labels to support SwitchControl accessibility
	func updateAccessibilityStatus()
}
