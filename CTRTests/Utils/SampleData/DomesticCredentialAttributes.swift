/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

extension DomesticCredentialAttributes {
	
	static func sample(category: String?) -> DomesticCredentialAttributes {
		DomesticCredentialAttributes(
			birthDay: "30",
			birthMonth: "5",
			firstNameInitial: "R",
			lastNameInitial: "P",
			credentialVersion: "2",
			category: category ?? "",
			specimen: "0",
			paperProof: "0",
			validFrom: "\(Date().timeIntervalSince1970)",
			validForHours: "24"
		)
	}
}
