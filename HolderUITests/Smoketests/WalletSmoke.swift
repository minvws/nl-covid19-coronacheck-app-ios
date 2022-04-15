/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class WalletSmoke: BaseTest {
	
	func test_emptyWallet() {
		viewWallet()
		
		assertNoCertificatesInWallet()
	}
	
	func test_vacP1() {
		let person = TestData.vacP1
		addVaccinationCertificate(for: person)
		
		let vac = storeRetrievedCertificateDetails()
		addRetrievedCertificateToApp()
		
		viewWallet()
		assertWalletItem(ofType: .vaccination, with: vac)
	}
	
	func test_vacP3() {
		let person = TestData.vacP3
		addVaccinationCertificate(for: person)
		
		let vac0 = storeRetrievedCertificateDetails(index: 0)
		let vac1 = storeRetrievedCertificateDetails(index: 1)
		let vac2 = storeRetrievedCertificateDetails(index: 2)
		addRetrievedCertificateToApp()
		
		viewWallet()
		assertWalletItem(ofType: .vaccination, atIndex: 0, with: vac0)
		assertWalletItem(ofType: .vaccination, atIndex: 1, with: vac1)
		assertWalletItem(ofType: .vaccination, atIndex: 2, with: vac2)
	}
	
	func test_posPcrBeforeP1() {
		let person = TestData.posPcrBeforeP1
		addVaccinationCertificate(for: person, combinedWithPositiveTest: true)
		
		let vac = storeRetrievedCertificateDetails(index: 0)
		let pos = storeRetrievedCertificateDetails(index: 1)
		addRetrievedCertificateToApp()
		assertCombinedVaccinationAndRecoveryRetrieval()
		
		viewWallet()
		assertWalletItem(ofType: .positive, with: pos)
		assertWalletItem(ofType: .vaccination, with: vac)
	}
	
	func test_encodingChinese() {
		let person = TestData.encodingChinese
		addVaccinationCertificate(for: person, combinedWithPositiveTest: true)
		let vac0 = storeRetrievedCertificateDetails(index: 0)
		let vac1 = storeRetrievedCertificateDetails(index: 1)
		let pos = storeRetrievedCertificateDetails(index: 2)
		addRetrievedCertificateToApp()
		assertCombinedVaccinationAndRecoveryRetrieval()
		
		addTestCertificateFromGGD(for: person)
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
		addTestCertificateFromGGD(for: person)
		let neg = storeRetrievedCertificateDetails()
		addRetrievedCertificateToApp()
		
		addVaccinationCertificate(for: person)
		let vac = storeRetrievedCertificateDetails()
		addRetrievedCertificateToApp()
		assertCertificateIsOnlyValidInternationally()
		
		viewWallet()
		assertWalletItem(ofType: .negative, with: neg)
		assertWalletItem(ofType: .vaccination, with: vac)
	}
	
	func test_vacJ1DifferentEverything_ReplaceSetup() {
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
}
