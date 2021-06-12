/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest

class WalletManagerSpy: WalletManaging {

	required init(dataStoreManager: DataStoreManaging) {}

	var invokedStoreEventGroup = false
	var invokedStoreEventGroupCount = 0
	var invokedStoreEventGroupParameters: (type: EventType, providerIdentifier: String, signedResponse: SignedResponse, issuedAt: Date)?
	var invokedStoreEventGroupParametersList = [(type: EventType, providerIdentifier: String, signedResponse: SignedResponse, issuedAt: Date)]()
	var stubbedStoreEventGroupResult: Bool! = false

	func storeEventGroup(_ type: EventType, providerIdentifier: String, signedResponse: SignedResponse, issuedAt: Date) -> Bool {
		invokedStoreEventGroup = true
		invokedStoreEventGroupCount += 1
		invokedStoreEventGroupParameters = (type, providerIdentifier, signedResponse, issuedAt)
		invokedStoreEventGroupParametersList.append((type, providerIdentifier, signedResponse, issuedAt))
		return stubbedStoreEventGroupResult
	}

	var invokedFetchSignedEvents = false
	var invokedFetchSignedEventsCount = 0
	var stubbedFetchSignedEventsResult: [String]! = []

	func fetchSignedEvents() -> [String] {
		invokedFetchSignedEvents = true
		invokedFetchSignedEventsCount += 1
		return stubbedFetchSignedEventsResult
	}

	var invokedRemoveExistingEventGroups = false
	var invokedRemoveExistingEventGroupsCount = 0
	var invokedRemoveExistingEventGroupsParameters: (type: EventType, providerIdentifier: String)?
	var invokedRemoveExistingEventGroupsParametersList = [(type: EventType, providerIdentifier: String)]()

	func removeExistingEventGroups(type: EventType, providerIdentifier: String) {
		invokedRemoveExistingEventGroups = true
		invokedRemoveExistingEventGroupsCount += 1
		invokedRemoveExistingEventGroupsParameters = (type, providerIdentifier)
		invokedRemoveExistingEventGroupsParametersList.append((type, providerIdentifier))
	}

	var invokedRemoveExistingGreenCards = false
	var invokedRemoveExistingGreenCardsCount = 0

	func removeExistingGreenCards() {
		invokedRemoveExistingGreenCards = true
		invokedRemoveExistingGreenCardsCount += 1
	}

	var invokedStoreDomesticGreenCard = false
	var invokedStoreDomesticGreenCardCount = 0
	var invokedStoreDomesticGreenCardParameters: (remoteGreenCard: RemoteGreenCards.DomesticGreenCard, cryptoManager: CryptoManaging)?
	var invokedStoreDomesticGreenCardParametersList = [(remoteGreenCard: RemoteGreenCards.DomesticGreenCard, cryptoManager: CryptoManaging)]()
	var stubbedStoreDomesticGreenCardResult: Bool! = false

	func storeDomesticGreenCard(_ remoteGreenCard: RemoteGreenCards.DomesticGreenCard, cryptoManager: CryptoManaging) -> Bool {
		invokedStoreDomesticGreenCard = true
		invokedStoreDomesticGreenCardCount += 1
		invokedStoreDomesticGreenCardParameters = (remoteGreenCard, cryptoManager)
		invokedStoreDomesticGreenCardParametersList.append((remoteGreenCard, cryptoManager))
		return stubbedStoreDomesticGreenCardResult
	}

	var invokedStoreEuGreenCard = false
	var invokedStoreEuGreenCardCount = 0
	var invokedStoreEuGreenCardParameters: (remoteEuGreenCard: RemoteGreenCards.EuGreenCard, cryptoManager: CryptoManaging)?
	var invokedStoreEuGreenCardParametersList = [(remoteEuGreenCard: RemoteGreenCards.EuGreenCard, cryptoManager: CryptoManaging)]()
	var stubbedStoreEuGreenCardResult: Bool! = false

	func storeEuGreenCard(_ remoteEuGreenCard: RemoteGreenCards.EuGreenCard, cryptoManager: CryptoManaging) -> Bool {
		invokedStoreEuGreenCard = true
		invokedStoreEuGreenCardCount += 1
		invokedStoreEuGreenCardParameters = (remoteEuGreenCard, cryptoManager)
		invokedStoreEuGreenCardParametersList.append((remoteEuGreenCard, cryptoManager))
		return stubbedStoreEuGreenCardResult
	}

	var invokedImportExistingTestCredential = false
	var invokedImportExistingTestCredentialCount = 0
	var invokedImportExistingTestCredentialParameters: (data: Data, sampleDate: Date)?
	var invokedImportExistingTestCredentialParametersList = [(data: Data, sampleDate: Date)]()
	var stubbedImportExistingTestCredentialResult: Bool! = false

	func importExistingTestCredential(_ data: Data, sampleDate: Date) -> Bool {
		invokedImportExistingTestCredential = true
		invokedImportExistingTestCredentialCount += 1
		invokedImportExistingTestCredentialParameters = (data, sampleDate)
		invokedImportExistingTestCredentialParametersList.append((data, sampleDate))
		return stubbedImportExistingTestCredentialResult
	}

	var invokedListGreenCards = false
	var invokedListGreenCardsCount = 0
	var stubbedListGreenCardsResult: [GreenCard]! = []

	func listGreenCards() -> [GreenCard] {
		invokedListGreenCards = true
		invokedListGreenCardsCount += 1
		return stubbedListGreenCardsResult
	}

	var invokedListOrigins = false
	var invokedListOriginsCount = 0
	var invokedListOriginsParameters: (type: OriginType, Void)?
	var invokedListOriginsParametersList = [(type: OriginType, Void)]()
	var stubbedListOriginsResult: [Origin]! = []

	func listOrigins(type: OriginType) -> [Origin] {
		invokedListOrigins = true
		invokedListOriginsCount += 1
		invokedListOriginsParameters = (type, ())
		invokedListOriginsParametersList.append((type, ()))
		return stubbedListOriginsResult
	}

	var invokedRemoveExpiredGreenCards = false
	var invokedRemoveExpiredGreenCardsCount = 0
	var stubbedRemoveExpiredGreenCardsResult: [(greencardType: String, originType: String)]! = []

	func removeExpiredGreenCards() -> [(greencardType: String, originType: String)] {
		invokedRemoveExpiredGreenCards = true
		invokedRemoveExpiredGreenCardsCount += 1
		return stubbedRemoveExpiredGreenCardsResult
	}

	var invokedExpireEventGroups = false
	var invokedExpireEventGroupsCount = 0
	var invokedExpireEventGroupsParameters: (vaccinationValidity: Int?, recoveryValidity: Int?, testValidity: Int?)?
	var invokedExpireEventGroupsParametersList = [(vaccinationValidity: Int?, recoveryValidity: Int?, testValidity: Int?)]()

	func expireEventGroups(vaccinationValidity: Int?, recoveryValidity: Int?, testValidity: Int?) {
		invokedExpireEventGroups = true
		invokedExpireEventGroupsCount += 1
		invokedExpireEventGroupsParameters = (vaccinationValidity, recoveryValidity, testValidity)
		invokedExpireEventGroupsParametersList.append((vaccinationValidity, recoveryValidity, testValidity))
	}
}
