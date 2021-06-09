/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

enum EventType: String {

	case recovery
	case test
	case vaccination
}

class EventGroupModel {

	static let entityName = "EventGroup"

	@discardableResult class func create(
		type: EventType,
		providerIdentifier: String,
		maxIssuedAt: Date,
		jsonData: Data,
		wallet: Wallet,
		managedContext: NSManagedObjectContext) -> EventGroup? {

		if let object = NSEntityDescription.insertNewObject(
			forEntityName: entityName,
			into: managedContext) as? EventGroup {

			object.type = type.rawValue
			object.providerIdentifier = providerIdentifier
			object.maxIssuedAt = maxIssuedAt
			object.jsonData = jsonData
			object.wallet = wallet

			return object
		}
		return nil
	}
}
