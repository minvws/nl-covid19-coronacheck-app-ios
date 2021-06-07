//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension String {

	static var holderGGDLoginFailureVaccineGeneralTitle: String {

		return Localization.string(for: "holder.ggdlogin.failure.general.title")
	}

	/// localizedEventMode: vaccine, testresult etc.
	static func holderGGDLoginFailureVaccineGeneralMessage(localizedEventMode: String) -> String {

		return String(format: Localization.string(for: "holder.ggdlogin.failure.general.message"), arguments: [localizedEventMode])
	}
}
