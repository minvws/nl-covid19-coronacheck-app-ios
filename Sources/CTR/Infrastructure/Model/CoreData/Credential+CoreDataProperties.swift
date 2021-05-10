/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

extension Credential {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Credential> {
		return NSFetchRequest<Credential>(entityName: "Credential")
	}
	
	@NSManaged public var qrData: Data?
	@NSManaged public var validFrom: Date?
	@NSManaged public var greenCard: GreenCard?
	
}
