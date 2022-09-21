/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import CoreData

class GreenCardHintModel {
	
	static let entityName = "GreenCardHint"
	
	@discardableResult class func create(
		greenCard: GreenCard,
		hint: String,
		managedContext: NSManagedObjectContext) -> GreenCardHint? {
			
			guard let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedContext) as? GreenCardHint else {
				return nil
			}
			
			object.hint = hint
			object.greenCard = greenCard
			
			return object
		}
}
