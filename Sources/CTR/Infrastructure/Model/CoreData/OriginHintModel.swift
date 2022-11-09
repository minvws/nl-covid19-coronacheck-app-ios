/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import CoreData

extension OriginHint {
	
	@discardableResult convenience init(
		origin: Origin,
		hint: String,
		managedContext: NSManagedObjectContext) {
			
		self.init(context: managedContext)
		self.hint = hint
		self.origin = origin
	}
}
