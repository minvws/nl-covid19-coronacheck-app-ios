/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ProofValidatorProtocol {

	/// Initializer
	/// - Parameter maxValidity: the maximum validity of a test in hours
	init(maxValidity: Int)

	/// Validate the proof
	/// - Parameter sampleTimeStamp: the sample time stamp
	/// - Returns: Validity
	func validate(_ sampleTimeStamp: TimeInterval) -> ProofValidity
}

enum ProofValidity {

	/// The proof is still valid
	case valid(Date)

	/// The proof is expiring
//	case expiring

	/// The proof is expired
	case expired
}

class ProofValidator: ProofValidatorProtocol, Logging {

	/// the maximum validity of a test in hours
	var maxValidity: Int

	/// Initializer
	/// - Parameter maxValidity: the maximum validity of a test in hours
	required init(maxValidity: Int) {

		self.maxValidity = maxValidity
	}

	/// Validate the proof
	/// - Parameter sampleTimeStamp: the sample time stamp
	/// - Returns: Validity
	func validate(_ sampleTimeStamp: TimeInterval) -> ProofValidity {

		let now = Date().timeIntervalSince1970
		let validity = TimeInterval(maxValidity * 60 * 60)
		logDebug("Checking with \(maxValidity) hours")
		if (sampleTimeStamp + validity) > now && sampleTimeStamp < now {

			let validUntilDate = Date(timeIntervalSince1970: sampleTimeStamp + validity)
			return .valid(validUntilDate)
		} else {
			
			return .expired
		}
	}
}
