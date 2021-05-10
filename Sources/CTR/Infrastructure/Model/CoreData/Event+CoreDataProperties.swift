/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

extension Event {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
		return NSFetchRequest<Event>(entityName: "Event")
	}
	
	@NSManaged public var type: String?
	@NSManaged public var issuedAt: Date?
	@NSManaged public var jsonData: Data?
	@NSManaged public var wallet: Wallet?
	
}
