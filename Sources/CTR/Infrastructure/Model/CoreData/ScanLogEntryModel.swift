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

		if let object = NSEntityDescription.insertNewObject(
			forEntityName: entityName,
			into: managedContext) as? ScanLogEntry {

			object.date = date
			object.mode = mode
			object.identifier = 0
			return object
		}
		return nil
	}

	class func listFrom(date: Date, managedContext: NSManagedObjectContext) -> [ScanLogEntry] {

		let fetchRequest = NSFetchRequest<ScanLogEntry>(entityName: entityName)
		let fromPredicate = NSPredicate(format: "date >= %@", date as CVarArg)
		fetchRequest.predicate = fromPredicate

		do {
			let fetchedResults = try managedContext.fetch(fetchRequest)
			return fetchedResults
		} catch {}
		return []
	}

	class func listTo(date: Date, managedContext: NSManagedObjectContext) -> [ScanLogEntry] {

		let fetchRequest = NSFetchRequest<ScanLogEntry>(entityName: entityName)
		let fromPredicate = NSPredicate(format: "date < %@", date as CVarArg)
		fetchRequest.predicate = fromPredicate

		do {
			let fetchedResults = try managedContext.fetch(fetchRequest)
			return fetchedResults
		} catch {}
		return []
	}
}
