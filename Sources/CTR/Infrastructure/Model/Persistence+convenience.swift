/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Persistence
import CoreData
import Transport

extension Array where Element == RemoteGreenCards.BlobExpiry {
	
	/// Determine which BlobExpiry elements ("blockItems") match EventGroups which were sent to be signed:
	func combinedWith(matchingEventGroups eventGroups: [EventGroup]) -> [(RemoteGreenCards.BlobExpiry, EventGroup)] {
		reduce([]) { partialResult, blockItem in
			guard let matchingEvent = eventGroups.first(where: { "\($0.uniqueIdentifier)" == blockItem.identifier }) else { return partialResult }
			return partialResult + [(blockItem, matchingEvent)]
		}
	}
}

class GreenCardModel {

	class func fetchByIds(objectIDs: [NSManagedObjectID]) -> Result<[GreenCard], Error> {

		var result = [GreenCard]()
		for objectID in objectIDs {
			do {
				if let greenCard = try Current.dataStoreManager.managedObjectContext().existingObject(with: objectID) as? GreenCard {
					result.append(greenCard)
				}
			} catch let error {
				return .failure(error)
			}
		}
		return .success(result)
	}
}

