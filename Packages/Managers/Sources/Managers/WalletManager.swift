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
import Persistence
import Models

public class WalletManager: WalletManaging {

	public static let walletName = "main"

	private var dataStoreManager: DataStoreManaging

	public required init(dataStoreManager: DataStoreManaging) {
		
		self.dataStoreManager = dataStoreManager

		guard AppFlavor.flavor == .holder else { return }
		createMainWalletIfNotExists()
	}

	private func createMainWalletIfNotExists() {

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if WalletModel.findBy(label: WalletManager.walletName, managedContext: context) == nil {
				Wallet(label: WalletManager.walletName, managedContext: context)
				dataStoreManager.save(context)
			}
		}
	}
	
	/// Expire event groups that are no longer valid
	/// - Parameter forDate: Current date
	public func expireEventGroups(forDate: Date) {
		
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
			
			for eventGroup in wallet.castEventGroups() {
				if let expiryDate = eventGroup.expiryDate, expiryDate < forDate {
					logInfo("Sashay away \(String(describing: eventGroup.providerIdentifier)) \(String(describing: eventGroup.type)) \(String(describing: eventGroup.expiryDate))")
					context.delete(eventGroup)
				}
			}
		}
	}
	
	public func fetchSignedEvents() -> [String] {

		var signedEvents = [String]()

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
			
			for eventGroup in wallet.castEventGroups() {
				if let jsonString = eventGroup.getSignedEvents() {
					signedEvents.append(jsonString)
				}
			}
		}
		return signedEvents
	}

	public func listGreenCards() -> [GreenCard] {

		var result = [GreenCard]()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context),
			   let greenCards = wallet.castGreenCards() {
				result = greenCards
			}
		}
		return result
	}

	/// List all the event groups
	/// - Returns: all the event groups
	public func listEventGroups() -> [EventGroup] {

		var result = [EventGroup]()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
			
			result = wallet.castEventGroups()
		}
		return result
	}

	/// Return all greencards for current wallet which still have unexpired origins (regardless of credentials):
	public func greencardsWithUnexpiredOrigins(now: Date, ofOriginType originType: OriginType? = nil) -> [GreenCard] {
		var result = [GreenCard]()

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context),
				  let allGreenCards = wallet.castGreenCards()
			else { return }

			for greenCard in allGreenCards {
				guard let origins = greenCard.castOrigins() else { break }

				let hasValidRemainingOrigins = origins.contains(where: { origin in
					guard let expirationTime = origin.expirationTime,
						  expirationTime > now
					else { return false }

					// Optional extra check:
					if let originType {
						return origin.type == originType.rawValue
					}

					return true
				})

				if hasValidRemainingOrigins {
					result += [greenCard]
				}
			}
		}

		return result
	}
	
	public func updateEventGroup(identifier: String, expiryDate: Date) {
		
		logDebug("WalletManager: Should update eventGroup \(identifier) with expiry \(expiryDate)")
		
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
		
			wallet.castEventGroups().forEach { eventGroup in
				if String(eventGroup.uniqueIdentifier) == identifier {
					eventGroup.expiryDate = expiryDate
				}
			}
			dataStoreManager.save(context)
		}
	}
	
	public func updateEventGroup(_ eventGroup: EventGroup, isDraft: Bool) {
		
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			eventGroup.isDraft = isDraft
			dataStoreManager.save(context)
		}
	}
}

// MARK: Storing

extension WalletManager {
	
