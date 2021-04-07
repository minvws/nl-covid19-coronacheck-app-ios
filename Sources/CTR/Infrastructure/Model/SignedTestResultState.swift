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
	case alreadySigned(response: SignedTestResultErrorResponse)

	/// The test was not negative (code 99993)
	case notNegative(response: SignedTestResultErrorResponse)

	/// The test was in future (code 99991)
	case tooNew(response: SignedTestResultErrorResponse)

	/// The test is too old (code 99992)
	case tooOld(response: SignedTestResultErrorResponse)

	/// The state is unknown
	case unknown(response: SignedTestResultErrorResponse)

	/// The signed test result is valid
	case valid
}

struct SignedTestResultErrorResponse: Decodable {

	/// The error status
	let status: String

	/// The error code
	let code: Int
}

extension SignedTestResultErrorResponse {

	/*
	## Error codes
	99981 - Test is not in expected format
	99982 - Test is empty
	99983 - Test signature invalid
	99991 - Test sample time in the future
	99992 - Test sample time too old (48h)
	99993 - Test result was not negative
	99994 - Test result signed before
	99995 - Unknown error creating signed test result
	99996 - Session key no longer valid
	*/

	/// Get the signed test error response as a signed test state
	/// - Returns: the signed test state
	func asSignedTestResultState() -> SignedTestResultState {

		switch code {
			case 99991:
				return SignedTestResultState.tooNew(response: self)

			case 99992:
				return SignedTestResultState.tooOld(response: self)

			case 99993:
				return SignedTestResultState.notNegative(response: self)

			case 99994:
				return SignedTestResultState.alreadySigned(response: self)

			default:
				return SignedTestResultState.unknown(response: self)
		}
	}
}
