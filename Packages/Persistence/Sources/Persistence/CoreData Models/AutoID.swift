/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

extension NSManagedObject {
	
	public var autoId: Int64 {
		/*
		 Core Data automatically generate auto increment id for each managed object.
		 
		 The unique auto id is however not exposed through the api. However, there is [NSManagedObject objectID]
		 method that returns the unique path for each object.
		 
		 Its usually in the form <x-coredata://SOME_ID/Entity/ObjectID>
		 e.g <x-coredata://197823AB-8917-408A-AD72-3BE89F0981F0/Message/p12> for object of Message entity with ID `p12.
		 The numeric part of the ID (last segment of the path) is the auto increment value for each object.
		 */
		
		let urlString = self.objectID.uriRepresentation().absoluteString
		let parts = urlString.components(separatedBy: "/")
		if let numberPart = parts.last?.replacingOccurrences(of: "p", with: ""),
		   let value = Int64(numberPart) {
			return value
		}
		return 0
	}
}
