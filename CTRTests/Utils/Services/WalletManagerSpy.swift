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
	var invokedStoreEventGroupParameters: (type: EventMode, providerIdentifier: String, jsonData: Data, issuedAt: Date)?
	var invokedStoreEventGroupParametersList = [(type: EventMode, providerIdentifier: String, jsonData: Data, issuedAt: Date)]()
	var stubbedStoreEventGroupResult: Bool! = false

	func storeEventGroup(_ type: EventMode, providerIdentifier: String, jsonData: Data, issuedAt: Date) -> Bool {
		invokedStoreEventGroup = true
		invokedStoreEventGroupCount += 1
		invokedStoreEventGroupParameters = (type, providerIdentifier, jsonData, issuedAt)
		invokedStoreEventGroupParametersList.append((type, providerIdentifier, jsonData, issuedAt))
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

	var invokedRemoveExistingEventGroupsType = false
	var invokedRemoveExistingEventGroupsTypeCount = 0
	var invokedRemoveExistingEventGroupsTypeParameters: (type: EventMode, providerIdentifier: String)?
	var invokedRemoveExistingEventGroupsTypeParametersList = [(type: EventMode, providerIdentifier: String)]()

	func removeExistingEventGroups(type: EventMode, providerIdentifier: String) {
		invokedRemoveExistingEventGroupsType = true
		invokedRemoveExistingEventGroupsTypeCount += 1
		invokedRemoveExistingEventGroupsTypeParameters = (type, providerIdentifier)
		invokedRemoveExistingEventGroupsTypeParametersList.append((type, providerIdentifier))
	}

	var invokedRemoveExistingEventGroups = false
	var invokedRemoveExistingEventGroupsCount = 0

	func removeExistingEventGroups() {
		invokedRemoveExistingEventGroups = true
		invokedRemoveExistingEventGroupsCount += 1
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

	var invokedListEventGroups = false
	var invokedListEventGroupsCount = 0
	var stubbedListEventGroupsResult: [EventGroup]! = []

	func listEventGroups() -> [EventGroup] {
		invokedListEventGroups = true
		invokedListEventGroupsCount += 1
		return stubbedListEventGroupsResult
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

	var invokedGreencardsWithUnexpiredOrigins = false
	var invokedGreencardsWithUnexpiredOriginsCount = 0
	var invokedGreencardsWithUnexpiredOriginsParameters: (now: Date, ofOriginType: OriginType?)?
	var invokedGreencardsWithUnexpiredOriginsParametersList = [(now: Date, ofOriginType: OriginType?)]()
	var stubbedGreencardsWithUnexpiredOriginsResult: [GreenCard]! = []

	func greencardsWithUnexpiredOrigins(now: Date, ofOriginType: OriginType?) -> [GreenCard] {
		invokedGreencardsWithUnexpiredOrigins = true
		invokedGreencardsWithUnexpiredOriginsCount += 1
		invokedGreencardsWithUnexpiredOriginsParameters = (now, ofOriginType)
		invokedGreencardsWithUnexpiredOriginsParametersList.append((now, ofOriginType))
		return stubbedGreencardsWithUnexpiredOriginsResult
	}

	var invokedCanSkipMultiDCCUpgrade = false
	var invokedCanSkipMultiDCCUpgradeCount = 0
	var stubbedCanSkipMultiDCCUpgradeResult: Bool! = false

	func canSkipMultiDCCUpgrade() -> Bool {
		invokedCanSkipMultiDCCUpgrade = true
		invokedCanSkipMultiDCCUpgradeCount += 1
		return stubbedCanSkipMultiDCCUpgradeResult
	}

	var invokedShouldShowMultiDCCUpgradeBanner = false
	var invokedShouldShowMultiDCCUpgradeBannerCount = 0
	var invokedShouldShowMultiDCCUpgradeBannerParameters: (userSettings: UserSettingsProtocol, Void)?
	var invokedShouldShowMultiDCCUpgradeBannerParametersList = [(userSettings: UserSettingsProtocol, Void)]()
	var stubbedShouldShowMultiDCCUpgradeBannerResult: Bool! = false

	func shouldShowMultiDCCUpgradeBanner(userSettings: UserSettingsProtocol) -> Bool {
		invokedShouldShowMultiDCCUpgradeBanner = true
		invokedShouldShowMultiDCCUpgradeBannerCount += 1
		invokedShouldShowMultiDCCUpgradeBannerParameters = (userSettings, ())
		invokedShouldShowMultiDCCUpgradeBannerParametersList.append((userSettings, ()))
		return stubbedShouldShowMultiDCCUpgradeBannerResult
	}

	var invokedHasEventGroup = false
	var invokedHasEventGroupCount = 0
	var invokedHasEventGroupParameters: (type: String, providerIdentifier: String)?
	var invokedHasEventGroupParametersList = [(type: String, providerIdentifier: String)]()
	var stubbedHasEventGroupResult: Bool! = false

	func hasEventGroup(type: String, providerIdentifier: String) -> Bool {
		invokedHasEventGroup = true
		invokedHasEventGroupCount += 1
		invokedHasEventGroupParameters = (type, providerIdentifier)
		invokedHasEventGroupParametersList.append((type, providerIdentifier))
		return stubbedHasEventGroupResult
	}
}

extension WalletManagerSpy {
	convenience init() {
		self.init(dataStoreManager: DataStoreManager(.inMemory))
	}
}
