/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class ResetSmoke: BaseTest {
	
	let person = TestData.vacP3
	
	func test_resetBlankApp() {
		resetApp()
		assertNoCertificateRetrieved()
	}
	
	func test_resetData() {
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		resetApp()
		
		assertNoCertificateRetrieved()
		
		viewWallet()
		assertNoEventsInWallet()
	}
	
	func test_dontResetData() {
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		resetApp(confirm: false)
		
		assertValidDutchVaccinationCertificate(doses: person.dose, validFromOffsetInDays: person.vacFrom)
		assertValidInternationalVaccinationCertificate(doses: person.doseIntl)
		
		viewWallet()
		assertAmountOfWalletItems(ofType: .vaccination, is: 3)
	}
}
