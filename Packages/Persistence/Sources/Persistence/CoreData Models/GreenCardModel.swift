/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

public enum GreenCardType: String {

	case domestic
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

	/// Get the active credential with the longest lifetime for a date
	/// - Parameter now: the date for the credential (defaults to now)
	/// - Returns: the active credential
	public func getActiveDomesticCredential(forDate now: Date = Date()) -> Credential? {
		
		guard getType() == GreenCardType.domestic else {
			return nil
		}

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
