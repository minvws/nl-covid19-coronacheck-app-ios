/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

public struct RemovedEventItem: Equatable {
	public let objectID: NSManagedObjectID
	public let eventDate: Date
	public let reason: String
	public let type: OriginType
	
	public init(objectID: NSManagedObjectID, eventDate: Date, reason: String, type: OriginType) {
		self.objectID = objectID
		self.eventDate = eventDate
		self.reason = reason
		self.type = type
	}
}
