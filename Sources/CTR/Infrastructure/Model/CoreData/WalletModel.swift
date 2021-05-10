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

	@discardableResult class func initialize(managedContext: NSManagedObjectContext) -> Wallet? {

		let list = WalletModel.listAll(managedContext: managedContext)
		if !list.isEmpty {
			return list.first
		}

		return WalletModel.create(label: "main", managedContext: managedContext)
	}

	class func listAll(managedContext: NSManagedObjectContext) -> [Wallet] {
		
		let request = NSFetchRequest<Wallet>(entityName: entityName)
		
		do {
			let fetchedResults = try managedContext.fetch(request)
			return fetchedResults
		} catch {}
		return []
	}
}
