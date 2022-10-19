/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

extension ScanLogEntry {

	@discardableResult convenience init(
		mode: String,
		date: Date,
		managedContext: NSManagedObjectContext) {
		
		self.init(context: managedContext)
		self.date = date
		self.mode = mode
		self.identifier = 0
	}
}

class ScanLogEntryModel {

	static let entityName = "ScanLogEntry"

	/// List all the entries starting from a date
	/// - Parameters:
	///   - date: the date
	///   - managedContext: the managed object context
	/// - Returns: list of scan log entries
	class func listEntriesStartingFrom(date: Date, managedContext: NSManagedObjectContext) -> Result<[ScanLogEntry], Error> {

		let fetchRequest = NSFetchRequest<ScanLogEntry>(entityName: entityName)
		let fromPredicate = NSPredicate(format: "date >= %@", date as NSDate)
		fetchRequest.predicate = fromPredicate

		do {
			let fetchedResults = try managedContext.fetch(fetchRequest)
			return .success(fetchedResults)
		} catch let error {
			return .failure(error)
		}
	}

	/// List all the entries up until a date
	/// - Parameters:
	///   - date: the date
	///   - managedContext: the managed object context
	/// - Returns: list of scan log entries
	class func listEntriesUpTo(date: Date, managedContext: NSManagedObjectContext) -> Result<[ScanLogEntry], Error> {

		let fetchRequest = NSFetchRequest<ScanLogEntry>(entityName: entityName)
		let fromPredicate = NSPredicate(format: "date < %@", date as NSDate)
		fetchRequest.predicate = fromPredicate

		do {
			let fetchedResults = try managedContext.fetch(fetchRequest)
			return .success(fetchedResults)
		} catch let error {
			return .failure(error)
		}
	}

	/// List all the entries
	/// - Parameters:
	///   - managedContext: the managed object context
	/// - Returns: list of scan log entries
	class func listEntries(managedContext: NSManagedObjectContext) -> Result<[ScanLogEntry], Error> {

		let fetchRequest = NSFetchRequest<ScanLogEntry>(entityName: entityName)
		do {
			let fetchedResults = try managedContext.fetch(fetchRequest)
			return .success(fetchedResults)
		} catch let error {
			return .failure(error)
		}
	}
}

extension Array {

	func sortedByIdentifier() -> [ScanLogEntry] where Element == ScanLogEntry {
		sorted(by: { ($0.identifier) < ($1.identifier) })
	}
}
