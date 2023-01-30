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
}
