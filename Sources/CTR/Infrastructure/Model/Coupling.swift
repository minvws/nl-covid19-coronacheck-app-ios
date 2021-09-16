/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct DccCoupling {

	struct CouplingResponse: Codable {

		let status: CouplingState
	}

	/// The state of the coupling
	enum CouplingState: String, Codable {

		/// The coupling is accepted
		case accepted

		/// The coupling is rejected(combination is wrong)
		case rejected

		/// The coupling is expired(dcc is expired)
		case expired

		/// The coupling is blocked (number of tries exceeded)
		case blocked
	}
}
