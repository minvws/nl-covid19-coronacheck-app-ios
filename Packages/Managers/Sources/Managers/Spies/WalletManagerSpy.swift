/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import CoreData
import Foundation
import Transport
import Shared
import Persistence
import Models

public class WalletManagerSpy: WalletManaging {
	
	public init() {}

	public var invokedStoreEventGroup = false
	public var invokedStoreEventGroupCount = 0
	public var invokedStoreEventGroupParameters: (type: EventMode, providerIdentifier: String, jsonData: Data, expiryDate: Date?, isDraft: Bool)?
	public var invokedStoreEventGroupParametersList = [(type: EventMode, providerIdentifier: String, jsonData: Data, expiryDate: Date?, isDraft: Bool)]()
	public var stubbedStoreEventGroupResult: EventGroup!

	public func storeEventGroup(
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

	public var invokedFetchSignedEvents = false
	public var invokedFetchSignedEventsCount = 0
	public var stubbedFetchSignedEventsResult: [String]! = []

	public func fetchSignedEvents() -> [String] {
		invokedFetchSignedEvents = true
		invokedFetchSignedEventsCount += 1
		return stubbedFetchSignedEventsResult
	}

	public var invokedRemoveDomesticGreenCards = false
	public var invokedRemoveDomesticGreenCardsCount = 0

	public func removeDomesticGreenCards() {
		invokedRemoveDomesticGreenCards = true
		invokedRemoveDomesticGreenCardsCount += 1
	}

	public var invokedRemoveDraftEventGroups = false
	public var invokedRemoveDraftEventGroupsCount = 0

	public func removeDraftEventGroups() {
		invokedRemoveDraftEventGroups = true
		invokedRemoveDraftEventGroupsCount += 1
	}

	public var invokedRemoveExistingEventGroupsType = false
	public var invokedRemoveExistingEventGroupsTypeCount = 0
	public var invokedRemoveExistingEventGroupsTypeParameters: (type: EventMode, providerIdentifier: String)?
	public var invokedRemoveExistingEventGroupsTypeParametersList = [(type: EventMode, providerIdentifier: String)]()
	public var stubbedRemoveExistingEventGroupsTypeResult: Int! = 0

	public func removeExistingEventGroups(type: EventMode, providerIdentifier: String) -> Int {
		invokedRemoveExistingEventGroupsType = true
		invokedRemoveExistingEventGroupsTypeCount += 1
		invokedRemoveExistingEventGroupsTypeParameters = (type, providerIdentifier)
		invokedRemoveExistingEventGroupsTypeParametersList.append((type, providerIdentifier))
		return stubbedRemoveExistingEventGroupsTypeResult
	}

	public var invokedRemoveExistingEventGroups = false
	public var invokedRemoveExistingEventGroupsCount = 0

	public func removeExistingEventGroups() {
		invokedRemoveExistingEventGroups = true
		invokedRemoveExistingEventGroupsCount += 1
	}

	public var invokedRemoveExistingGreenCards = false
	public var invokedRemoveExistingGreenCardsCount = 0

	public func removeExistingGreenCards() {
		invokedRemoveExistingGreenCards = true
		invokedRemoveExistingGreenCardsCount += 1
	}

	public var invokedRemoveExistingBlockedEvents = false
	public var invokedRemoveExistingBlockedEventsCount = 0

	public func removeExistingBlockedEvents() {
		invokedRemoveExistingBlockedEvents = true
		invokedRemoveExistingBlockedEventsCount += 1
	}

	public var invokedRemoveExistingMismatchedIdentityEvents = false
	public var invokedRemoveExistingMismatchedIdentityEventsCount = 0

	public func removeExistingMismatchedIdentityEvents() {
		invokedRemoveExistingMismatchedIdentityEvents = true
		invokedRemoveExistingMismatchedIdentityEventsCount += 1
	}

	public var invokedRemoveVaccinationAssessmentEventGroups = false
	public var invokedRemoveVaccinationAssessmentEventGroupsCount = 0

	public func removeVaccinationAssessmentEventGroups() {
		invokedRemoveVaccinationAssessmentEventGroups = true
		invokedRemoveVaccinationAssessmentEventGroupsCount += 1
	}

	public var invokedStoreEuGreenCard = false
	public var invokedStoreEuGreenCardCount = 0
	public var invokedStoreEuGreenCardParameters: (remoteEuGreenCard: RemoteGreenCards.EuGreenCard, cryptoManager: CryptoManaging)?
	public var invokedStoreEuGreenCardParametersList = [(remoteEuGreenCard: RemoteGreenCards.EuGreenCard, cryptoManager: CryptoManaging)]()
	public var stubbedStoreEuGreenCardResult: Bool! = false

	public func storeEuGreenCard(_ remoteEuGreenCard: RemoteGreenCards.EuGreenCard, cryptoManager: CryptoManaging) -> Bool {
		invokedStoreEuGreenCard = true
		invokedStoreEuGreenCardCount += 1
		invokedStoreEuGreenCardParameters = (remoteEuGreenCard, cryptoManager)
		invokedStoreEuGreenCardParametersList.append((remoteEuGreenCard, cryptoManager))
		return stubbedStoreEuGreenCardResult
	}

	public var invokedStoreRemovedEvent = false
	public var invokedStoreRemovedEventCount = 0
	public var invokedStoreRemovedEventParameters: (type: EventMode, eventDate: Date, reason: String)?
	public var invokedStoreRemovedEventParametersList = [(type: EventMode, eventDate: Date, reason: String)]()
	public var stubbedStoreRemovedEventResult: RemovedEvent!

	public func storeRemovedEvent(type: EventMode, eventDate: Date, reason: String) -> RemovedEvent? {
		invokedStoreRemovedEvent = true
		invokedStoreRemovedEventCount += 1
		invokedStoreRemovedEventParameters = (type, eventDate, reason)
		invokedStoreRemovedEventParametersList.append((type, eventDate, reason))
		return stubbedStoreRemovedEventResult
	}

	public var invokedCreateAndPersistRemovedEventWrapper = false
	public var invokedCreateAndPersistRemovedEventWrapperCount = 0
	public var invokedCreateAndPersistRemovedEventWrapperParameters: (wrapper: EventFlow.EventResultWrapper, reason: RemovalReason)?
	public var invokedCreateAndPersistRemovedEventWrapperParametersList = [(wrapper: EventFlow.EventResultWrapper, reason: RemovalReason)]()
	public var stubbedCreateAndPersistRemovedEventWrapperResult: [RemovedEvent]! = []

	public func createAndPersistRemovedEvent(wrapper: EventFlow.EventResultWrapper, reason: RemovalReason) -> [RemovedEvent] {
		invokedCreateAndPersistRemovedEventWrapper = true
		invokedCreateAndPersistRemovedEventWrapperCount += 1
		invokedCreateAndPersistRemovedEventWrapperParameters = (wrapper, reason)
		invokedCreateAndPersistRemovedEventWrapperParametersList.append((wrapper, reason))
		return stubbedCreateAndPersistRemovedEventWrapperResult
	}

	public var invokedCreateAndPersistRemovedEventEuCredentialAttributes = false
	public var invokedCreateAndPersistRemovedEventEuCredentialAttributesCount = 0
	public var invokedCreateAndPersistRemovedEventEuCredentialAttributesParameters: (euCredentialAttributes: EuCredentialAttributes, reason: RemovalReason)?
	public var invokedCreateAndPersistRemovedEventEuCredentialAttributesParametersList = [(euCredentialAttributes: EuCredentialAttributes, reason: RemovalReason)]()
	public var stubbedCreateAndPersistRemovedEventEuCredentialAttributesResult: RemovedEvent!

	public func createAndPersistRemovedEvent(euCredentialAttributes: EuCredentialAttributes, reason: RemovalReason) -> RemovedEvent? {
		invokedCreateAndPersistRemovedEventEuCredentialAttributes = true
		invokedCreateAndPersistRemovedEventEuCredentialAttributesCount += 1
		invokedCreateAndPersistRemovedEventEuCredentialAttributesParameters = (euCredentialAttributes, reason)
		invokedCreateAndPersistRemovedEventEuCredentialAttributesParametersList.append((euCredentialAttributes, reason))
		return stubbedCreateAndPersistRemovedEventEuCredentialAttributesResult
	}

	public var invokedCreateAndPersistRemovedEventBlockItem = false
	public var invokedCreateAndPersistRemovedEventBlockItemCount = 0
	public var invokedCreateAndPersistRemovedEventBlockItemParameters: (blockItem: RemoteGreenCards.BlobExpiry, existingEventGroup: EventGroup, cryptoManager: CryptoManaging?)?
	public var invokedCreateAndPersistRemovedEventBlockItemParametersList = [(blockItem: RemoteGreenCards.BlobExpiry, existingEventGroup: EventGroup, cryptoManager: CryptoManaging?)]()
	public var stubbedCreateAndPersistRemovedEventBlockItemResult: RemovedEvent!

	public func createAndPersistRemovedEvent(blockItem: RemoteGreenCards.BlobExpiry, existingEventGroup: EventGroup, cryptoManager: CryptoManaging?) -> RemovedEvent? {
		invokedCreateAndPersistRemovedEventBlockItem = true
		invokedCreateAndPersistRemovedEventBlockItemCount += 1
		invokedCreateAndPersistRemovedEventBlockItemParameters = (blockItem, existingEventGroup, cryptoManager)
		invokedCreateAndPersistRemovedEventBlockItemParametersList.append((blockItem, existingEventGroup, cryptoManager))
		return stubbedCreateAndPersistRemovedEventBlockItemResult
	}

	public var invokedListEventGroups = false
	public var invokedListEventGroupsCount = 0
	public var stubbedListEventGroupsResult: [EventGroup]! = []

	public func listEventGroups() -> [EventGroup] {
		invokedListEventGroups = true
		invokedListEventGroupsCount += 1
		return stubbedListEventGroupsResult
	}

	public var invokedListGreenCards = false
	public var invokedListGreenCardsCount = 0
	public var stubbedListGreenCardsResult: [GreenCard]! = []

	public func listGreenCards() -> [GreenCard] {
		invokedListGreenCards = true
		invokedListGreenCardsCount += 1
		return stubbedListGreenCardsResult
	}

	public var invokedRemoveExpiredGreenCards = false
	public var invokedRemoveExpiredGreenCardsCount = 0
	public var invokedRemoveExpiredGreenCardsParameters: (forDate: Date, Void)?
	public var invokedRemoveExpiredGreenCardsParametersList = [(forDate: Date, Void)]()
	public var stubbedRemoveExpiredGreenCardsResult: [(greencardType: String, originType: String)]! = []

	public func removeExpiredGreenCards(forDate: Date) -> [(greencardType: String, originType: String)] {
		invokedRemoveExpiredGreenCards = true
		invokedRemoveExpiredGreenCardsCount += 1
		invokedRemoveExpiredGreenCardsParameters = (forDate, ())
		invokedRemoveExpiredGreenCardsParametersList.append((forDate, ()))
		return stubbedRemoveExpiredGreenCardsResult
	}

	public var invokedExpireEventGroups = false
	public var invokedExpireEventGroupsCount = 0
	public var invokedExpireEventGroupsParameters: (forDate: Date, Void)?
	public var invokedExpireEventGroupsParametersList = [(forDate: Date, Void)]()

	public func expireEventGroups(forDate: Date) {
		invokedExpireEventGroups = true
		invokedExpireEventGroupsCount += 1
		invokedExpireEventGroupsParameters = (forDate, ())
		invokedExpireEventGroupsParametersList.append((forDate, ()))
	}

	public var invokedRemoveEventGroup = false
	public var invokedRemoveEventGroupCount = 0
	public var invokedRemoveEventGroupParameters: (objectID: NSManagedObjectID, Void)?
	public var invokedRemoveEventGroupParametersList = [(objectID: NSManagedObjectID, Void)]()
	public var stubbedRemoveEventGroupResult: Result<Void, Error>!

	public func removeEventGroup(_ objectID: NSManagedObjectID) -> Result<Void, Error> {
		invokedRemoveEventGroup = true
		invokedRemoveEventGroupCount += 1
		invokedRemoveEventGroupParameters = (objectID, ())
		invokedRemoveEventGroupParametersList.append((objectID, ()))
		return stubbedRemoveEventGroupResult
	}

	public var invokedGreencardsWithUnexpiredOrigins = false
	public var invokedGreencardsWithUnexpiredOriginsCount = 0
	public var invokedGreencardsWithUnexpiredOriginsParameters: (now: Date, ofOriginType: OriginType?)?
	public var invokedGreencardsWithUnexpiredOriginsParametersList = [(now: Date, ofOriginType: OriginType?)]()
	public var stubbedGreencardsWithUnexpiredOriginsResult: [GreenCard]! = []

	public func greencardsWithUnexpiredOrigins(now: Date, ofOriginType: OriginType?) -> [GreenCard] {
		invokedGreencardsWithUnexpiredOrigins = true
		invokedGreencardsWithUnexpiredOriginsCount += 1
		invokedGreencardsWithUnexpiredOriginsParameters = (now, ofOriginType)
		invokedGreencardsWithUnexpiredOriginsParametersList.append((now, ofOriginType))
		return stubbedGreencardsWithUnexpiredOriginsResult
	}

	public var invokedUpdateEventGroupIdentifier = false
	public var invokedUpdateEventGroupIdentifierCount = 0
	public var invokedUpdateEventGroupIdentifierParameters: (identifier: String, expiryDate: Date)?
	public var invokedUpdateEventGroupIdentifierParametersList = [(identifier: String, expiryDate: Date)]()

	public func updateEventGroup(identifier: String, expiryDate: Date) {
		invokedUpdateEventGroupIdentifier = true
		invokedUpdateEventGroupIdentifierCount += 1
		invokedUpdateEventGroupIdentifierParameters = (identifier, expiryDate)
		invokedUpdateEventGroupIdentifierParametersList.append((identifier, expiryDate))
	}

	public var invokedUpdateEventGroupIsDraft = false
	public var invokedUpdateEventGroupIsDraftCount = 0
	public var invokedUpdateEventGroupIsDraftParameters: (eventGroup: EventGroup, isDraft: Bool)?
	public var invokedUpdateEventGroupIsDraftParametersList = [(eventGroup: EventGroup, isDraft: Bool)]()

	public func updateEventGroup(_ eventGroup: EventGroup, isDraft: Bool) {
		invokedUpdateEventGroupIsDraft = true
		invokedUpdateEventGroupIsDraftCount += 1
		invokedUpdateEventGroupIsDraftParameters = (eventGroup, isDraft)
		invokedUpdateEventGroupIsDraftParametersList.append((eventGroup, isDraft))
	}
}
