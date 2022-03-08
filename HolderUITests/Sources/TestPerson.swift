/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

struct TestPerson {
	let bsn: String
	let name: String?
	let birthdate: String
	let dose: Int
	let doseIntl: [String]
	let vacFrom: Int
	let vacUntil: Int
	let vacUntilDate: String?
	let vacOffset: Int
	let recFrom: Int
	let recUntil: Int
	let testFrom: Int
	let testUntil: Int
	
	let baseTest = BaseTest()
	
	init(
		bsn: String,
		name: String? = nil,
		birthdate: String? = nil,
		dose: Int = 0,
		doseIntl: [String] = [],
		vacFrom: Int = 0,
		vacUntil: Int = 0,
		vacUntilDate: String? = nil,
		vacOffset: Int = 0,
		recFrom: Int = 0,
		recUntil: Int = 0,
		testFrom: Int = 0,
		testUntil: Int = 0) {
			self.bsn = bsn
			self.name = name
			self.birthdate = birthdate ?? baseTest.formattedDate(with: "1960-01-01")
			self.dose = dose
			self.doseIntl = doseIntl
			self.vacFrom = vacFrom
			self.vacUntil = vacUntil
			self.vacUntilDate = vacUntilDate
			self.vacOffset = vacOffset
			self.recFrom = recFrom
			self.recUntil = recUntil
			self.testFrom = testFrom
			self.testUntil = testUntil
		}
}
