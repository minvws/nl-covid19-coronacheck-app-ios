/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData
import Transport
import Shared

protocol WalletManaging: AnyObject {

	/// Store an event group
	/// - Parameters:
	///   - type: the event type (vaccination, recovery, test)
	///   - providerIdentifier: the identifier of the provider
	///   - jsonData: the json  data of the original signed event or dcc
	///   - expiryDate: when will this eventgroup expire?
	///   - isDraft: has the event been confirmed by the signer? If not, `draft = true`.
	/// - Returns: Object if stored
	func storeEventGroup(
		_ type: EventMode,
		providerIdentifier: String,
		jsonData: Data,
		expiryDate: Date?,
		isDraft: Bool) -> EventGroup?

	func fetchSignedEvents() -> [String]

	/// Deletes any EventGroups marked as `draft=true`
	func removeDraftEventGroups()
	
	/// Remove any existing event groups for the type and provider identifier
	/// - Parameters:
	///   - type: the type of event group
	///   - providerIdentifier: the identifier of the the provider
	/// - Returns: Number of event groups removed
	func removeExistingEventGroups(type: EventMode, providerIdentifier: String) -> Int

	/// Remove any existing event groups
	func removeExistingEventGroups()

	func removeExistingGreenCards()
	
	func removeExistingBlockedEvents()
	
	func removeExistingMismatchedIdentityEvents()

	func storeDomesticGreenCard(_ remoteGreenCard: RemoteGreenCards.DomesticGreenCard, cryptoManager: CryptoManaging) -> Bool

	func storeEuGreenCard(_ remoteEuGreenCard: RemoteGreenCards.EuGreenCard, cryptoManager: CryptoManaging) -> Bool
	
	@discardableResult
	func storeRemovedEvent(type: EventMode, eventDate: Date, reason: String) -> RemovedEvent?
	
	@discardableResult
	func createAndPersistRemovedEvent(wrapper: EventFlow.EventResultWrapper, reason: RemovalReason) -> [RemovedEvent]
	
	@discardableResult
	func createAndPersistRemovedEvent(euCredentialAttributes: EuCredentialAttributes, reason: RemovalReason) -> RemovedEvent?
	
	@discardableResult
	func createAndPersistRemovedEvent(blockItem: RemoteGreenCards.BlobExpiry, existingEventGroup: EventGroup, cryptoManager: CryptoManaging?) -> RemovedEvent?
	
	/// List all the event groups
	/// - Returns: all the event groups
	func listEventGroups() -> [EventGroup]

	func listGreenCards() -> [GreenCard]

	func removeExpiredGreenCards(forDate: Date) -> [(greencardType: String, originType: String)]

	/// Expire event groups that are no longer valid
	/// - Parameter forDate: Current date
	func expireEventGroups(forDate: Date)
	
	func removeEventGroup(_ objectID: NSManagedObjectID) -> Result<Void, Error>

	/// Return all greencards for current wallet which still have unexpired origins (regardless of credentials):
	func greencardsWithUnexpiredOrigins(now: Date, ofOriginType: OriginType?) -> [GreenCard]
	
	func updateEventGroup(identifier: String, expiryDate: Date)
	
	func updateEventGroup(_ eventGroup: EventGroup, isDraft: Bool)
}
