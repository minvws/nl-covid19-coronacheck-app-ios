/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The state of the signed test result
enum SignedTestResultState {

	/// The test was already signed before (code 99994)
	case alreadySigned

	/// The test was not negative (code 99993)
	case notNegative

	/// The test was in future (code 99991)
	case tooNew

	/// The test is too old (code 99992)
	case tooOld

	/// The state is unknown
	case unknown(Error?)

	/// The signed test result is valid
	case valid
}

struct SignedTestResultErrorResponse: Decodable {

	/// The error status
	let status: String

	/// The error code
	let code: Int
}
