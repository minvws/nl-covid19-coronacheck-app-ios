/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

class Person {
	let bsn: String?
	let name: String
	let birthDate: Date
	
	init(
		bsn: String?,
		name: String,
		birthDate: Date) {
			self.bsn = bsn
			self.name = name
			self.birthDate = birthDate
		}
	
	convenience init(bsn: String? = nil) {
		self.init(bsn: bsn, name: "van Geer, Corrie", birthDate: Date("1960-01-01"))
	}
}
