/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
@testable import Transport
@testable import Shared
import TestingShared
import Persistence
import XCTest
import CoreData

class WalletManagerSpy: WalletManaging {

	var invokedStoreEventGroup = false
	var invokedStoreEventGroupCount = 0
	var invokedStoreEventGroupParameters: (type: EventMode, providerIdentifier: String, jsonData: Data, expiryDate: Date?, isDraft: Bool)?
	var invokedStoreEventGroupParametersList = [(type: EventMode, providerIdentifier: String, jsonData: Data, expiryDate: Date?, isDraft: Bool)]()
	var stubbedStoreEventGroupResult: EventGroup!

	func storeEventGroup(
		_ type: EventMode,
		providerIdentifier: String,
		jsonData: Data,
		expiryDate: Date?,
		isDraft: Bool) -> EventGroup? {
		invokedStoreEventGroup = true
		invokedStoreEventGroupCount += 1
		invokedStoreEventGroupParameters = (type, providerIdentifier, jsonData, expiryDate, isDraft)
		invokedStoreEventGroupParametersList.append((type, providerIdentifier, jsonData, expiryDate, isDraft))
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

	var invokedRemoveDraftEventGroups = false
	var invokedRemoveDraftEventGroupsCount = 0

	func removeDraftEventGroups() {
		invokedRemoveDraftEventGroups = true
		invokedRemoveDraftEventGroupsCount += 1
	}

	var invokedRemoveExistingEventGroupsType = false
	var invokedRemoveExistingEventGroupsTypeCount = 0
	var invokedRemoveExistingEventGroupsTypeParameters: (type: EventMode, providerIdentifier: String)?
	var invokedRemoveExistingEventGroupsTypeParametersList = [(type: EventMode, providerIdentifier: String)]()
	var stubbedRemoveExistingEventGroupsTypeResult: Int! = 0

	func removeExistingEventGroups(type: EventMode, providerIdentifier: String) -> Int {
		invokedRemoveExistingEventGroupsType = true
		invokedRemoveExistingEventGroupsTypeCount += 1
		invokedRemoveExistingEventGroupsTypeParameters = (type, providerIdentifier)
		invokedRemoveExistingEventGroupsTypeParametersList.append((type, providerIdentifier))
		return stubbedRemoveExistingEventGroupsTypeResult
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

	var invokedRemoveExistingBlockedEvents = false
	var invokedRemoveExistingBlockedEventsCount = 0

	func removeExistingBlockedEvents() {
		invokedRemoveExistingBlockedEvents = true
		invokedRemoveExistingBlockedEventsCount += 1
	}

	var invokedRemoveExistingMismatchedIdentityEvents = false
	var invokedRemoveExistingMismatchedIdentityEventsCount = 0

	func removeExistingMismatchedIdentityEvents() {
		invokedRemoveExistingMismatchedIdentityEvents = true
		invokedRemoveExistingMismatchedIdentityEventsCount += 1
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

	var invokedStoreRemovedEvent = false
	var invokedStoreRemovedEventCount = 0
	var invokedStoreRemovedEventParameters: (type: EventMode, eventDate: Date, reason: String)?
	var invokedStoreRemovedEventParametersList = [(type: EventMode, eventDate: Date, reason: String)]()
	var stubbedStoreRemovedEventResult: RemovedEvent!

	func storeRemovedEvent(type: EventMode, eventDate: Date, reason: String) -> RemovedEvent? {
		invokedStoreRemovedEvent = true
		invokedStoreRemovedEventCount += 1
		invokedStoreRemovedEventParameters = (type, eventDate, reason)
		invokedStoreRemovedEventParametersList.append((type, eventDate, reason))
		return stubbedStoreRemovedEventResult
	}

	var invokedCreateAndPersistRemovedEventWrapper = false
	var invokedCreateAndPersistRemovedEventWrapperCount = 0
	var invokedCreateAndPersistRemovedEventWrapperParameters: (wrapper: EventFlow.EventResultWrapper, reason: RemovalReason)?
	var invokedCreateAndPersistRemovedEventWrapperParametersList = [(wrapper: EventFlow.EventResultWrapper, reason: RemovalReason)]()
	var stubbedCreateAndPersistRemovedEventWrapperResult: [RemovedEvent]! = []

	func createAndPersistRemovedEvent(wrapper: EventFlow.EventResultWrapper, reason: RemovalReason) -> [RemovedEvent] {
		invokedCreateAndPersistRemovedEventWrapper = true
		invokedCreateAndPersistRemovedEventWrapperCount += 1
		invokedCreateAndPersistRemovedEventWrapperParameters = (wrapper, reason)
		invokedCreateAndPersistRemovedEventWrapperParametersList.append((wrapper, reason))
		return stubbedCreateAndPersistRemovedEventWrapperResult
	}

	var invokedCreateAndPersistRemovedEventEuCredentialAttributes = false
	var invokedCreateAndPersistRemovedEventEuCredentialAttributesCount = 0
	var invokedCreateAndPersistRemovedEventEuCredentialAttributesParameters: (euCredentialAttributes: EuCredentialAttributes, reason: RemovalReason)?
	var invokedCreateAndPersistRemovedEventEuCredentialAttributesParametersList = [(euCredentialAttributes: EuCredentialAttributes, reason: RemovalReason)]()
	var stubbedCreateAndPersistRemovedEventEuCredentialAttributesResult: RemovedEvent!

	func createAndPersistRemovedEvent(euCredentialAttributes: EuCredentialAttributes, reason: RemovalReason) -> RemovedEvent? {
		invokedCreateAndPersistRemovedEventEuCredentialAttributes = true
		invokedCreateAndPersistRemovedEventEuCredentialAttributesCount += 1
		invokedCreateAndPersistRemovedEventEuCredentialAttributesParameters = (euCredentialAttributes, reason)
		invokedCreateAndPersistRemovedEventEuCredentialAttributesParametersList.append((euCredentialAttributes, reason))
		return stubbedCreateAndPersistRemovedEventEuCredentialAttributesResult
	}

	var invokedCreateAndPersistRemovedEventBlockItem = false
	var invokedCreateAndPersistRemovedEventBlockItemCount = 0
	var invokedCreateAndPersistRemovedEventBlockItemParameters: (blockItem: RemoteGreenCards.BlobExpiry, existingEventGroup: EventGroup, cryptoManager: CryptoManaging?)?
	var invokedCreateAndPersistRemovedEventBlockItemParametersList = [(blockItem: RemoteGreenCards.BlobExpiry, existingEventGroup: EventGroup, cryptoManager: CryptoManaging?)]()
	var stubbedCreateAndPersistRemovedEventBlockItemResult: RemovedEvent!

	func createAndPersistRemovedEvent(blockItem: RemoteGreenCards.BlobExpiry, existingEventGroup: EventGroup, cryptoManager: CryptoManaging?) -> RemovedEvent? {
		invokedCreateAndPersistRemovedEventBlockItem = true
		invokedCreateAndPersistRemovedEventBlockItemCount += 1
		invokedCreateAndPersistRemovedEventBlockItemParameters = (blockItem, existingEventGroup, cryptoManager)
		invokedCreateAndPersistRemovedEventBlockItemParametersList.append((blockItem, existingEventGroup, cryptoManager))
		return stubbedCreateAndPersistRemovedEventBlockItemResult
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

	var invokedRemoveExpiredGreenCards = false
	var invokedRemoveExpiredGreenCardsCount = 0
	var invokedRemoveExpiredGreenCardsParameters: (forDate: Date, Void)?
	var invokedRemoveExpiredGreenCardsParametersList = [(forDate: Date, Void)]()
	var stubbedRemoveExpiredGreenCardsResult: [(greencardType: String, originType: String)]! = []

	func removeExpiredGreenCards(forDate: Date) -> [(greencardType: String, originType: String)] {
		invokedRemoveExpiredGreenCards = true
		invokedRemoveExpiredGreenCardsCount += 1
		invokedRemoveExpiredGreenCardsParameters = (forDate, ())
		invokedRemoveExpiredGreenCardsParametersList.append((forDate, ()))
		return stubbedRemoveExpiredGreenCardsResult
	}

	var invokedExpireEventGroups = false
	var invokedExpireEventGroupsCount = 0
	var invokedExpireEventGroupsParameters: (forDate: Date, Void)?
	var invokedExpireEventGroupsParametersList = [(forDate: Date, Void)]()

	func expireEventGroups(forDate: Date) {
		invokedExpireEventGroups = true
		invokedExpireEventGroupsCount += 1
		invokedExpireEventGroupsParameters = (forDate, ())
		invokedExpireEventGroupsParametersList.append((forDate, ()))
	}

	var invokedRemoveEventGroup = false
	var invokedRemoveEventGroupCount = 0
	var invokedRemoveEventGroupParameters: (objectID: NSManagedObjectID, Void)?
	var invokedRemoveEventGroupParametersList = [(objectID: NSManagedObjectID, Void)]()
	var stubbedRemoveEventGroupResult: Result<Void, Error>!

	func removeEventGroup(_ objectID: NSManagedObjectID) -> Result<Void, Error> {
		invokedRemoveEventGroup = true
		invokedRemoveEventGroupCount += 1
		invokedRemoveEventGroupParameters = (objectID, ())
		invokedRemoveEventGroupParametersList.append((objectID, ()))
		return stubbedRemoveEventGroupResult
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

	var invokedUpdateEventGroupIdentifier = false
	var invokedUpdateEventGroupIdentifierCount = 0
	var invokedUpdateEventGroupIdentifierParameters: (identifier: String, expiryDate: Date)?
	var invokedUpdateEventGroupIdentifierParametersList = [(identifier: String, expiryDate: Date)]()

	func updateEventGroup(identifier: String, expiryDate: Date) {
		invokedUpdateEventGroupIdentifier = true
		invokedUpdateEventGroupIdentifierCount += 1
		invokedUpdateEventGroupIdentifierParameters = (identifier, expiryDate)
		invokedUpdateEventGroupIdentifierParametersList.append((identifier, expiryDate))
	}

	var invokedUpdateEventGroupIsDraft = false
	var invokedUpdateEventGroupIsDraftCount = 0
	var invokedUpdateEventGroupIsDraftParameters: (eventGroup: EventGroup, isDraft: Bool)?
	var invokedUpdateEventGroupIsDraftParametersList = [(eventGroup: EventGroup, isDraft: Bool)]()

	func updateEventGroup(_ eventGroup: EventGroup, isDraft: Bool) {
		invokedUpdateEventGroupIsDraft = true
		invokedUpdateEventGroupIsDraftCount += 1
		invokedUpdateEventGroupIsDraftParameters = (eventGroup, isDraft)
		invokedUpdateEventGroupIsDraftParametersList.append((eventGroup, isDraft))
	}
}
