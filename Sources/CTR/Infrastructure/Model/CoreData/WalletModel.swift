/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

class WalletModel {

	static let entityName = "Wallet"

	@discardableResult class func create(
		label: String,
		managedContext: NSManagedObjectContext) -> Wallet? {

		if let object = NSEntityDescription.insertNewObject(
			forEntityName: entityName,
			into: managedContext) as? Wallet {

			object.label = label
			return object
		}
		return nil
	}

	class func listAll(managedContext: NSManagedObjectContext) -> [Wallet] {
		
		let fetchRequest = NSFetchRequest<Wallet>(entityName: entityName)
		
		do {
			let fetchedResults = try managedContext.fetch(fetchRequest)
			return fetchedResults
		} catch {}
		return []
	}

	class func findBy(label: String, managedContext: NSManagedObjectContext) -> Wallet? {

		let fetchRequest = NSFetchRequest<Wallet>(entityName: entityName)
		let namePredicate = NSPredicate(format: "label = %@", label)
		fetchRequest.predicate = namePredicate

		do {
			let fetchedResults = try managedContext.fetch(fetchRequest)
			return fetchedResults.first
		} catch {}
		return nil
	}
}
