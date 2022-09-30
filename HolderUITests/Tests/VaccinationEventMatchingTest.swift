/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

class VaccinationEventMatchingTest: BaseTest {
	
	let setup = TestData.vacP2DifferentSetupSituation
	let setupPerson = Person(bsn: "999993562", name: "van Geer, Corrie", birthDate: Date("1960-01-01"))
	let setupVac1of2 = Vaccination(eventDate: Date(-90), vaccine: .pfizer)
	let setupVac2of2 = Vaccination(eventDate: Date(-60), vaccine: .pfizer)
	let newVac = Vaccination(eventDate: Date(-30), vaccine: .janssen)
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		addVaccinationCertificate(for: setupPerson.bsn!)
		assertRetrievedVaccinationDetails(for: setupPerson, vaccination: setupVac2of2, position: 0)
		assertRetrievedVaccinationDetails(for: setupPerson, vaccination: setupVac1of2, position: 1)
		addRetrievedCertificateToApp()
	}
	
	func test_vacJ1DifferentFirstName_Merges() {
		let differentFirstName = Person(bsn: "999991255", name: "van Geer, Pieter")
		addVaccinationCertificate(for: differentFirstName.bsn!)
		assertRetrievedVaccinationDetails(for: differentFirstName, vaccination: newVac)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: 3, validFromOffsetInDays: -30)
		assertInternationalVaccination(of: newVac, dose: "3/3")
		assertInternationalVaccination(of: setupVac2of2, dose: "2/2")
		assertInternationalVaccination(of: setupVac1of2, dose: "1/2")
		
		viewQRCodes(of: .vaccination)
		assertInternationalVaccinationQR(of: newVac, dose: "3/3", for: differentFirstName)
		viewPreviousQR()
		assertInternationalVaccinationQR(of: setupVac2of2, dose: "2/2", for: setupPerson)
		viewPreviousQR(hidden: true)
		assertInternationalVaccinationQR(of: setupVac1of2, dose: "1/2", for: setupPerson)
	}
	
	func test_vacJ1DifferentLastName_Merges() {
		let differentLastName = Person(bsn: "999991267", name: "de Heuvel, Corrie")
		addVaccinationCertificate(for: differentLastName.bsn!)
		assertRetrievedVaccinationDetails(for: differentLastName, vaccination: newVac)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: 3, validFromOffsetInDays: -30)
		assertInternationalVaccination(of: newVac, dose: "3/3")
		assertInternationalVaccination(of: setupVac2of2, dose: "2/2")
		assertInternationalVaccination(of: setupVac1of2, dose: "1/2")
		
		viewQRCodes(of: .vaccination)
		assertInternationalVaccinationQR(of: newVac, dose: "3/3", for: differentLastName)
		viewPreviousQR()
		assertInternationalVaccinationQR(of: setupVac2of2, dose: "2/2", for: setupPerson)
		viewPreviousQR(hidden: true)
		assertInternationalVaccinationQR(of: setupVac1of2, dose: "1/2", for: setupPerson)
	}
	
	func test_vacJ1DifferentFullName_ReplaceSetup() {
		let differentFullName = Person(bsn: "999992156", name: "de Heuvel, Pieter")
		addVaccinationCertificate(for: differentFullName.bsn!)
		assertRetrievedVaccinationDetails(for: differentFullName, vaccination: newVac)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: 1, validFromOffsetInDays: -30)
		assertInternationalVaccination(of: newVac, dose: "1/1")
		
		viewQRCode(of: .vaccination)
		assertInternationalVaccinationQR(of: newVac, dose: "1/1", for: differentFullName)
	}
	
	func test_vacJ1DifferentFullName_KeepSetup() {
		let differentFullName = Person(bsn: "999992156", name: "de Heuvel, Pieter")
		addVaccinationCertificate(for: differentFullName.bsn!)
		assertRetrievedVaccinationDetails(for: differentFullName, vaccination: newVac)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: 2, validFromOffsetInDays: -60)
		assertInternationalVaccination(of: setupVac2of2, dose: "2/2")
		assertInternationalVaccination(of: setupVac1of2, dose: "1/2")
		
		viewQRCodes(of: .vaccination)
		assertInternationalVaccinationQR(of: setupVac2of2, dose: "2/2", for: setupPerson)
		viewPreviousQR(hidden: true)
		assertInternationalVaccinationQR(of: setupVac1of2, dose: "1/2", for: setupPerson)
	}
	
	func test_vacJ1DifferentBirthDay_ReplaceSetup() {
		let differentBirthDay = Person(bsn: "899991279", birthDate: Date("1960-01-02"))
		addVaccinationCertificate(for: differentBirthDay.bsn!)
		assertRetrievedVaccinationDetails(for: differentBirthDay, vaccination: newVac)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: 1, validFromOffsetInDays: -30)
		assertInternationalVaccination(of: newVac, dose: "1/1")
		
		viewQRCode(of: .vaccination)
		assertInternationalVaccinationQR(of: newVac, dose: "1/1", for: differentBirthDay)
	}
	
	func test_vacJ1DifferentBirthDay_KeepSetup() {
		let differentBirthDay = Person(bsn: "899991279", birthDate: Date("1960-01-02"))
		addVaccinationCertificate(for: differentBirthDay.bsn!)
		assertRetrievedVaccinationDetails(for: differentBirthDay, vaccination: newVac)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: 2, validFromOffsetInDays: -60)
		assertInternationalVaccination(of: setupVac2of2, dose: "2/2")
		assertInternationalVaccination(of: setupVac1of2, dose: "1/2")
		
		viewQRCodes(of: .vaccination)
		assertInternationalVaccinationQR(of: setupVac2of2, dose: "2/2", for: setupPerson)
		viewPreviousQR(hidden: true)
		assertInternationalVaccinationQR(of: setupVac1of2, dose: "1/2", for: setupPerson)
	}
	
	func test_vacJ1DifferentBirthMonth_ReplaceSetup() {
		let differentBirthMonth = Person(bsn: "999993021", birthDate: Date("1960-02-01"))
		addVaccinationCertificate(for: differentBirthMonth.bsn!)
		assertRetrievedVaccinationDetails(for: differentBirthMonth, vaccination: newVac)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: 1, validFromOffsetInDays: -30)
		assertInternationalVaccination(of: newVac, dose: "1/1")
		
		viewQRCode(of: .vaccination)
		assertInternationalVaccinationQR(of: newVac, dose: "1/1", for: differentBirthMonth)
	}
	
	func test_vacJ1DifferentBirthMonth_KeepSetup() {
		let differentBirthMonth = Person(bsn: "999993021", birthDate: Date("1960-02-01"))
		addVaccinationCertificate(for: differentBirthMonth.bsn!)
		assertRetrievedVaccinationDetails(for: differentBirthMonth, vaccination: newVac)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: 2, validFromOffsetInDays: -60)
		assertInternationalVaccination(of: setupVac2of2, dose: "2/2")
		assertInternationalVaccination(of: setupVac1of2, dose: "1/2")
		
		viewQRCodes(of: .vaccination)
		assertInternationalVaccinationQR(of: setupVac2of2, dose: "2/2", for: setupPerson)
		viewPreviousQR(hidden: true)
		assertInternationalVaccinationQR(of: setupVac1of2, dose: "1/2", for: setupPerson)
	}
	
	func test_vacJ1DifferentBirthYear_Merges() {
		let differentBirthYear = Person(bsn: "899991292", birthDate: Date("1970-01-01"))
		addVaccinationCertificate(for: differentBirthYear.bsn!)
		assertRetrievedVaccinationDetails(for: differentBirthYear, vaccination: newVac)
		addRetrievedCertificateToApp()
		
		assertValidDutchVaccinationCertificate(doses: 3, validFromOffsetInDays: -30)
		assertInternationalVaccination(of: newVac, dose: "3/3")
		assertInternationalVaccination(of: setupVac2of2, dose: "2/2")
		assertInternationalVaccination(of: setupVac1of2, dose: "1/2")
		
		viewQRCodes(of: .vaccination)
		assertInternationalVaccinationQR(of: newVac, dose: "3/3", for: differentBirthYear)
		viewPreviousQR()
		assertInternationalVaccinationQR(of: setupVac2of2, dose: "2/2", for: setupPerson)
		viewPreviousQR(hidden: true)
		assertInternationalVaccinationQR(of: setupVac1of2, dose: "1/2", for: setupPerson)
	}
	
	func test_vacJ1DifferentEverything_ReplaceSetup() {
		let differentEverything = Person(bsn: "999991723", name: "de Heuvel, Pieter", birthDate: Date("1970-02-02"))
		addVaccinationCertificate(for: differentEverything.bsn!)
		assertRetrievedVaccinationDetails(for: differentEverything, vaccination: newVac)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		assertValidDutchVaccinationCertificate(doses: 1, validFromOffsetInDays: -30)
		assertInternationalVaccination(of: newVac, dose: "1/1")
		
		viewQRCode(of: .vaccination)
		assertInternationalVaccinationQR(of: newVac, dose: "1/1", for: differentEverything)
	}
	
	func test_vacJ1DifferentEverything_KeepSetup() {
		let differentEverything = Person(bsn: "999991723", name: "de Heuvel, Pieter", birthDate: Date("1970-02-02"))
		addVaccinationCertificate(for: differentEverything.bsn!)
		assertRetrievedVaccinationDetails(for: differentEverything, vaccination: newVac)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		assertValidDutchVaccinationCertificate(doses: 2, validFromOffsetInDays: -60)
		assertInternationalVaccination(of: setupVac2of2, dose: "2/2")
		assertInternationalVaccination(of: setupVac1of2, dose: "1/2")
		
		viewQRCodes(of: .vaccination)
		assertInternationalVaccinationQR(of: setupVac2of2, dose: "2/2", for: setupPerson)
		viewPreviousQR(hidden: true)
		assertInternationalVaccinationQR(of: setupVac1of2, dose: "1/2", for: setupPerson)
	}
}
