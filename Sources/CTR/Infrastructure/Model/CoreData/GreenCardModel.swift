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

	class func fetchByIds(objectIDs: [NSManagedObjectID]) -> Result<[GreenCard], Error> {

		var result = [GreenCard]()
		for objectID in objectIDs {
			do {
				if let greenCard = try Services.dataStoreManager.managedObjectContext().existingObject(with: objectID) as? GreenCard {
					result.append(greenCard)
				}
			} catch let error {
				return .failure(error)
			}
		}
		return .success(result)
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
				.filter { $0.validFrom! <= now }
				.sorted { $0.validFrom! < $1.validFrom! }
				.last
		}
		return nil
	}

	func originsActiveNowOrBeforeThresholdFromNow(now: Date, thresholdDays: Int) -> [Origin]? {
		let thresholdEndDate = now.addingTimeInterval(TimeInterval(60 * 60 * 24 * thresholdDays))

		return castOrigins()?
			.filter { origin in
				(origin.validFromDate ?? .distantFuture) < thresholdEndDate
			}
			.filter { origin in
				(origin.expirationTime ?? .distantPast) > now
			}
	}

	func hasActiveCredentialNowOrInFuture(forDate now: Date = Date()) -> Bool {

		return !activeCredentialsNowOrInFuture(forDate: now).isEmpty
	}

	func activeCredentialsNowOrInFuture(forDate now: Date = Date()) -> [Credential] {
		guard let list = credentials?.allObjects as? [Credential] else { return [] }

		let activeCredentialsNowOrInFuture = list
			.filter { $0.expirationTime != nil }
			.filter { $0.expirationTime! > now }

		return activeCredentialsNowOrInFuture
	}

	func currentOrNextActiveCredential(forDate now: Date = Date()) -> Credential? {
		let activeCrendentials = activeCredentialsNowOrInFuture(forDate: now)
		return activeCrendentials.sorted(by: {
			($0.validFrom ?? .distantFuture) < ($1.validFrom ?? .distantFuture)
		}).first
	}

	/// Get the credentials, strongly typed.
	func castCredentials() -> [Credential]? {
		return credentials?.compactMap({ $0 as? Credential })
	}

	/// Get the origins, strongly typed.
	func castOrigins() -> [Origin]? {
		return origins?.compactMap({ $0 as? Origin })
	}
}
