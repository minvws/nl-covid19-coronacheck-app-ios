/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct DCCQRDetails {
	let field: DCCQRDetailable
	let value: String?
}

protocol DCCQRDetailable {
	
	/// The display title of the field
	var displayTitle: String { get }
}

enum DCCQRDetailsVaccination: DCCQRDetailable {
	
	var displayTitle: String {
		return ""
	}
}

enum DCCQRDetailsTest: DCCQRDetailable {
	
	var displayTitle: String {
		return ""
	}
}

enum DCCQRDetailsRecovery: DCCQRDetailable {
	
	var displayTitle: String {
		return ""
	}
}
