/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

enum GreenCardType: String {

	case domestic
	case eu
}

class GreenCardModel {

	static let entityName = "GreenCard"

	@discardableResult class func create(
		type: GreenCardType,
		wallet: Wallet,
		managedContext: NSManagedObjectContext) -> GreenCard? {

		if let object = NSEntityDescription.insertNewObject(
			forEntityName: entityName,
			into: managedContext) as? GreenCard {

			object.type = type.rawValue
			object.wallet = wallet

			return object
		}
		return nil
	}
}

extension GreenCard {

	/// Get the type of a greenCard as a GreenCardType
	/// - Returns: greenCard type
	func getType() -> GreenCardType? {
		if let type = type {
			return GreenCardType(rawValue: type)
		}
		return nil
	}

	/// Get the active credential with the longest lifetime for a date
	/// - Parameter now: the date for the credential (defaults to now)
	/// - Returns: the active credential
	func getActiveCredential(forDate now: Date = Date()) -> Credential? {

		if let list = credentials?.allObjects as? [Credential] {
			return list
				.filter { $0.expirationTime != nil }
				.filter { $0.validFrom != nil }
				.filter { $0.expirationTime! > now }
				.filter { $0.validFrom! < now }
				.sorted { $0.validFrom! < $1.validFrom! }
				.last
		}
		return nil
	}
}
