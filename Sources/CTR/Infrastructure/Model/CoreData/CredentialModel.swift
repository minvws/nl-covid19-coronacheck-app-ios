/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

extension Credential {

	@discardableResult convenience init(
		data: Data,
		validFrom: Date,
		expirationTime: Date,
		version: Int32 = 1,
		greenCard: GreenCard,
		managedContext: NSManagedObjectContext) {

		self.init(context: managedContext)
		self.data = data
		self.version = version
		self.validFrom = validFrom
		self.expirationTime = expirationTime
		self.greenCard = greenCard
	}
}

extension Array {

	/// Find the Credential element with the latest expiry date (note: this could still be in the past).
	func latestCredentialExpiryTime() -> Date? where Element == Credential {
		sorted(by: { ($0.expirationTime ?? .distantPast) < ($1.expirationTime ?? .distantPast) })
			.last?
			.expirationTime
	}
}
