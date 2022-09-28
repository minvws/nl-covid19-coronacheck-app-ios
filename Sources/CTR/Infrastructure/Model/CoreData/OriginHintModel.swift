/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import CoreData

class OriginHintModel {
	
	static let entityName = "OriginHint"
	
	@discardableResult class func create(
		origin: Origin,
		hint: String,
		managedContext: NSManagedObjectContext) -> OriginHint? {
			
		guard let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedContext) as? OriginHint else {
			return nil
		}
		
		object.hint = hint
		object.origin = origin
		
		return object
	}
}
