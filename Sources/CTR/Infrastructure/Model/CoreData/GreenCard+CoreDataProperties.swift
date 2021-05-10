/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

extension GreenCard {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<GreenCard> {
		return NSFetchRequest<GreenCard>(entityName: "GreenCard")
	}

	@NSManaged public var type: String?
	@NSManaged public var issuedAt: Date?
	@NSManaged public var wallet: Wallet?
	@NSManaged public var credentials: NSSet?

}

// MARK: Generated accessors for credentials
extension GreenCard {

	@objc(addCredentialsObject:)
	@NSManaged public func addToCredentials(_ value: Credential)

	@objc(removeCredentialsObject:)
	@NSManaged public func removeFromCredentials(_ value: Credential)

	@objc(addCredentials:)
	@NSManaged public func addToCredentials(_ values: NSSet)

	@objc(removeCredentials:)
	@NSManaged public func removeFromCredentials(_ values: NSSet)

}
