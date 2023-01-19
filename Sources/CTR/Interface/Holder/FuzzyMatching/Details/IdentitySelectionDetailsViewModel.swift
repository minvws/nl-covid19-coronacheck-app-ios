/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

struct IdentitySelectionDetails: Equatable {
	
	let name: String
	let details: [[String]]
}

class IdentitySelectionDetailsViewModel {
	
	let title = Observable<String>(value: L.general_details())
	var message = Observable<String>(value: "")
	var details = Observable<[[String]]>(value: [])
	
	init(identitySelectionDetails: IdentitySelectionDetails) {
		
		message.value = L.holder_identitySelection_details_body(identitySelectionDetails.name)
		details.value = identitySelectionDetails.details
	}
}
