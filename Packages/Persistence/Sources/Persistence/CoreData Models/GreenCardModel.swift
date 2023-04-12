/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

public enum GreenCardType: String {

	case eu
}

extension GreenCard {
	
	@discardableResult public convenience init(
		type: GreenCardType,
		wallet: Wallet,
		managedContext: NSManagedObjectContext) {

		self.init(context: managedContext)
		self.type = type.rawValue
		self.wallet = wallet
	}

	/// Get the type of a greenCard as a GreenCardType
	/// - Returns: greenCard type
	public func getType() -> GreenCardType? {
		
		if let type {
			return GreenCardType(rawValue: type)
		}
		return nil
	}

	public func originsActiveNowOrBeforeThresholdFromNow(now: Date, thresholdDays: Int) -> [Origin]? {
		
		let thresholdEndDate = now.addingTimeInterval(TimeInterval(60 * 60 * 24 * thresholdDays))

		return castOrigins()?
			.filter { origin in
				(origin.validFromDate ?? .distantFuture) < thresholdEndDate
			}
			.filter { origin in
				(origin.expirationTime ?? .distantPast) > now
			}
	}

	public func hasActiveCredentialNowOrInFuture(forDate now: Date = Date()) -> Bool {

		return !activeCredentialsNowOrInFuture(forDate: now).isEmpty
	}

	public func activeCredentialsNowOrInFuture(forDate now: Date = Date()) -> [Credential] {
		
		guard let list = castCredentials() else { return [] }

		let activeCredentialsNowOrInFuture = list
			.filter { $0.expirationTime != nil }
			.filter { $0.expirationTime! > now }

		return activeCredentialsNowOrInFuture
	}

	public func currentOrNextActiveCredential(forDate now: Date = Date()) -> Credential? {
		
		let activeCrendentials = activeCredentialsNowOrInFuture(forDate: now)
		return activeCrendentials.sorted(by: {
			($0.validFrom ?? .distantFuture) < ($1.validFrom ?? .distantFuture)
		}).first
	}

	/// Get the credentials, strongly typed.
	public func castCredentials() -> [Credential]? {
		
		return credentials?.compactMap({ $0 as? Credential })
	}

	/// Get the origins, strongly typed.
	public func castOrigins() -> [Origin]? {
		
		return origins?.compactMap({ $0 as? Origin })
	}
	
	public func getLatestInternationalCredential() -> Credential? {
		
		guard getType() == GreenCardType.eu else {
			return nil
		}
		// An international greencard has 1 credential, that may be expired.
		return castCredentials()?.last
	}
	
	public func delete(context: NSManagedObjectContext) {
		
		context.delete(self)
	}
}

public class GreenCardModel {

	public class func fetchByIds(objectIDs: [NSManagedObjectID], managedObjectContext: NSManagedObjectContext) -> Result<[GreenCard], Error> {

		var result = [GreenCard]()
		for objectID in objectIDs {
			do {
				if let greenCard = try managedObjectContext.existingObject(with: objectID) as? GreenCard {
					result.append(greenCard)
				}
			} catch let error {
				return .failure(error)
			}
		}
		return .success(result)
	}
}
