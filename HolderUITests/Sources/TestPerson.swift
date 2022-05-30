/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

struct TestPerson {
	let bsn: String?
	let name: String
	let birthDate: String
	let dose: Int
	let doseIntl: [String]
	let vacDate: String?
	let vacFrom: Int
	let vacUntil: Int
	let vacUntilDate: String?
	let vacOffset: Int
	let recFrom: Int
	let recUntil: Int
	let testFrom: Int
	let testUntil: Int
	let dcc: String?
	let couplingCode: String?
	
	init(
		bsn: String? = nil,
		name: String = "van Geer, Corrie",
		birthDate: String = "1960-01-01",
		dose: Int = 0,
		doseIntl: [String] = [],
		vacDate: String? = nil,
		vacFrom: Int = 0,
		vacUntil: Int = 0,
		vacUntilDate: String? = nil,
		vacOffset: Int = 0,
		recFrom: Int = 0,
		recUntil: Int = 0,
		testFrom: Int = 0,
		testUntil: Int = 0,
		dcc: String? = nil,
		couplingCode: String? = nil) {
			self.bsn = bsn
			self.name = name
			self.birthDate = birthDate
			self.dose = dose
			self.doseIntl = doseIntl
			self.vacDate = vacDate
			self.vacFrom = vacFrom
			self.vacUntil = vacUntil
			self.vacUntilDate = vacUntilDate
			self.vacOffset = vacOffset
			self.recFrom = recFrom
			self.recUntil = recUntil
			self.testFrom = testFrom
			self.testUntil = testUntil
			self.dcc = dcc
			self.couplingCode = couplingCode
		}
}
