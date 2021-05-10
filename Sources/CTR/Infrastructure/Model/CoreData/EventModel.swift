/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

class EventModel {

	static let entityName = "Event"

	@discardableResult class func create(
		type: String,
		issuedAt: Date,
		jsonData: Data,
		wallet: Wallet,
		managedContext: NSManagedObjectContext) -> Event? {

		if let object = NSEntityDescription.insertNewObject(
			forEntityName: entityName,
			into: managedContext) as? Event {

			object.type = type
			object.issuedAt = issuedAt
			object.jsonData = jsonData
			object.wallet = wallet

			return object
		}
		return nil
	}
}
