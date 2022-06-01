/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

@testable import CTR
import XCTest
import Nimble

class WalletManagerTests: XCTestCase {

	private var sut: WalletManager!
	private var dataStoreManager: DataStoreManaging!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		
		dataStoreManager = DataStoreManager(.inMemory, logHandler: LogHandlerSpy())
		sut = WalletManager(dataStoreManager: dataStoreManager, logHandler: LogHandlerSpy())
	}

	func test_initializer() {

		// Given
		var wallet: Wallet?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			// When
			wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context)
		}

		// Then
		expect(wallet).toEventuallyNot(beNil())
		expect(wallet?.label).toEventually(equal(WalletManager.walletName))
	}

	func test_initializer_withExistingWallet() {

		// Given
		var wallet: Wallet?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			// Delete the one created by the initializer in the setup()
			for element in WalletModel.listAll(managedContext: context) {
				context.delete(element)
			}
			let exitingWallet = WalletModel.create(label: WalletManager.walletName, managedContext: context)

			// When
			sut = WalletManager(dataStoreManager: dataStoreManager, logHandler: LogHandlerSpy())
			wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context)

			// Then
			expect(wallet) == exitingWallet
		}
		expect(wallet).toEventuallyNot(beNil())
	}

	func test_storeEventGroup() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())

		// When
		let result = sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			issuedAt: Date()
		)

		// Then
		expect(result) == true
		expect(wallet?.eventGroups).to(haveCount(1))
	}
	
	func test_storeEventGroup_cantStoreTwice() throws {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		let json = try XCTUnwrap("test_storeEventGroup_cantStoreTwice".data(using: .utf8))

		// When
		let result1 = sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: json,
			issuedAt: now
		)
		let result2 = sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: json,
			issuedAt: now
		)

		// Then
		expect(result1) == true
		expect(result2) == true
		expect(wallet?.eventGroups).to(haveCount(1))
	}

	func test_removeExistingEventGroups_withProviderIdentifier() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		sut.removeExistingEventGroups(type: .vaccination, providerIdentifier: "CoronaCheck")

		// Then
		expect(wallet?.eventGroups).to(beEmpty())
	}

	func test_removeExistingEventGroups_otherProviderIdentifier() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "Other Provider",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		sut.removeExistingEventGroups(type: .vaccination, providerIdentifier: "CoronaCheck")

		// Then
		expect(wallet?.eventGroups).to(haveCount(1))
	}

	func test_removeExistingEventGroups_otherType() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		sut.storeEventGroup(
			.test,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		sut.removeExistingEventGroups(type: .vaccination, providerIdentifier: "CoronaCheck")

		// Then
		expect(wallet?.eventGroups).to(haveCount(1))
	}

	func test_removeAllEventGroups() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		sut.storeEventGroup(
			.test,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			issuedAt: Date()
		)
		sut.storeEventGroup(
			.test,
			providerIdentifier: "Other Provider",
			jsonData: Data(),
			issuedAt: Date()
		)
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GGD",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		sut.removeExistingEventGroups()

		// Then
		expect(wallet?.eventGroups).to(haveCount(0))
	}

	func test_listEventGroups() {

		// Given
		sut.storeEventGroup(
			.test,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			issuedAt: Date()
		)
		sut.storeEventGroup(
			.test,
			providerIdentifier: "Other Provider",
			jsonData: Data(),
			issuedAt: Date()
		)
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GGD",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		let list = sut.listEventGroups()

		// Then
		expect(list).to(haveCount(3))
	}

	func test_fetchSignedEvents_noEvents() {

		// Given

		// When
		let signedEvents = sut.fetchSignedEvents()

		// Then
		expect(signedEvents).to(beEmpty())
	}

	func test_fetchSignedEvents_oneEvent() {

		// Given
		sut.storeEventGroup(
			.test,
			providerIdentifier: "CoronaCheck",
			jsonData: Data("test".utf8),
			issuedAt: Date()
		)

		// When
		let signedEvents = sut.fetchSignedEvents()

		// Then
		expect(signedEvents).toNot(beEmpty())
		expect(signedEvents).to(contain("test"))
	}

	func test_fetchSignedEvents_twoEvents() {

		// Given
		sut.storeEventGroup(
			.test,
			providerIdentifier: "CoronaCheck",
			jsonData: Data("test".utf8),
			issuedAt: Date()
		)
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: Data("vaccination".utf8),
			issuedAt: Date()
		)

		// When
		let signedEvents = sut.fetchSignedEvents()

		// Then
		expect(signedEvents).toNot(beEmpty())
		expect(signedEvents).to(contain("test"))
		expect(signedEvents).to(contain("vaccination"))
	}

	func test_hasEventGroup_vaccination() {

		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GGD",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		let hasEventGroup = sut.hasEventGroup(type: "vaccination", providerIdentifier: "GGD")

		// Then
		expect(hasEventGroup) == true
	}

	func test_hasEventGroup_recovery() {

		// Given
		sut.storeEventGroup(
			.recovery,
			providerIdentifier: "DCC",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		let hasEventGroup = sut.hasEventGroup(type: "recovery", providerIdentifier: EventFlow.paperproofIdentier)

		// Then
		expect(hasEventGroup) == true
	}
	
	func test_expireEventGroups_noEvents() {
		
		// Given
		// When
		sut.expireEventGroups(vaccinationValidity: 0, recoveryValidity: 0, testValidity: 0, vaccinationAssessmentValidity: 0)
		
		// Then
		expect(self.sut.listEventGroups()).to(haveCount(0))
	}
	
	func test_expireEventGroups_oneVaccination_notExpired() {
		
		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		// When
		sut.expireEventGroups(vaccinationValidity: 11, recoveryValidity: nil, testValidity: nil, vaccinationAssessmentValidity: nil)
		
		// Then
		expect(self.sut.listEventGroups()).to(haveCount(1))
	}
	
	func test_expireEventGroups_oneVaccination_expired() {
		
		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		// When
		sut.expireEventGroups(vaccinationValidity: 9, recoveryValidity: nil, testValidity: nil, vaccinationAssessmentValidity: nil)
		
		// Then
		expect(self.sut.listEventGroups()).to(haveCount(0))
	}
	
	func test_expireEventGroups_oneVaccination_expired_oneVaccination_notExpired() {
		
		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CC",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(20 * hours * ago)
		)
		
		// When
		sut.expireEventGroups(vaccinationValidity: 15, recoveryValidity: nil, testValidity: nil, vaccinationAssessmentValidity: nil)
		
		// Then
		expect(self.sut.listEventGroups()).to(haveCount(1))
	}
	
	func test_expireEventGroups_oneVaccination_notExpired_oneRecovery_notExpired_oneTest_oneVaccinationAssessment_notExpired() {
		
		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		sut.storeEventGroup(
			.recovery,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		sut.storeEventGroup(
			.test,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		sut.storeEventGroup(
			.vaccinationassessment,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		// When
		sut.expireEventGroups(vaccinationValidity: 15, recoveryValidity: 15, testValidity: 15, vaccinationAssessmentValidity: 15)
		
		// Then
		expect(self.sut.listEventGroups()).to(haveCount(4))
	}
	
	func test_expireEventGroups_oneVaccination_expired_oneRecovery_notExpired_oneTest_notExpired() {
		
		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		sut.storeEventGroup(
			.recovery,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		sut.storeEventGroup(
			.test,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		// When
		sut.expireEventGroups(vaccinationValidity: 5, recoveryValidity: 15, testValidity: 15, vaccinationAssessmentValidity: nil)
		
		// Then
		expect(self.sut.listEventGroups()).to(haveCount(2))
	}
	
	func test_expireEventGroups_oneVaccination_expired_oneRecovery_expired_oneTest_notExpired() {
		
		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		sut.storeEventGroup(
			.recovery,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		sut.storeEventGroup(
			.test,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		// When
		sut.expireEventGroups(vaccinationValidity: 5, recoveryValidity: 5, testValidity: 15, vaccinationAssessmentValidity: nil)
		
		// Then
		expect(self.sut.listEventGroups()).to(haveCount(1))
	}
	
	func test_expireEventGroups_oneVaccination_expired_oneRecovery_expired_oneTest_expired_oneVaccinationAssessment_expired() {
		
		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		sut.storeEventGroup(
			.recovery,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		sut.storeEventGroup(
			.test,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		sut.storeEventGroup(
			.vaccinationassessment,
			providerIdentifier: "GDD",
			jsonData: Data(),
			issuedAt: Date().addingTimeInterval(10 * hours * ago)
		)
		
		// When
		sut.expireEventGroups(vaccinationValidity: 5, recoveryValidity: 5, testValidity: 5, vaccinationAssessmentValidity: 5)
		
		// Then
		expect(self.sut.listEventGroups()).to(beEmpty())
	}
	
	func test_removeExistingGreenCards_noGreenCards() {
		
		// Given
		// When
		sut.removeExistingGreenCards()
		
		// Then
		expect(self.sut.listGreenCards()).to(beEmpty())
	}
	
	func test_removeExistingGreenCards_oneGreenCard() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedCreateCredentialResult = .failure(CryptoError.unknown)
		_ = sut.storeDomesticGreenCard(
			RemoteGreenCards.DomesticGreenCard.fakeVaccinationGreenCardExpiresIn30Days,
			cryptoManager: environmentSpies.cryptoManagerSpy
		)
		
		// When
		sut.removeExistingGreenCards()
		
		// Then
		expect(self.sut.listGreenCards()).to(beEmpty())
	}
	
	func test_removeExistingGreenCards_twoGreenCards() {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedCreateCredentialResult = .failure(CryptoError.unknown)
		_ = sut.storeDomesticGreenCard(
			RemoteGreenCards.DomesticGreenCard.fakeVaccinationGreenCardExpiresIn30Days,
			cryptoManager: environmentSpies.cryptoManagerSpy
		)
		_ = sut.storeDomesticGreenCard(
			RemoteGreenCards.DomesticGreenCard.fakeVaccinationGreenCardExpiresIn30Days,
			cryptoManager: environmentSpies.cryptoManagerSpy
		)
		
		// When
		sut.removeExistingGreenCards()
		
		// Then
		expect(self.sut.listGreenCards()).to(beEmpty())
	}
	
	func test_storeDomesticGreenCard_vaccination() throws {
		
		// Given
		let domesticCredentials: [DomesticCredential] = [
			DomesticCredential(
				credential: Data("test".utf8),
				attributes: DomesticCredentialAttributes.sample(category: "3")
			)
		]
		let encodedDomesticCredentials = try JSONEncoder().encode(domesticCredentials)
		let jsonString = try XCTUnwrap( String(data: encodedDomesticCredentials, encoding: .utf8))
		let jsonData = Data(jsonString.utf8)
		environmentSpies.cryptoManagerSpy.stubbedCreateCredentialResult = .success(jsonData)
		
		// When
		let success = sut.storeDomesticGreenCard(
			RemoteGreenCards.DomesticGreenCard.fakeVaccinationGreenCardExpiresIn30Days,
			cryptoManager: environmentSpies.cryptoManagerSpy
		)
		
		// Then
		expect(success) == true
		expect(self.sut.listGreenCards()).to(haveCount(1))
		expect(self.sut.listOrigins(type: .vaccination)).to(haveCount(1))
		expect(self.sut.listOrigins(type: .test)).to(beEmpty())
		expect(self.sut.listOrigins(type: .recovery)).to(beEmpty())
		expect(self.sut.listOrigins(type: .vaccinationassessment)).to(beEmpty())
		expect(self.sut.listGreenCards().first?.credentials).to(haveCount(1))
		// Credential Valid From should be now for a CTB
		expect(self.sut.listGreenCards().first?.castCredentials()?.first?.validFrom) != Date(timeIntervalSince1970: 0)
	}
	
	func test_storeDomesticGreenCard_recovery() throws {
		
		// Given
		let domesticCredentials: [DomesticCredential] = [
			DomesticCredential(
				credential: Data("test".utf8),
				attributes: DomesticCredentialAttributes.sample(category: "3")
			)
		]
		let encodedDomesticCredentials = try JSONEncoder().encode(domesticCredentials)
		let jsonString = try XCTUnwrap( String(data: encodedDomesticCredentials, encoding: .utf8))
		let jsonData = Data(jsonString.utf8)
		environmentSpies.cryptoManagerSpy.stubbedCreateCredentialResult = .success(jsonData)
		
		// When
		let success = sut.storeDomesticGreenCard(
			RemoteGreenCards.DomesticGreenCard.fakeRecoveryGreenCardExpiresIn30Days,
			cryptoManager: environmentSpies.cryptoManagerSpy
		)
		
		// Then
		expect(success) == true
		expect(self.sut.listGreenCards()).to(haveCount(1))
		expect(self.sut.listOrigins(type: .vaccination)).to(beEmpty())
		expect(self.sut.listOrigins(type: .test)).to(beEmpty())
		expect(self.sut.listOrigins(type: .recovery)).to(haveCount(1))
		expect(self.sut.listOrigins(type: .vaccinationassessment)).to(beEmpty())
		expect(self.sut.listGreenCards().first?.credentials).to(haveCount(1))
	}
	
	func test_storeDomesticGreenCard_vaccinationAssessment() throws {
		
		// Given
		let domesticCredentials: [DomesticCredential] = [
			DomesticCredential(
				credential: Data("test".utf8),
				attributes: DomesticCredentialAttributes.sample(category: "3")
			)
		]
		let encodedDomesticCredentials = try JSONEncoder().encode(domesticCredentials)
		let jsonString = try XCTUnwrap( String(data: encodedDomesticCredentials, encoding: .utf8))
		let jsonData = Data(jsonString.utf8)
		environmentSpies.cryptoManagerSpy.stubbedCreateCredentialResult = .success(jsonData)
		
		// When
		let success = sut.storeDomesticGreenCard(
			RemoteGreenCards.DomesticGreenCard.fakeVaccinationAssessmentGreenCardExpiresIn14Days,
			cryptoManager: environmentSpies.cryptoManagerSpy
		)
		
		// Then
		expect(success) == true
		expect(self.sut.listGreenCards()).to(haveCount(1))
		expect(self.sut.listOrigins(type: .vaccination)).to(beEmpty())
		expect(self.sut.listOrigins(type: .test)).to(beEmpty())
		expect(self.sut.listOrigins(type: .recovery)).to(beEmpty())
		expect(self.sut.listOrigins(type: .vaccinationassessment)).to(haveCount(1))
		expect(self.sut.listGreenCards().first?.credentials).to(haveCount(1))
	}
	
	func test_storeInternationalGreenCard_vaccination() throws {
		
		// Given
		let internationalGreenCard = RemoteGreenCards.EuGreenCard(
			origins: [RemoteGreenCards.Origin.fakeVaccinationOrigin],
			credential: "test_storeInternationalGreenCard_vaccination"
		)
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination(
			dcc: EuCredentialAttributes.DigitalCovidCertificate.sampleWithVaccine(doseNumber: 1, totalDose: 2)
		)
		
		// When
		let success = sut.storeEuGreenCard(internationalGreenCard, cryptoManager: environmentSpies.cryptoManagerSpy)
		
		// Then
		expect(success) == true
		expect(self.sut.listGreenCards()).to(haveCount(1))
		expect(self.sut.listOrigins(type: .vaccination)).to(haveCount(1))
		expect(self.sut.listOrigins(type: .test)).to(beEmpty())
		expect(self.sut.listOrigins(type: .recovery)).to(beEmpty())
		expect(self.sut.listOrigins(type: .vaccinationassessment)).to(beEmpty())
		expect(self.sut.listGreenCards().first?.credentials).to(haveCount(1))
		// Credential Valid From should be epoch for a DCC (immediately valid)
		expect(self.sut.listGreenCards().first?.castCredentials()?.first?.validFrom) == Date(timeIntervalSince1970: 0)
	}

	func test_storeInternationalGreenCard_recovery() throws {
		
		// Given
		let internationalGreenCard = RemoteGreenCards.EuGreenCard(
			origins: [RemoteGreenCards.Origin.fakeRecoveryOriginExpiringIn30Days],
			credential: "test_storeInternationalGreenCard_recovery"
		)
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination(
			dcc: EuCredentialAttributes.DigitalCovidCertificate.sampleWithVaccine(doseNumber: 1, totalDose: 2)
		)
		
		// When
		let success = sut.storeEuGreenCard(internationalGreenCard, cryptoManager: environmentSpies.cryptoManagerSpy)
		
		// Then
		expect(success) == true
		expect(self.sut.listGreenCards()).to(haveCount(1))
		expect(self.sut.listOrigins(type: .vaccination)).to(beEmpty())
		expect(self.sut.listOrigins(type: .test)).to(beEmpty())
		expect(self.sut.listOrigins(type: .recovery)).to(haveCount(1))
		expect(self.sut.listGreenCards().first?.credentials).to(haveCount(1))
	}
	
	func test_storeInternationalGreenCard_twoVaccinations() throws {
		
		// Given
		let internationalGreenCard = RemoteGreenCards.EuGreenCard(
			origins: [RemoteGreenCards.Origin.fakeVaccinationOriginExpiringIn30Days],
			credential: "test_storeInternationalGreenCard_twoVaccinations"
		)
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination(
			dcc: EuCredentialAttributes.DigitalCovidCertificate.sampleWithVaccine(doseNumber: 1, totalDose: 2)
		)
		
		// When
		_ = sut.storeEuGreenCard(internationalGreenCard, cryptoManager: environmentSpies.cryptoManagerSpy)
		_ = sut.storeEuGreenCard(internationalGreenCard, cryptoManager: environmentSpies.cryptoManagerSpy)
		
		// Then
		expect(self.sut.listGreenCards()).to(haveCount(2))
		expect(self.sut.listOrigins(type: .vaccination)).to(haveCount(2))
		expect(self.sut.listOrigins(type: .test)).to(beEmpty())
		expect(self.sut.listOrigins(type: .recovery)).to(beEmpty())
		expect(self.sut.listGreenCards().first?.credentials).to(haveCount(1))
	}
}
