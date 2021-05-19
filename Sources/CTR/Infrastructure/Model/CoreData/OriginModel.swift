/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

enum OriginType: String {

	case vaccination
	case recovery
	case negativeTest
}

class OriginModel {

	static let entityName = "Origin"

	@discardableResult class func create(
		type: OriginType,
		eventDate: Date,
		expireDate: Date,
		greenCard: GreenCard,
		managedContext: NSManagedObjectContext) -> Origin? {

		if let object = NSEntityDescription.insertNewObject(
			forEntityName: entityName,
			into: managedContext) as? Origin {

			object.type = type.rawValue
			object.eventDate = eventDate
			object.expireDate = expireDate
			object.greenCard = greenCard

			return object
		}
		return nil
	}
}
