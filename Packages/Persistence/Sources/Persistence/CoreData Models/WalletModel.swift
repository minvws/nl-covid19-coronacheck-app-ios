/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

public final class WalletModel {

	static let entityName = "Wallet"

	/// List all the wallets
	/// - Parameter managedContext: the managed object context
	/// - Returns: a list of all wallets
	public class func listAll(managedContext: NSManagedObjectContext) -> [Wallet] {
		
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
	public class func findBy(label: String, managedContext: NSManagedObjectContext) -> Wallet? {

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

extension Wallet {
	
	/// Create a wallet
	/// - Parameters:
	///   - label: the label of the wallet
	///   - managedContext: the managed object context
	/// - Returns: optional newly created wallet
	@discardableResult public convenience init(
		label: String,
		managedContext: NSManagedObjectContext) {

		self.init(context: managedContext)
		self.label = label
	}
	
	/// Get the greencards, strongly typed.
	public func castGreenCards() -> [GreenCard]? {
		
		return greenCards?.compactMap({ $0 as? GreenCard })
	}
	
	/// Get the eventgroups, strongly typed.
	public func castEventGroups() -> [EventGroup] {
		
		return eventGroups?.compactMap({ $0 as? EventGroup }).sorted(by: { $0.autoId < $1.autoId }) ?? []
	}
}