	public func storeEuGreenCard(_ remoteEuGreenCard: RemoteGreenCards.EuGreenCard, cryptoManager: CryptoManaging) -> Bool {
		
		var result = true
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {
				let greenCard = GreenCard(type: .eu, wallet: wallet, managedContext: context)
				// Origins
				for remoteOrigin in remoteEuGreenCard.origins {
					result = result && storeOrigin(remoteOrigin: remoteOrigin, greenCard: greenCard, context: context)
				}
				// Credential (DCC has 1 credential)
				let data = Data(remoteEuGreenCard.credential.utf8)
				if let euCredentialAttributes = cryptoManager.readEuCredentials(data) {
					Credential(
						data: data,
						validFrom: Date(timeIntervalSince1970: 0), // DCC are always immediately valid
						expirationTime: Date(timeIntervalSince1970: euCredentialAttributes.expirationTime),
						version: Int32(euCredentialAttributes.credentialVersion),
						greenCard: greenCard,
						managedContext: context)
				} else {
					result = false
				}
			}
			if result {
				dataStoreManager.save(context)
			}
		}
		return result
	}
	
	private func storeOrigin(remoteOrigin: RemoteGreenCards.Origin, greenCard: GreenCard, context: NSManagedObjectContext) -> Bool {
		
		if let type = OriginType(rawValue: remoteOrigin.type) {
			
			let origin = Origin(
				type: type,
				eventDate: remoteOrigin.eventTime,
				expirationTime: remoteOrigin.expirationTime,
				validFromDate: remoteOrigin.validFrom,
				doseNumber: remoteOrigin.doseNumber,
				greenCard: greenCard,
				managedContext: context
			)
			
			// Store the origin hints
			for hint in remoteOrigin.hints {
				OriginHint(origin: origin, hint: hint, managedContext: context)
			}
			return true
			
		} else {
			return false
		}
	}
	
	@discardableResult
	public func storeRemovedEvent(type: EventMode, eventDate: Date, reason: String) -> RemovedEvent? {

		var blockedEvent: RemovedEvent?
		let context = dataStoreManager.managedObjectContext()
		
		context.performAndWait {
			
			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else {
				return
			}
			
			blockedEvent = RemovedEvent(
				type: type,
				eventDate: eventDate,
				reason: reason,
				wallet: wallet,
				managedContext: context
			)
			dataStoreManager.save(context)
		}
		
		return blockedEvent
	}
	
	@discardableResult
	public func createAndPersistRemovedEvent(wrapper: EventFlow.EventResultWrapper, reason: RemovalReason) -> [RemovedEvent] {
		
		var result: [RemovedEvent] = []
		
		guard let events = wrapper.events, events.isNotEmpty else {
			return result
		}
		
		var eventMode: EventMode?
		if let event = events.first {
			if event.hasVaccinationAssessment {
				eventMode = .vaccinationassessment
			} else if event.hasPaperCertificate {
				eventMode = .paperflow
			} else if event.hasPositiveTest {
				eventMode = .recovery
			} else if event.hasNegativeTest {
				eventMode = .test( wrapper.isGGD ? .ggd : .commercial)
			} else if event.hasRecovery {
				eventMode = .recovery
			} else if event.hasVaccination {
				eventMode = .vaccination
			}
		}
		
		for event in events {
			if let eventDate = event.getSortDate(with: DateFormatter.Event.iso8601),
				let eventMode,
				let removedEvent = storeRemovedEvent(
				type: eventMode,
				eventDate: eventDate,
				reason: reason.rawValue
			) {
				result.append( removedEvent)
			}
		}
		return result
	}
	
	@discardableResult
	public func createAndPersistRemovedEvent(euCredentialAttributes: EuCredentialAttributes, reason: RemovalReason) -> RemovedEvent? {
		
		guard let eventMode = euCredentialAttributes.eventMode else {
			return nil
		}
		
		var eventDate: Date? {
			guard let eventDate = euCredentialAttributes.eventDate else { return nil }
			return DateFormatter.Event.iso8601.date(from: eventDate)
		}
		
		return storeRemovedEvent(
			type: eventMode,
			eventDate: eventDate ?? .distantPast,
			reason: reason.rawValue
		)
	}
	
	@discardableResult
	public func createAndPersistRemovedEvent(blockItem: RemoteGreenCards.BlobExpiry, existingEventGroup: EventGroup, cryptoManager: CryptoManaging?) -> RemovedEvent? {
		
		guard let jsonData = existingEventGroup.jsonData,
			  let object = try? JSONDecoder().decode(EventFlow.DccEvent.self, from: jsonData),
			  let credentialData = object.credential.data(using: .utf8),
			  let euCredentialAttributes = cryptoManager?.readEuCredentials(credentialData),
			  let eventMode = euCredentialAttributes.eventMode,
			  let reason = blockItem.reason
		else { return nil }
		
		var eventDate: Date? {
			guard let eventDate = euCredentialAttributes.eventDate else { return nil }
			return DateFormatter.Event.iso8601.date(from: eventDate)
		}
		
		return storeRemovedEvent(
			type: eventMode,
			eventDate: eventDate ?? .distantPast,
			reason: reason
		)
	}
	
	/// Store an event group
	/// - Parameters:
	///   - type: the event type (vaccination, recovery, test)
	///   - providerIdentifier: the identifier of the provider
	///   - signedResponse: the json of the signed response to store
	///   - expiryDate: when will this eventgroup expire?
	/// - Returns: optional event group
	@discardableResult public func storeEventGroup(
		_ type: EventMode,
		providerIdentifier: String,
		jsonData: Data,
		expiryDate: Date?,
		isDraft: Bool
	) -> EventGroup? {

		var eventGroup: EventGroup?

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else {
				return
			}
			
			eventGroup = EventGroup(
				type: type,
				providerIdentifier: providerIdentifier,
				expiryDate: expiryDate,
				jsonData: jsonData,
				wallet: wallet,
				isDraft: isDraft,
				managedContext: context
			)
			dataStoreManager.save(context)
		}
		return eventGroup
	}
}

// MARK: - Removing

extension WalletManager {
	
