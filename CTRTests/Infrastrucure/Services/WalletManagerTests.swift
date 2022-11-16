/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

@testable import CTR
@testable import Transport
@testable import Shared
import XCTest
import Nimble

class WalletManagerTests: XCTestCase {

	private var sut: WalletManager!
	private var dataStoreManager: DataStoreManaging!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		
		dataStoreManager = DataStoreManager(.inMemory, loadPersistentStoreCompletion: { _ in })
		sut = WalletManager(dataStoreManager: dataStoreManager)
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
			let exitingWallet = Wallet(label: WalletManager.walletName, managedContext: context)

			// When
			sut = WalletManager(dataStoreManager: dataStoreManager)
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
		let eventGroup = sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
		)

		// Then
		expect(eventGroup) != nil
		expect(wallet?.eventGroups).to(haveCount(1))
	}
	
	func test_removeDraftEventGroups() {
		
		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
		)
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: true
		)

		// When
		sut.removeDraftEventGroups()

		// Then
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		expect(wallet?.eventGroups).to(haveCount(1))
	}

	func test_removeExistingEventGroups_withProviderIdentifier() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
		)

		// When
		let result = sut.removeExistingEventGroups(type: .vaccination, providerIdentifier: "CoronaCheck")

		// Then
		expect(wallet?.eventGroups).to(beEmpty())
		expect(result) == 1
	}

	func test_removeExistingEventGroups_otherProviderIdentifier() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "Other Provider",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
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
			.test(.ggd),
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
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
			.test(.ggd),
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
		)
		sut.storeEventGroup(
			.test(.ggd),
			providerIdentifier: "Other Provider",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
		)
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GGD",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
		)

		// When
		sut.removeExistingEventGroups()

		// Then
		expect(wallet?.eventGroups).to(haveCount(0))
	}

	func test_listEventGroups() {

		// Given
		sut.storeEventGroup(
			.test(.ggd),
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
		)
		sut.storeEventGroup(
			.test(.ggd),
			providerIdentifier: "Other Provider",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
		)
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GGD",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
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

	func test_fetchSignedEvents_invalidData() {

		// Given
		sut.storeEventGroup(
			.test(.ggd),
			providerIdentifier: "CoronaCheck",
			jsonData: Data("WRONG".utf8),
			expiryDate: nil,
			isDraft: false
		)

		// When
		let signedEvents = sut.fetchSignedEvents()

		// Then
		expect(signedEvents).to(beEmpty())
	}
	
	func test_fetchSignedEvents_oneEvent() {

		// Given
		sut.storeEventGroup(
			.test(.ggd),
			providerIdentifier: "CoronaCheck",
			jsonData: Data("{\"payload\": \"test\"}".utf8),
			expiryDate: nil,
			isDraft: false
		)

		// When
		let signedEvents = sut.fetchSignedEvents()

		// Then
		expect(signedEvents).toNot(beEmpty())
		expect(signedEvents).to(haveCount(1))
		expect(signedEvents.first).to(contain("test"))
	}

	func test_fetchSignedEvents_twoEvents() {

		// Given
		sut.storeEventGroup(
			.test(.ggd),
			providerIdentifier: "CoronaCheck",
			jsonData: Data("{\"payload\": \"test\"}".utf8),
			expiryDate: nil,
			isDraft: false
		)
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: Data("{\"payload\": \"vaccination\"}".utf8),
			expiryDate: nil,
			isDraft: false
		)

		// When
		let signedEvents = sut.fetchSignedEvents()

		// Then
		expect(signedEvents).toNot(beEmpty())
		expect(signedEvents).to(haveCount(2))
		expect(signedEvents.first).to(contain("test"))
		expect(signedEvents.last).to(contain("vaccination"))
	}
	
	func test_expireEventGroups_noEvents() {
		
		// Given
		
		// When
		sut.expireEventGroups(forDate: now)
		
		// Then
		expect(self.sut.listEventGroups()).to(haveCount(0))
	}
	
	func test_expireEventGroups_oneVaccination_notExpired() {

		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * days),
			isDraft: false
		)

		// When
		sut.expireEventGroups(forDate: now)

		// Then
		expect(self.sut.listEventGroups()).to(haveCount(1))
	}

	func test_expireEventGroups_oneVaccination_expired() {

		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours * ago),
			isDraft: false
		)

		// When
		sut.expireEventGroups(forDate: now)

		// Then
		expect(self.sut.listEventGroups()).to(haveCount(0))
	}

	func test_expireEventGroups_oneVaccination_expired_oneVaccination_notExpired() {

		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours * ago),
			isDraft: false
		)

		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CC",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours),
			isDraft: false
		)

		// When
		sut.expireEventGroups(forDate: now)

		// Then
		expect(self.sut.listEventGroups()).to(haveCount(1))
	}

	func test_expireEventGroups_oneVaccination_notExpired_oneRecovery_notExpired_oneTest_oneVaccinationAssessment_notExpired() {

		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours),
			isDraft: false
		)

		sut.storeEventGroup(
			.recovery,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours),
			isDraft: false
		)

		sut.storeEventGroup(
			.test(.ggd),
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours),
			isDraft: false
		)

		sut.storeEventGroup(
			.vaccinationassessment,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours),
			isDraft: false
		)

		// When
		sut.expireEventGroups(forDate: now)

		// Then
		expect(self.sut.listEventGroups()).to(haveCount(4))
	}

	func test_expireEventGroups_oneVaccination_expired_oneRecovery_notExpired_oneTest_notExpired() {

		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours * ago),
			isDraft: false
		)

		sut.storeEventGroup(
			.recovery,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours),
			isDraft: false
		)

		sut.storeEventGroup(
			.test(.ggd),
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours),
			isDraft: false
		)

		// When
		sut.expireEventGroups(forDate: now)

		// Then
		expect(self.sut.listEventGroups()).to(haveCount(2))
	}

	func test_expireEventGroups_oneVaccination_expired_oneRecovery_expired_oneTest_notExpired() {

		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours * ago),
			isDraft: false
		)

		sut.storeEventGroup(
			.recovery,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours * ago),
			isDraft: false
		)

		sut.storeEventGroup(
			.test(.ggd),
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours),
			isDraft: false
		)

		// When
		sut.expireEventGroups(forDate: now)

		// Then
		expect(self.sut.listEventGroups()).to(haveCount(1))
	}

	func test_expireEventGroups_oneVaccination_oneRecovery_oneTest_oneVaccinationAssessment_allExpired() {

		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours * ago),
			isDraft: false
		)

		sut.storeEventGroup(
			.recovery,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours * ago),
			isDraft: false
		)

		sut.storeEventGroup(
			.test(.ggd),
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours * ago),
			isDraft: false
		)

		sut.storeEventGroup(
			.vaccinationassessment,
			providerIdentifier: "GDD",
			jsonData: Data(),
			expiryDate: now.addingTimeInterval(10 * hours * ago),
			isDraft: false
		)

		// When
		sut.expireEventGroups(forDate: now)

		// Then
		expect(self.sut.listEventGroups()).to(beEmpty())
	}
	
	func test_removeEventGroup() throws {
		
		// Given
		var wallet: Wallet?
		var eventGroup: EventGroup?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet,
			   let json = "test_removeEventGroup".data(using: .utf8) {

				// When
				eventGroup = EventGroup(
					type: EventMode.test(.commercial),
					providerIdentifier: "CoronaCheck",
					expiryDate: nil,
					jsonData: json,
					wallet: unwrappedWallet,
					isDraft: false,
					managedContext: context
				)
			}
		}
		
		// When
		let objectId = try XCTUnwrap(eventGroup?.objectID)
		let result = sut.removeEventGroup(objectId)
		
		// Then
		expect(result.isSuccess) == true
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
	
	func test_removeExpiredGreenCards_noGreenCards() {
		
		// Given
		
		// When
		let result = sut.removeExpiredGreenCards(forDate: now)
		
		// Then
		expect(result).to(beEmpty())
	}
	
	func test_removeExpiredGreenCards_oneValidGreenCard() throws {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedCreateCredentialResult = .success(sampleJSONData)
		_ = sut.storeDomesticGreenCard(
			RemoteGreenCards.DomesticGreenCard.fakeVaccinationGreenCardExpiresIn30Days,
			cryptoManager: environmentSpies.cryptoManagerSpy
		)

		// When
		let result = sut.removeExpiredGreenCards(forDate: now)
		
		// Then
		expect(result).to(beEmpty())
	}
	
	func test_removeExpiredGreenCards_oneExpiredGreenCard() throws {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedCreateCredentialResult = .success(sampleJSONData)
		_ = sut.storeDomesticGreenCard(
			RemoteGreenCards.DomesticGreenCard.fakeVaccinationGreenCardExpired30DaysAgo,
			cryptoManager: environmentSpies.cryptoManagerSpy
		)

		// When
		let result = sut.removeExpiredGreenCards(forDate: now)
		
		// Then
		expect(result.first?.greencardType) == "domestic"
		expect(result.first?.originType) == "vaccination"
	}
	
	func test_storeDomesticGreenCard_vaccination() throws {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedCreateCredentialResult = .success(sampleJSONData)
		
		// When
		let success = sut.storeDomesticGreenCard(
			RemoteGreenCards.DomesticGreenCard.fakeVaccinationGreenCardExpiresIn30Days,
			cryptoManager: environmentSpies.cryptoManagerSpy
		)
		
		// Then
		expect(success) == true
		expect(self.sut.listGreenCards()).to(haveCount(1))
		expect(self.sut.listGreenCards().first?.credentials).to(haveCount(1))
		// Credential Valid From should be now for a CTB
		expect(self.sut.listGreenCards().first?.castCredentials()?.first?.validFrom) != Date(timeIntervalSince1970: 0)
		expect(self.sut.listGreenCards().first?.castOrigins()?.first?.castHints()).to(haveCount(1))
	}
	
	func test_storeDomesticGreenCard_recovery() throws {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedCreateCredentialResult = .success(sampleJSONData)
		
		// When
		let success = sut.storeDomesticGreenCard(
			RemoteGreenCards.DomesticGreenCard.fakeRecoveryGreenCardExpiresIn30Days,
			cryptoManager: environmentSpies.cryptoManagerSpy
		)
		
		// Then
		expect(success) == true
		expect(self.sut.listGreenCards()).to(haveCount(1))
		expect(self.sut.listGreenCards().first?.credentials).to(haveCount(1))
	}
	
	func test_storeDomesticGreenCard_vaccinationAssessment() throws {
		
		// Given
		environmentSpies.cryptoManagerSpy.stubbedCreateCredentialResult = .success(sampleJSONData)
		
		// When
		let success = sut.storeDomesticGreenCard(
			RemoteGreenCards.DomesticGreenCard.fakeVaccinationAssessmentGreenCardExpiresIn14Days,
			cryptoManager: environmentSpies.cryptoManagerSpy
		)
		
		// Then
		expect(success) == true
		expect(self.sut.listGreenCards()).to(haveCount(1))
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
		expect(self.sut.listGreenCards().first?.credentials).to(haveCount(1))
		// Credential Valid From should be epoch for a DCC (immediately valid)
		expect(self.sut.listGreenCards().first?.castCredentials()?.first?.validFrom) == Date(timeIntervalSince1970: 0)
		expect(self.sut.listGreenCards().first?.castOrigins()?.first?.castHints()).to(haveCount(1))
	}

	func test_storeInternationalGreenCard_vaccination_failedCredential() throws {
		
		// Given
		let internationalGreenCard = RemoteGreenCards.EuGreenCard(
			origins: [RemoteGreenCards.Origin.fakeVaccinationOrigin],
			credential: "test_storeInternationalGreenCard_vaccination"
		)
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = nil
		
		// When
		let success = sut.storeEuGreenCard(internationalGreenCard, cryptoManager: environmentSpies.cryptoManagerSpy)
		
		// Then
		expect(success) == false
		expect(self.sut.listGreenCards()).to(haveCount(1))
		expect(self.sut.listGreenCards().first?.credentials).to(beEmpty())
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
		expect(self.sut.listGreenCards().first?.credentials).to(haveCount(1))
	}
	
	func test_updateEventGroup() throws {
		
		// Given
		sut.storeEventGroup(
			.test(.ggd),
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
		)
		let autoId = try XCTUnwrap(self.sut.listEventGroups().first?.uniqueIdentifier)
		
		// When
		sut.updateEventGroup(identifier: "\(autoId)", expiryDate: now)
		
		// Then
		expect(self.sut.listEventGroups()).to(haveCount(1))
		expect(self.sut.listEventGroups().first?.expiryDate) == now
	}
	
	func test_updateEventGroup_invalidIdentifier() {
		
		// Given
		sut.storeEventGroup(
			.test(.ggd),
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			expiryDate: nil,
			isDraft: false
		)
		
		// When
		sut.updateEventGroup(identifier: "wrongIdentifier", expiryDate: now)
		
		// Then
		expect(self.sut.listEventGroups()).to(haveCount(1))
		expect(self.sut.listEventGroups().first?.expiryDate) == nil
	}
	
	let sampleJSONData = Data("[{\"credential\":{\"signature\":{\"A\":\"test\",\"e\":\"test\",\"v\":\"test\",\"KeyshareP\":null},\"attributes\":[null,\"YBwIAgYmEqyuplqChoZaYQ==\",\"Yw==\",\"YQ==\",\"YmxsYmhgbmRgYQ==\",\"ZGk=\",\"hw==\",\"jw==\",\"AQ==\",\"Yw==\",\"Yw==\"]},\"attributes\":{\"birthDay\":\"\",\"birthMonth\":\"1\",\"category\":\"3\",\"credentialVersion\":\"3\",\"firstNameInitial\":\"C\",\"isPaperProof\":\"0\",\"isSpecimen\":\"1\",\"lastNameInitial\":\"G\",\"validForHours\":\"24\",\"validFrom\":\"1661407200\"}}]".utf8)
}
