/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

class ScanLogEntryModel {

	static let entityName = "ScanLogEntry"

	/// Create a scan log entry
	/// - Parameters:
	///   - mode: the scanned mode
	///   - date: the date
	///   - managedContext: the managed object context
	/// - Returns: optional newly created scan log entry
	@discardableResult class func create(
		mode: String,
		date: Date,
		managedContext: NSManagedObjectContext) -> ScanLogEntry? {

		guard let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedContext) as? ScanLogEntry else {
			return nil
		}

		object.date = date
		object.mode = mode
		object.identifier = 0
		return object
	}

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
}

extension Array {

	func sortedByIdentifier() -> [ScanLogEntry] where Element == ScanLogEntry {
		sorted(by: { ($0.identifier) < ($1.identifier) })
	}
}
