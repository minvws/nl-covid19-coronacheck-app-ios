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
}
