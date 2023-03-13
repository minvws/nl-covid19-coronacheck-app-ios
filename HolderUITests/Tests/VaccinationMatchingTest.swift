/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

class VaccinationMatchingTest: BaseTest {
	
	let setupPerson = Person(bsn: "999993562", name: "van Geer, Corrie", birthDate: Date("1960-01-01"))
	let setupVac1of2 = Vaccination(eventDate: Date(-90), vaccine: .pfizer)
	let setupVac2of2 = Vaccination(eventDate: Date(-60), vaccine: .pfizer)
	let newVac = Vaccination(eventDate: Date(-30), vaccine: .janssen)
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		addVaccinationCertificate(for: setupPerson.bsn!)
		addRetrievedCertificateToApp()
	}
	
	func test_identicalBirthdateIdenticalName() {
		let person = Person(bsn: "999991255")
		retrieveCertificate(for: person)
		
		assertMergedVaccinations(for: person)
	}
	
	func test_identicalBirthdateMatchingName() {
		let person = Person(bsn: "999991267", name: "van Gool, Berrie")
		retrieveCertificate(for: person)
		
		assertMergedVaccinations(for: person)
	}
	
	func test_identicalBirthdateDifferentFirstName_keepOriginalName() {
		let person = Person(bsn: "999992156", name: "van Gool, Borry")
		retrieveCertificate(for: person)
		
		// Temp disabled as the signer does not use fuzzy matching
		/*
		 chooseToKeepNameOf(setupPerson)
		 
		 assertSetupVaccination()
		 assertNewVaccinationRemoved()
		 */
		
		// Default back to initial match result
		assertMergedVaccinations(for: person)
	}
	
	func test_identicalBirthdateDifferentFirstName_replaceOriginalName() {
		let person = Person(bsn: "999992156", name: "van Gool, Borry")
		retrieveCertificate(for: person)
		
		// Temp disabled as the signer does not use fuzzy matching
		/*
		 chooseToKeepNameOf(person)
		 
		 assertReplacedVaccination(for: person)
		 assertSetupVaccinationRemoved()
		 */
		
		// Default back to initial match result
		assertMergedVaccinations(for: person)
	}
	
	func test_identicalBirthdateDifferentLastName_keepOriginalName() {
		let person = Person(bsn: "999993021", name: "de Gael, Berrie")
		retrieveCertificate(for: person)
		
		// Temp disabled as the signer does not use fuzzy matching
		/*
		 chooseToKeepNameOf(setupPerson)
		 
		 assertSetupVaccination()
		 assertNewVaccinationRemoved()
		 */
		
		// Default back to initial match result
		assertMergedVaccinations(for: person)
	}
	
	func test_identicalBirthdateDifferentLastName_replaceOriginalName() {
		let person = Person(bsn: "999993021", name: "de Gael, Berrie")
		retrieveCertificate(for: person)
		
		// Temp disabled as the signer does not use fuzzy matching
		/*
		 chooseToKeepNameOf(person)
		 
		 assertReplacedVaccination(for: person)
		 assertSetupVaccinationRemoved()
		 */
		
		// Default back to initial match result
		assertMergedVaccinations(for: person)
	}
	
	func test_identicalBirthdateDifferentLastName_reloadAndKeepSetup() {
		let person = Person(bsn: "999993021", name: "de Gael, Berrie")
		retrieveCertificate(for: person)
		
		// Temp disabled as the signer does not use fuzzy matching
		/*
		 chooseToKeepNameOf(person)
		 
		 retrieveCertificate(for: setupPerson)
		 chooseToKeepNameOf(setupPerson)
		 
		 assertSetupVaccination()
		 assertNewVaccinationRemoved()
		 */
		
		// Default back to initial match result
		assertMergedVaccinations(for: person)
	}
	
	func test_identicalBirthdateDifferentLastName_reloadAndIgnoreSetup() {
		let person = Person(bsn: "999993021", name: "de Gael, Berrie")
		retrieveCertificate(for: person)
		
		// Temp disabled as the signer does not use fuzzy matching
		/*
		chooseToKeepNameOf(person)
		
		retrieveCertificate(for: setupPerson)
		chooseToKeepNameOf(person)
		
		assertReplacedVaccination(for: person)
		assertSetupVaccinationRemoved()
		 */
		
		// Default back to initial match result
		assertMergedVaccinations(for: person)
	}
	
	func test_identicalBirthdateDifferentFirstNameInitial() {
		let person = Person(bsn: "999991723", name: "van Geer, Xorrie")
		retrieveCertificate(for: person)
		
		assertMergedVaccinations(for: person)
	}
	
	func test_identicalBirthdateDifferentLastNameInitial() {
		let person = Person(bsn: "999994098", name: "van Xeer, Corrie")
		retrieveCertificate(for: person)
		
		assertMergedVaccinations(for: person)
	}
	
	func test_differentBirthDay_keepSetup() {
		let person = Person(bsn: "999994104", birthDate: Date("1960-01-02"))
		retrieveCertificate(for: person)
		replaceExistingCertificate(false)
		
		assertSetupVaccination()
	}
	
	func test_differentBirthDay_replaceSetup() {
		let person = Person(bsn: "999994104", birthDate: Date("1960-01-02"))
		retrieveCertificate(for: person)
		replaceExistingCertificate(true)
		
		assertReplacedVaccination(for: person)
	}
	
	func test_differentBirthMonth_keepSetup() {
		let person = Person(bsn: "999994116", birthDate: Date("1960-02-01"))
		retrieveCertificate(for: person)
		replaceExistingCertificate(false)
		
		assertSetupVaccination()
	}
	
	func test_differentBirthMonth_replaceSetup() {
		let person = Person(bsn: "999994116", birthDate: Date("1960-02-01"))
		retrieveCertificate(for: person)
		replaceExistingCertificate(true)
		
		assertReplacedVaccination(for: person)
	}
	
	func test_differentBirthMonth_reloadAndKeepSetup() {
		let person = Person(bsn: "999994116", birthDate: Date("1960-02-01"))
		retrieveCertificate(for: person)
		replaceExistingCertificate(true)
		
		retrieveCertificate(for: setupPerson)
		replaceExistingCertificate(true)
		
		assertSetupVaccination()
	}
	
	func test_differentBirthMonth_reloadAndIgnoreSetup() {
		let person = Person(bsn: "999994116", birthDate: Date("1960-02-01"))
		retrieveCertificate(for: person)
		replaceExistingCertificate(true)
		
		retrieveCertificate(for: setupPerson)
		replaceExistingCertificate(false)
		
		assertReplacedVaccination(for: person)
	}
	
	func test_differentBirthYeardateIdenticalName() {
		let person = Person(bsn: "999994128", birthDate: Date("1970-01-01"))
		retrieveCertificate(for: person)
		
		assertMergedVaccinations(for: person)
	}
	
	func test_differentBirthYeardateMatchingName() {
		let person = Person(bsn: "999994141", name: "van Gool, Berrie", birthDate: Date("1970-01-01"))
		retrieveCertificate(for: person)
		
		assertMergedVaccinations(for: person)
	}
	
	func test_differentBirthYeardateDifferentFirstName_keepOriginalName() {
		let person = Person(bsn: "999994153", name: "van Gool, Borry", birthDate: Date("1970-01-01"))
		retrieveCertificate(for: person)
		// Temp disabled as the signer does not use fuzzy matching
		/*
		 chooseToKeepNameOf(setupPerson)
		 
		 assertSetupVaccination()
		 assertNewVaccinationRemoved()
		 */
		// Default back to initial match result
		assertMergedVaccinations(for: person)
	}
	
	func test_differentBirthYeardateDifferentFirstName_replaceOriginalName() {
		let person = Person(bsn: "999994153", name: "van Gool, Borry", birthDate: Date("1970-01-01"))
		retrieveCertificate(for: person)
		// Temp disabled as the signer does not use fuzzy matching
		/*
		 chooseToKeepNameOf(person)
		 
		 assertReplacedVaccination(for: person)
		 assertSetupVaccinationRemoved()
		 */
		// Default back to initial match result
		assertMergedVaccinations(for: person)
	}
	
	func test_differentBirthYeardateDifferentLastName_keepOriginalName() {
		let person = Person(bsn: "999994165", name: "de Gael, Berrie", birthDate: Date("1970-01-01"))
		retrieveCertificate(for: person)
		// Temp disabled as the signer does not use fuzzy matching
		/*
		 chooseToKeepNameOf(setupPerson)
		 
		 assertSetupVaccination()
		 assertNewVaccinationRemoved()
		 
		 */
		// Default back to initial match result
		assertMergedVaccinations(for: person)
	}
	
	func test_differentBirthYeardateDifferentLastName_replaceOriginalName() {
		let person = Person(bsn: "999994165", name: "de Gael, Berrie", birthDate: Date("1970-01-01"))
		retrieveCertificate(for: person)
		// Temp disabled as the signer does not use fuzzy matching
		/*
		 chooseToKeepNameOf(person)
		
		assertReplacedVaccination(for: person)
		assertSetupVaccinationRemoved()
		 */
		// Default back to initial match result
		assertMergedVaccinations(for: person)
	}
	
	func test_differentBirthYeardateDifferentFirstNameInitial() {
		let person = Person(bsn: "999994177", name: "van Geer, Xorrie", birthDate: Date("1970-01-01"))
		retrieveCertificate(for: person)
		
		assertMergedVaccinations(for: person)
	}
	
	func test_differentBirthYeardateDifferentLastNameInitial() {
		let person = Person(bsn: "999994189", name: "van Xeer, Corrie", birthDate: Date("1970-01-01"))
		retrieveCertificate(for: person)
		
		assertMergedVaccinations(for: person)
	}
	
	func test_differentBirthdateDifferentName_keepSetup() {
		let person = Person(bsn: "999994190", name: "de Heuvel, Pieter", birthDate: Date("1970-02-02"))
		retrieveCertificate(for: person)
		replaceExistingCertificate(false)
		
		assertSetupVaccination()
	}
	
	func test_differentBirthdateDifferentName_replaceSetup() {
		let person = Person(bsn: "999994190", name: "de Heuvel, Pieter", birthDate: Date("1970-02-02"))
		retrieveCertificate(for: person)
		replaceExistingCertificate(true)
		
		assertReplacedVaccination(for: person)
	}
	
	// MARK: private functions
	
	private func retrieveCertificate(for person: Person) {
		addVaccinationCertificate(for: person.bsn!)
		if person === setupPerson {
			assertRetrievedVaccinationDetails(for: setupPerson, vaccination: setupVac2of2, position: 0)
			assertRetrievedVaccinationDetails(for: setupPerson, vaccination: setupVac1of2, position: 1)
		} else {
			assertRetrievedVaccinationDetails(for: person, vaccination: newVac)
		}
		addRetrievedCertificateToApp()
	}
	
	private func assertSetupVaccination() {
		assertInternationalVaccination(of: setupVac2of2, dose: "2/2")
		assertInternationalVaccination(of: setupVac1of2, dose: "1/2")
		
		viewQRCodes(of: .vaccination)
		assertInternationalVaccinationQR(of: setupVac2of2, dose: "2/2", for: setupPerson)
		viewPreviousQR(hidden: true)
		assertInternationalVaccinationQR(of: setupVac1of2, dose: "1/2", for: setupPerson)
		backToOverview()
	}
	
	private func assertMergedVaccinations(for person: Person) {
		assertInternationalVaccination(of: newVac, dose: "3/3")
		assertInternationalVaccination(of: setupVac2of2, dose: "2/2")
		assertInternationalVaccination(of: setupVac1of2, dose: "1/2")
		
		viewQRCodes(of: .vaccination)
		assertInternationalVaccinationQR(of: newVac, dose: "3/3", for: person)
		viewPreviousQR()
		assertInternationalVaccinationQR(of: setupVac2of2, dose: "2/2", for: setupPerson)
		viewPreviousQR(hidden: true)
		assertInternationalVaccinationQR(of: setupVac1of2, dose: "1/2", for: setupPerson)
		backToOverview()
	}
	
	private func assertReplacedVaccination(for person: Person) {
		assertInternationalVaccination(of: newVac, dose: "1/1")
		
		viewQRCode(of: .vaccination)
		assertInternationalVaccinationQR(of: newVac, dose: "1/1", for: person)
		backToOverview()
	}
	
	private func assertSetupVaccinationRemoved() {
		assertRemovedCertificates(events: [setupVac1of2, setupVac2of2])
	}
	
	private func assertNewVaccinationRemoved() {
		assertRemovedCertificates(events: [newVac])
	}
}