	public func removeEventGroup(_ objectID: NSManagedObjectID) -> Result<Void, Error> {
		
		dataStoreManager.delete(objectID)
	}

	/// Deletes any EventGroups marked as `draft=true`
	public func removeDraftEventGroups() {
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
			
			for eventGroup in wallet.castEventGroups() where eventGroup.isDraft {
				context.delete(eventGroup)
			}
		}
	}
	
	/// Remove any existing event groups for the type and provider identifier
	/// - Parameters:
	///   - type: the type of event group
	///   - providerIdentifier: the identifier of the the provider
	@discardableResult
	public func removeExistingEventGroups(type: EventMode, providerIdentifier: String) -> Int {
		
		var removedCount = 0
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
			
			for eventGroup in wallet.castEventGroups() where eventGroup.providerIdentifier?.lowercased() == providerIdentifier.lowercased() && eventGroup.type == type.rawValue {
				logDebug("Removing eventGroup \(String(describing: eventGroup.providerIdentifier)) \(String(describing: eventGroup.type))")
				context.delete(eventGroup)
				removedCount += 1
			}
			dataStoreManager.save(context)
		}
		return removedCount
	}

	/// Remove any existing event groups
	public func removeExistingEventGroups() {
		
		let context = dataStoreManager.managedObjectContext()
		
		context.performAndWait {
			
			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
			
			for eventGroup in wallet.castEventGroups() {
				logDebug("Removing eventGroup \(String(describing: eventGroup.providerIdentifier)) \(String(describing: eventGroup.type))")
				context.delete(eventGroup)
			}
			dataStoreManager.save(context)
		}
	}
	
	public func removeVaccinationAssessmentEventGroups() {
		
		let context = dataStoreManager.managedObjectContext()
		
		context.performAndWait {
			
			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
			
			for eventGroup in wallet.castEventGroups() where eventGroup.type == "vaccinationassessment" {
				logDebug("Removing eventGroup \(String(describing: eventGroup.providerIdentifier)) \(String(describing: eventGroup.type))")
				context.delete(eventGroup)
			}
			dataStoreManager.save(context)
		}
	}

	public func removeExistingGreenCards(secureUserSettings: SecureUserSettingsProtocol) {

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let greenCards = wallet.greenCards {
					for case let greenCard as GreenCard in greenCards.allObjects {

						if greenCard.type == GreenCardType.domestic.rawValue {
							// Reset the secret key to nil if the domestic greencard is deleted.
							secureUserSettings.holderSecretKey = nil
						}
				
						greenCard.delete(context: context)
							
					}
					dataStoreManager.save(context)
				}
			}
		}
	}
	
	public func removeDomesticGreenCards() {
		
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context),
			   let greenCards = wallet.greenCards {
				for case let greenCard as GreenCard in greenCards.allObjects where greenCard.type == "domestic" {
					greenCard.delete(context: context)
				}
				dataStoreManager.save(context)
			}
		}
	}

	public func removeExistingBlockedEvents() {
		
		removeExistingRemovedEvents(reason: RemovalReason.blockedEvent)
	}
	
	public func removeExistingMismatchedIdentityEvents() {
		
		removeExistingRemovedEvents(reason: RemovalReason.mismatchedIdentity)
	}
	
	public func removeExistingRemovedEvents(reason: RemovalReason) {
		
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let blockedEvents = wallet.removedEvents {
					for case let removedEvent as RemovedEvent in blockedEvents.allObjects where removedEvent.reason == reason.rawValue {
							removedEvent.delete(context: context)
						}
					dataStoreManager.save(context)
				}
			}
		}
	}

	/// Remove expired GreenCards that contain no more valid origins
	/// returns: an array of `Greencard.type` Strings. One for each GreenCard that was deleted.
	@discardableResult public func removeExpiredGreenCards(forDate: Date) -> [(greencardType: String, originType: String)] {
		var deletedGreenCardTypes: [(greencardType: String, originType: String)] = []

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let greenCards = wallet.greenCards {
					for case let greenCard as GreenCard in greenCards.allObjects {

						guard let origins = greenCard.castOrigins() else {
							greenCard.delete(context: context)
							break
						}

						// Does the GreenCard have any valid Origins remaining?
						let hasValidOrFutureOrigins = origins
							.contains(where: { ($0.expirationTime ?? .distantPast) > forDate })

						if hasValidOrFutureOrigins {
							continue
						} else {
							let lastExpiredOrigin = origins.sorted(by: { ($0.expirationTime ?? .distantPast) < ($1.expirationTime ?? .distantPast) }).last

							if let greencardType = greenCard.type, let originType = lastExpiredOrigin?.type {
								deletedGreenCardTypes += [(greencardType: greencardType, originType: originType)]
							}
							greenCard.delete(context: context)
						}
					}
				}
				dataStoreManager.save(context)
			}
		}

		return deletedGreenCardTypes
	}
}
