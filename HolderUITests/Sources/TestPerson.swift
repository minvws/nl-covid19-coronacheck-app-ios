/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

struct TestPerson {
	let bsn: String
	let name: String?
	let doseNL: Int
	let doseIntl: [String]
	let validFromNL: Int
	let validUntilNL: Int
	let validUntilDate: String?
	
	init(bsn: String, name: String? = nil, doseNL: Int = 0, doseIntl: [String] = [], validFromNL: Int = 0, validUntilNL: Int = 0, validUntilDate: String? = nil) {
		self.bsn = bsn
		self.name = name
		self.doseNL = doseNL
		self.doseIntl = doseIntl
		self.validFromNL = validFromNL
		self.validUntilNL = validUntilNL
		self.validUntilDate = validUntilDate
	}
}
