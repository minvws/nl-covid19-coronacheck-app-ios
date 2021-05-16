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

	/// Create a wallet
	/// - Parameters:
	///   - label: the label of the wallet
	///   - managedContext: the managed object context
	/// - Returns: optional newly created wallet
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

	/// List all the wallets
	/// - Parameter managedContext: the managed object context
	/// - Returns: a list of all wallets
	class func listAll(managedContext: NSManagedObjectContext) -> [Wallet] {
		
		let fetchRequest = NSFetchRequest<Wallet>(entityName: entityName)
		
		do {
			let fetchedResults = try managedContext.fetch(fetchRequest)
			return fetchedResults
		} catch {}
		return []
	}

	/// Find a wallet by its label
	/// - Parameters:
	///   - label: the label to search on
	///   - managedContext: the managed object context
	/// - Returns: the wallet with the label
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
