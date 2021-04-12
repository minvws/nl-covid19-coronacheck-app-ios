/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ForcedInformationManaging {

	// Initialize
	init()

	/// Do we need updating? True if we do
	var needsUpdating: Bool { get }
}

class ForcedInformationManager: ForcedInformationManaging {

	// Initialize
	required init() {
		// Required by protocol
	}

	/// Do we need updating? True if we do
	var needsUpdating: Bool {
		return true
	}
}
