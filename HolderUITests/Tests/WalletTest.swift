/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class WalletTest: BaseTest {
	
	func test_vacP3() {
		let person = TestData.vacP3
		addVaccinationCertificate(for: person.bsn)
		
		let vac0 = storeRetrievedCertificateDetails(atIndex: 0)
		let vac1 = storeRetrievedCertificateDetails(atIndex: 1)
		let vac2 = storeRetrievedCertificateDetails(atIndex: 2)
		addRetrievedCertificateToApp()
		
		viewWallet()
		assertWalletItem(ofType: .vaccination, atIndex: 0, with: vac0)
		assertWalletItem(ofType: .vaccination, atIndex: 1, with: vac1)
		assertWalletItem(ofType: .vaccination, atIndex: 2, with: vac2)
	}
	
	func test_posPcrBeforeP1() {
		let person = TestData.posPcrBeforeP1
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		
		let vac = storeRetrievedCertificateDetails(atIndex: 0)
		let pos = storeRetrievedCertificateDetails(atIndex: 1)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		viewWallet()
		assertWalletItem(ofType: .positive, with: pos)
		assertWalletItem(ofType: .vaccination, with: vac)
	}
	
	func test_encodingChinese() {
		let person = TestData.encodingChinese
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		let vac0 = storeRetrievedCertificateDetails(atIndex: 0)
		let vac1 = storeRetrievedCertificateDetails(atIndex: 1)
		let pos = storeRetrievedCertificateDetails(atIndex: 2)
		addRetrievedCertificateToApp()
		assertHintForVaccinationAndRecoveryCertificate()
		
		addTestCertificateFromGGD(for: person.bsn)
		let neg = storeRetrievedCertificateDetails()
		addRetrievedCertificateToApp()
		
		viewWallet()
		assertWalletItem(ofType: .vaccination, atIndex: 0, with: vac0)
		assertWalletItem(ofType: .vaccination, atIndex: 1, with: vac1)
		assertWalletItem(ofType: .positive, with: pos)
		assertWalletItem(ofType: .negative, with: neg)
	}
	
	func test_negPcrP1() {
		let person = TestData.negPcrP1
		addTestCertificateFromGGD(for: person.bsn)
		let neg = storeRetrievedCertificateDetails()
		addRetrievedCertificateToApp()
		
		addVaccinationCertificate(for: person.bsn)
		let vac = storeRetrievedCertificateDetails()
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		viewWallet()
		assertWalletItem(ofType: .negative, with: neg)
		assertWalletItem(ofType: .vaccination, with: vac)
	}
	
	func test_keepSetup() {
		let setup = TestData.vacP2DifferentSetupSituation
		addVaccinationCertificate(for: setup.bsn)
		let vac0 = storeRetrievedCertificateDetails(atIndex: 0)
		let vac1 = storeRetrievedCertificateDetails(atIndex: 1)
		addRetrievedCertificateToApp()
		
		let person = TestData.vacJ1DifferentEverythingReplaces
		addVaccinationCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		replaceExistingCertificate(false)
		
		viewWallet()
		assertAmountOfWalletItems(ofType: .vaccination, is: 2)
		assertWalletItem(ofType: .vaccination, atIndex: 0, with: vac0)
		assertWalletItem(ofType: .vaccination, atIndex: 1, with: vac1)
	}
	
	func test_removePositiveTest() {
		let person = TestData.posPcr
		addRecoveryCertificate(for: person.bsn)
		addRetrievedCertificateToApp()
		
		viewWallet()
		deleteItemFromWallet()
		assertNoEventsInWallet()
		
		returnFromWalletToOverview()
		assertNoCertificateRetrieved()
	}
	
	func test_removeNegativeTest() {
		let person = TestData.negPcr
		addTestCertificateFromGGD(for: person.bsn)
		addRetrievedCertificateToApp()
		
		viewWallet()
		deleteItemFromWallet()
		assertNoEventsInWallet()
		
		returnFromWalletToOverview()
		assertNoCertificateRetrieved()
	}
	
	func test_removeSeparateEvents() {
		let person = TestData.posPcrP1
		addVaccinationCertificate(for: person.bsn, combinedWithPositiveTest: true)
		addRetrievedCertificateToApp()
		assertHintForInternationalVaccinationAndRecoveryCertificate()
		
		viewWallet()
		assertAmountOfWalletItems(ofType: .positive, is: 1)
		assertAmountOfWalletItems(ofType: .vaccination, is: 1)
		
		deleteItemFromWallet()
		assertAmountOfWalletItems(ofType: .positive, is: 0)
		assertAmountOfWalletItems(ofType: .vaccination, is: 1)
		
		deleteItemFromWallet()
		assertNoEventsInWallet()
		
		returnFromWalletToOverview()
		assertNoCertificateRetrieved()
	}
}
