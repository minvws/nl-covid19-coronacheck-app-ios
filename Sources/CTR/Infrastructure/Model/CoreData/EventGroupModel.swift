/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

class EventGroupModel {

	static let entityName = "EventGroup"

	@discardableResult class func create(
		type: EventMode,
		providerIdentifier: String,
		maxIssuedAt: Date,
		jsonData: Data,
		wallet: Wallet,
		managedContext: NSManagedObjectContext) -> EventGroup? {

		guard let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedContext) as? EventGroup else {
			return nil
		}

		object.type = type.rawValue
		object.providerIdentifier = providerIdentifier
		object.maxIssuedAt = maxIssuedAt
		object.jsonData = jsonData
		object.wallet = wallet

		return object
	}
	
	class func delete(_ objectID: NSManagedObjectID, managedObjectContext: NSManagedObjectContext, save: () -> Void) -> Result<Bool, Error> {

		do {
			if let eventGroup = try managedObjectContext.existingObject(with: objectID) as? EventGroup {
				managedObjectContext.delete(eventGroup)
				save()
				return .success(true)
			} else {
				return .success(false)
			}
		} catch let error {
			return .failure(error)
		}
	}
	
	@discardableResult class func findBy(
		wallet: Wallet,
		type: EventMode,
		providerIdentifier: String,
		maxIssuedAt: Date,
		jsonData: Data) -> EventGroup? {
			
		if let list = wallet.eventGroups?.allObjects as? [EventGroup] {
			
			return list
				.filter { $0.type == type.rawValue }
				.filter { $0.providerIdentifier == providerIdentifier }
				.filter { $0.maxIssuedAt == maxIssuedAt }
				.filter { $0.jsonData == jsonData }
				.last
		}
		
		return nil
	}
}
