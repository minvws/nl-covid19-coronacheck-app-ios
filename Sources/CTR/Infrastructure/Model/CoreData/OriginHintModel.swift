/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import CoreData

class OriginHintModel {
	
	@discardableResult class func create(
		origin: Origin,
		hint: String,
		managedContext: NSManagedObjectContext) -> OriginHint? {
			
		let object = OriginHint(context: managedContext)
		object.hint = hint
		object.origin = origin
		
		return object
	}
}
