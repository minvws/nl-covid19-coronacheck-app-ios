/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import CoreData
import Transport

enum RemovalReason: String {
	case blockedEvent = "event_blocked"
	case mismatchedIdentity = "identity_mismatched"
}

class RemovedEventModel {
	
	static let entityName = "RemovedEvent"
	
	@discardableResult class func create(
		type: EventMode,
		eventDate: Date,
		reason: String,
		wallet: Wallet,
		managedContext: NSManagedObjectContext) -> RemovedEvent? {
			
			guard let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedContext) as? RemovedEvent else {
				return nil
			}
			
			object.type = type.rawValue
			object.eventDate = eventDate
			object.reason = reason
			object.wallet = wallet
			
			return object
		}
}

extension RemovedEvent {
	
	func delete(context: NSManagedObjectContext) {
		
		context.delete(self)
	}
	
	@discardableResult
	static func createAndPersist(blockItem: RemoteGreenCards.BlobExpiry, existingEventGroup: EventGroup) -> RemovedEvent? {
		guard let jsonData = existingEventGroup.jsonData,
			  let object = try? JSONDecoder().decode(EventFlow.DccEvent.self, from: jsonData),
			  let credentialData = object.credential.data(using: .utf8),
			  let euCredentialAttributes = Current.cryptoManager.readEuCredentials(credentialData),
			  let eventMode = euCredentialAttributes.eventMode
		else { return nil }
		
		var eventDate: Date? {
			guard let eventDate = euCredentialAttributes.eventDate else { return nil }
			return DateFormatter.Event.iso8601.date(from: eventDate)
		}
		
		return Current.walletManager.storeRemovedEvent(
			type: eventMode,
			eventDate: eventDate ?? .distantPast,
			reason: blockItem.reason
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
