/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import CoreData
import Transport

class BlockedEventModel {
	
	static let entityName = "BlockedEvent"
	
	@discardableResult class func create(
		type: EventMode,
		eventDate: Date,
		reason: String,
		wallet: Wallet,
		managedContext: NSManagedObjectContext) -> BlockedEvent? {
			
			guard let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedContext) as? BlockedEvent else {
				return nil
			}
			
			object.type = type.rawValue
			object.eventDate = eventDate
			object.reason = reason
			object.wallet = wallet
			
			return object
		}
}

extension BlockedEvent {
	
	func delete(context: NSManagedObjectContext) {
		
		context.delete(self)
	}
	
	@discardableResult
	static func createAndPersist(blockItem: RemoteGreenCards.BlobExpiry, existingEventGroup: EventGroup) -> BlockedEvent? {
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
		
		return Current.walletManager.storeBlockedEvent(
			type: eventMode,
			eventDate: eventDate ?? .distantPast,
			reason: blockItem.reason
		)
	}
}
