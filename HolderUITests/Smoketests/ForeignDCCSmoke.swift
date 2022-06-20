/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

// MARK: Valid vaccinations

class DccValidVac1of2DE: BaseTest {
	
	let person = TestData.vacP1
	
	let vac1 = TestData.validVac1of2DE
	let vac2 = Vaccination(eventDate: Date(-30), vaccine: .pfizer)
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + vac1.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_validVac1of2DE() {
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		addScannedQR()
		
		assertInternationalVaccination(of: vac1, dose: "2/2")
		assertInternationalVaccination(of: vac2, dose: "1/2")
		
		viewQRCode(of: .vaccination)
		assertInternationalVaccinationQR(of: vac2, dose: "2/2")
		viewPreviousQR(hidden: true)
		assertInternationalVaccinationQR(of: vac1, dose: "1/2")
	}
}

class DccValidVac2of2DE: BaseTest {
	
	let person = TestData.vacP1
	
	let vac1 = TestData.validVac2of2DE
	let vac2 = Vaccination(eventDate: Date(-30), vaccine: .pfizer)
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + vac1.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_validVac2of2DE() {
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		addScannedQR()
		
		assertInternationalVaccination(of: vac1, dose: "3/3")
		assertInternationalVaccination(of: vac2, dose: "2/2")
		
		viewQRCode(of: .vaccination)
		assertInternationalVaccinationQR(of: vac2, dose: "3/3")
		viewPreviousQR()
		assertInternationalVaccinationQR(of: vac1, dose: "2/2")
	}
}

class DccValidVac3of3DE: BaseTest {
	
	let person = TestData.vacP1
	
	let vac1 = TestData.validVac3of3DE
	let vac2 = Vaccination(eventDate: Date(-30), vaccine: .pfizer)
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + vac1.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_validVac3of3DE() {
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		addScannedQR()
		
		assertInternationalVaccination(of: vac1, dose: "4/4")
		assertInternationalVaccination(of: vac2, dose: "3/3")
		
		viewQRCode(of: .vaccination)
		assertInternationalVaccinationQR(of: vac2, dose: "4/4")
		viewPreviousQR()
		assertInternationalVaccinationQR(of: vac1, dose: "3/3")
	}
}

// MARK: - Expired vaccinations

class DccExpiredVac1of2DE: BaseTest {
	
	let vaccination = TestData.expiredVac1of2DE
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + vaccination.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_expiredVac1of2DE() {
		addScannedQR()
		assertSomethingWentWrong()
	}
}

class DccExpiredVac2of2DE: BaseTest {
	
	let vaccination = TestData.expiredVac2of2DE
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + vaccination.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_expiredVac2of2DE() {
		addScannedQR()
		assertSomethingWentWrong()
	}
}

class DccExpiredVac3of3DE: BaseTest {
	
	let vaccination = TestData.expiredVac3of3DE
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + vaccination.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_expiredVac3of3DE() {
		addScannedQR()
		assertSomethingWentWrong()
	}
}

// MARK: - Positive tests

class DccValidRecDE: BaseTest {
	
	let person = TestData.vacP1
	
	let positiveTest = TestData.validRecDE
	let vaccination = Vaccination(eventDate: Date(-30), vaccine: .pfizer)
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + positiveTest.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_validRecDE() {
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		addScannedQR()
		
		assertInternationalRecovery(of: positiveTest)
		assertInternationalRecoveryQR(for: positiveTest)
	}
}

class DccExpiredRecDE: BaseTest {
	
	let positiveTest = TestData.expiredRecDE
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + positiveTest.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_expiredRecDE() {
		addScannedQR()
		assertSomethingWentWrong()
	}
}

class DccValidNegDE: BaseTest {

	let person = TestData.negPcr
	let negativeTest = TestData.validNegDE

	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + negativeTest.dcc!)

		try super.setUpWithError()
	}

	func test_validVac1of2DE() {
		addTestCertificateFromGGD(for: person.bsn)
		addRetrievedCertificateToApp()

		addScannedQR()

		assertSomethingWentWrong(error: "i 580 000 500 99785")
	}
}

class DccExpiredNegDE: BaseTest {
	
	let negativeTest = TestData.expiredNegDE
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + negativeTest.dcc!)
		
		try super.setUpWithError()
	}
	
	func test_validVac1of2DE() {
		addScannedQR()
		assertSomethingWentWrong(error: "i 580 000 500 99799")
	}
}
