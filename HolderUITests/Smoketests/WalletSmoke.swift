/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class WalletSmoke: BaseTest {
	
	func test_emptyWallet() {
		viewWallet()
		
		assertNoEventsInWallet()
	}
	
	func test_vacP1() {
		let person = TestData.vacP1
		addVaccinationCertificate(for: person)
		
		let vac = storeRetrievedCertificateDetails()
		addRetrievedCertificateToApp()
		
		viewWallet()
		assertWalletItem(ofType: .vaccination, with: vac)
	}
	
	func test_posPcr() {
		let person = TestData.posPcrBeforeP1
		addRecoveryCertificate(for: person)
		let pos = storeRetrievedCertificateDetails()
		addRetrievedCertificateToApp()
		
		viewWallet()
		assertWalletItem(ofType: .positive, with: pos)
	}
	
	func test_negPcr() {
		let person = TestData.negPcr
		addTestCertificateFromGGD(for: person)
		let neg = storeRetrievedCertificateDetails()
		addRetrievedCertificateToApp()
		
		viewWallet()
		assertWalletItem(ofType: .negative, with: neg)
	}
	
	func test_replaceSetup() {
		let setup = TestData.vacP2DifferentSetupSituation
		addVaccinationCertificate(for: setup)
		addRetrievedCertificateToApp()
		
		let person = TestData.vacJ1DifferentEverythingReplaces
		addVaccinationCertificate(for: person)
		let vac = storeRetrievedCertificateDetails()
		addRetrievedCertificateToApp()
		replaceExistingCertificate(true)
		
		viewWallet()
		assertAmountOfWalletItems(ofType: .vaccination, is: 1)
		assertWalletItem(ofType: .vaccination, with: vac)
	}
	
	func test_removeVaccination() {
		let person = TestData.vacP1
		addVaccinationCertificate(for: person)
		addRetrievedCertificateToApp()
		
		viewWallet()
		deleteItemFromWallet()
		assertNoEventsInWallet()
		
		returnFromWalletToOverview()
		assertNoCertificateRetrieved()
	}
}
