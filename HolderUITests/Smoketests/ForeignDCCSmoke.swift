/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

class DccValidVac2of2NL: BaseTest {
	
	let person = TestData.validVac2of2NL
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + person.dcc!)
		app.launchArguments.append("-couplingCode:" + person.couplingCode!)
		
		try super.setUpWithError()
	}
	
	func test_validVac2of2NL() {
		let offsetDate = calculateOffset(for: person.vacDate!)
		
		addScannedQR()
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: offsetDate)
		assertInternationalVaccinationQRDetails(for: person, vaccinationDateOffsetInDays: offsetDate)
	}
}

class DccValidVac1of2DE: BaseTest {
	
	let person = TestData.validVac1of2DE
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + person.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_validVac1of2DE() {
		let offsetDate = calculateOffset(for: person.vacDate!)
		
		addScannedQR()
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: offsetDate)
		assertInternationalVaccinationQRDetails(for: person, vaccinationDateOffsetInDays: offsetDate)
	}
}

class DccValidVac2of2DE: BaseTest {
	
	let person = TestData.validVac2of2DE
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + person.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_validVac2of2DE() {
		let offsetDate = calculateOffset(for: person.vacDate!)
		
		addScannedQR()
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: offsetDate)
		assertInternationalVaccinationQRDetails(for: person, vaccinationDateOffsetInDays: offsetDate)
	}
}

class DccValidVac3of3DE: BaseTest {
	
	let person = TestData.validVac3of3DE
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + person.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_validVac3of3DE() {
		let offsetDate = calculateOffset(for: person.vacDate!)
		
		addScannedQR()
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: offsetDate)
		assertInternationalVaccinationQRDetails(for: person, vaccinationDateOffsetInDays: offsetDate)
	}
}

class DccExpiredVac1of2DE: BaseTest {
	
	let person = TestData.expiredVac1of2DE
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + person.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_expiredVac1of2DE() {
		let offsetDate = calculateOffset(for: person.vacDate!)
		
		addScannedQR()
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: offsetDate)
		assertInternationalVaccinationQRDetails(for: person, vaccinationDateOffsetInDays: offsetDate)
	}
}

class DccExpiredVac2of2DE: BaseTest {
	
	let person = TestData.expiredVac2of2DE
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + person.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_expiredVac2of2DE() {
		let offsetDate = calculateOffset(for: person.vacDate!)
		
		addScannedQR()
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: offsetDate)
		assertInternationalVaccinationQRDetails(for: person, vaccinationDateOffsetInDays: offsetDate)
	}
}

class DccExpiredVac3of3DE: BaseTest {
	
	let person = TestData.expiredVac3of3DE
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + person.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_expiredVac3of3DE() {
		let offsetDate = calculateOffset(for: person.vacDate!)
		
		addScannedQR()
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl, vaccinationDateOffsetInDays: offsetDate)
		assertInternationalVaccinationQRDetails(for: person, vaccinationDateOffsetInDays: offsetDate)
	}
}
