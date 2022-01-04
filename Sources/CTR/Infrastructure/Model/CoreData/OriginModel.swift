/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

enum OriginType: String {

	case recovery
	case test
	case vaccination
	case vaccinationassessment
}

class OriginModel {

	static let entityName = "Origin"

	@discardableResult class func create(
		type: OriginType,
		eventDate: Date,
		expirationTime: Date,
		validFromDate: Date,
		doseNumber: Int?,
		greenCard: GreenCard,
		managedContext: NSManagedObjectContext) -> Origin? {

		guard let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedContext) as? Origin else {
			return nil
		}

		object.type = type.rawValue
		object.eventDate = eventDate
		object.expirationTime = expirationTime
		object.validFromDate = validFromDate
		if let doseNumber = doseNumber {
			object.doseNumber = doseNumber as NSNumber
		}
		object.greenCard = greenCard

		return object
	}
}

extension Array {

	/// Find the Origin element with the latest expiry date (note: this could still be in the past).
	func latestOriginExpiryTime() -> Date? where Element == Origin {
		sorted(by: { ($0.expirationTime ?? .distantPast) < ($1.expirationTime ?? .distantPast) })
			.last?
			.expirationTime
	}
}
