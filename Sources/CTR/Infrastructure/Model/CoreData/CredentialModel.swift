/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

class CredentialModel {

	static let entityName = "Credential"

	@discardableResult class func create(
		data: Data,
		validFrom: Date,
		expirationTime: Date,
		version: Int32 = 1,
		greenCard: GreenCard,
		managedContext: NSManagedObjectContext) -> Credential? {

		if let object = NSEntityDescription.insertNewObject(
			forEntityName: entityName,
			into: managedContext) as? Credential {

			object.data = data
			object.version = version
			object.validFrom = validFrom
			object.expirationTime = expirationTime
			object.greenCard = greenCard

			return object
		}
		return nil
	}
}

extension Array {

	/// Filter, returning only Credentials where the expirationTime is still in the future (relative to a given `now`).
	func filterValid(now: Date = Date()) -> [Credential] where Element == Credential {
		filter { ($0.expirationTime ?? .distantPast) > now }
	}

	/// Find the Credential element with the latest expiry date (note: this could still be in the past).
	func latestCredentialExpiryTime() -> Date? where Element == Credential {
		sorted(by: { ($0.expirationTime ?? .distantPast) < ($1.expirationTime ?? .distantPast) })
			.last?
			.expirationTime
	}
}
