/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ProofValidatorProtocol {

	var maxValidity: Int { get }

	/// Initializer
	/// - Parameter maxValidity: the maximum validity of a test in hours
	init(maxValidity: Int)

	/// Validate the proof
	/// - Parameter sampleTimeStamp: the sample time stamp
	/// - Returns: Validity
	func validate(_ sampleTimeStamp: TimeInterval) -> ProofValidity
}

enum ProofValidity {

	/// The proof is still valid (expiration date)
	case valid(Date)

	/// The proof is expiring (expiration date, time left to expiration)
	case expiring(Date, TimeInterval)

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
		let warningPeriod = TimeInterval(6 * 60 * 60)
		logDebug("Checking with \(maxValidity) hours")
		if (sampleTimeStamp + validity) > now && sampleTimeStamp < now {

			let validUntilDate = Date(timeIntervalSince1970: sampleTimeStamp + validity)
			let timeLeft = sampleTimeStamp + validity - now
			logDebug("timeLeft: \(timeLeft), warningPeriod: \(warningPeriod)")

			if timeLeft < warningPeriod {
				return .expiring(validUntilDate, timeLeft)
			}
			return .valid(validUntilDate)
		} else {
			
			return .expired
		}
	}
}
