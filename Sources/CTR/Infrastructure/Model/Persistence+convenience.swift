/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Persistence
import CoreData
import Transport

extension Array where Element == RemoteGreenCards.BlobExpiry {
	
	/// Determine which BlobExpiry elements ("blockItems") match EventGroups which were sent to be signed:
	func combinedWith(matchingEventGroups eventGroups: [EventGroup]) -> [(RemoteGreenCards.BlobExpiry, EventGroup)] {
		reduce([]) { partialResult, blockItem in
			guard let matchingEvent = eventGroups.first(where: { "\($0.uniqueIdentifier)" == blockItem.identifier }) else { return partialResult }
			return partialResult + [(blockItem, matchingEvent)]
		}
	}
}

class GreenCardModel {

	class func fetchByIds(objectIDs: [NSManagedObjectID]) -> Result<[GreenCard], Error> {

		var result = [GreenCard]()
		for objectID in objectIDs {
			do {
				if let greenCard = try Current.dataStoreManager.managedObjectContext().existingObject(with: objectID) as? GreenCard {
					result.append(greenCard)
				}
			} catch let error {
				return .failure(error)
			}
		}
		return .success(result)
	}
}

extension RemovedEvent {
	
	static let entityName = "RemovedEvent"
	
	convenience init(
		type: EventMode,
		eventDate: Date,
		reason: String,
		wallet: Wallet,
		managedContext: NSManagedObjectContext) {
		
		self.init(context: managedContext)
		self.type = type.rawValue
		self.eventDate = eventDate
		self.reason = reason
		self.wallet = wallet
	}
	
	func delete(context: NSManagedObjectContext) {
		
		context.delete(self)
	}
	
	@discardableResult
	static func createAndPersist(blockItem: RemoteGreenCards.BlobExpiry, existingEventGroup: EventGroup) -> RemovedEvent? {
		guard let jsonData = existingEventGroup.jsonData,
			  let object = try? JSONDecoder().decode(EventFlow.DccEvent.self, from: jsonData),
			  let credentialData = object.credential.data(using: .utf8),
			  let euCredentialAttributes = Current.cryptoManager.readEuCredentials(credentialData),
			  let eventMode = euCredentialAttributes.eventMode,
			  let reason = blockItem.reason
		else { return nil }
		
		var eventDate: Date? {
			guard let eventDate = euCredentialAttributes.eventDate else { return nil }
			return DateFormatter.Event.iso8601.date(from: eventDate)
		}
		
		return Current.walletManager.storeRemovedEvent(
			type: eventMode,
			eventDate: eventDate ?? .distantPast,
			reason: reason
		)
	}
	
	@discardableResult
	static func createAndPersist(euCredentialAttributes: EuCredentialAttributes, reason: RemovalReason) -> RemovedEvent? {
		
		if let eventMode = euCredentialAttributes.eventMode {
			var eventDate: Date? {
				guard let eventDate = euCredentialAttributes.eventDate else { return nil }
				return DateFormatter.Event.iso8601.date(from: eventDate)
			}
			
			return Current.walletManager.storeRemovedEvent(
				type: eventMode,
				eventDate: eventDate ?? .distantPast,
				reason: reason.rawValue
			)
		}
		return nil
	}
	
	@discardableResult
	static func createAndPersist(wrapper: EventFlow.EventResultWrapper, reason: RemovalReason) -> [RemovedEvent] {
		
		var result = [RemovedEvent]()
		
		guard let events = wrapper.events else {
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
				let removedEvent = Current.walletManager.storeRemovedEvent(
				type: eventMode,
				eventDate: eventDate,
				reason: reason.rawValue
			) {
				result.append( removedEvent)
			}
		}
		return result
	}
}
