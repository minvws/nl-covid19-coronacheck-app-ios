/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The credentials of the the holder of the test
struct TestHolderIdentity: Codable, Equatable {

	/// The first letter of the first name
	let firstNameInitial: String

	/// The first letter of the last name (no middle names)
	let lastNameInitial: String

	/// The day of birth (1- 31) as String
	let birthDay: String

	/// The month of birth (1- 12) as String
	let birthMonth: String
}

extension TestHolderIdentity {

	/// Map the identity of the holder
	/// - Parameter months: the months
	/// - Returns: mapped identify
	func mapIdentity(months: [String]) -> [String] {

		var output: [String] = []
		output.append(firstNameInitial)
		output.append(lastNameInitial)
		if let value = Int(birthDay), value > 0 {
			let formatter = NumberFormatter()
			formatter.minimumIntegerDigits = 2
			if let day = formatter.string(from: NSNumber(value: value)) {
				output.append(day)
			}
		} else {
			output.append(birthDay)
		}

		if let value = Int(birthMonth), value <= months.count, value > 0 {
			output.append(months[value - 1])
		} else {
			output.append(birthMonth)
		}

		return output
	}

	func identityMatchTuple() -> (firstNameInitial: String?, lastNameInitial: String?, day: String?, month: String?) {
		
		return (firstNameInitial: firstNameInitial, lastNameInitial: lastNameInitial, day: birthDay, month: birthMonth)
	}
}
