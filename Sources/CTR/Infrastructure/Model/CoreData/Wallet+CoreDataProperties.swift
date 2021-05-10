/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

extension Wallet {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<Wallet> {
		return NSFetchRequest<Wallet>(entityName: "Wallet")
	}

	@NSManaged public var label: String?
	@NSManaged public var events: NSSet?
	@NSManaged public var greenCards: NSSet?

}

// MARK: Generated accessors for events
extension Wallet {

	@objc(addEventsObject:)
	@NSManaged public func addToEvents(_ value: Event)

	@objc(removeEventsObject:)
	@NSManaged public func removeFromEvents(_ value: Event)

	@objc(addEvents:)
	@NSManaged public func addToEvents(_ values: NSSet)

	@objc(removeEvents:)
	@NSManaged public func removeFromEvents(_ values: NSSet)

}

// MARK: Generated accessors for greenCards
extension Wallet {

	@objc(addGreenCardsObject:)
	@NSManaged public func addToGreenCards(_ value: GreenCard)

	@objc(removeGreenCardsObject:)
	@NSManaged public func removeFromGreenCards(_ value: GreenCard)

	@objc(addGreenCards:)
	@NSManaged public func addToGreenCards(_ values: NSSet)

	@objc(removeGreenCards:)
	@NSManaged public func removeFromGreenCards(_ values: NSSet)

}
