/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

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
