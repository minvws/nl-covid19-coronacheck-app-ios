/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

protocol ScanLogManaging: AnyObject {

	init( dataStoreManager: DataStoreManaging)

	func didWeScanQRs(withinLastNumberOfSeconds: Int) -> Bool

	func getScanEntries(withinLastNumberOfSeconds: Int) -> Result<[ScanLogEntry], Error>

	func addScanEntry(riskLevel: RiskLevel, date: Date)

	func deleteExpiredScanLogEntries(seconds: Int)

	func reset()
}

class ScanLogManager: ScanLogManaging {

	static let highRisk: String = "2G"
	static let lowRisk: String = "3G"

	private var dataStoreManager: DataStoreManaging

	required init( dataStoreManager: DataStoreManaging = Services.dataStoreManager) {

		self.dataStoreManager = dataStoreManager
	}

	func didWeScanQRs(withinLastNumberOfSeconds seconds: Int) -> Bool {

		switch getScanEntries(withinLastNumberOfSeconds: seconds) {
			case .success(let log): return !log.isEmpty
			case .failure: return false
		}
	}

	func getScanEntries(withinLastNumberOfSeconds seconds: Int) -> Result<[ScanLogEntry], Error> {

		var result: Result<[ScanLogEntry], Error> = .success([])
		let fromDate = Date().addingTimeInterval(TimeInterval(seconds) * -1)

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			result = ScanLogEntryModel.listEntriesStartingFrom(date: fromDate, managedContext: context)
		}
		return result
	}

	func addScanEntry(riskLevel: RiskLevel, date: Date) {

		// Nothing for now
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			let mode: String = riskLevel.isLow ? ScanLogManager.lowRisk : ScanLogManager.highRisk
			let entry = ScanLogEntryModel.create(mode: mode, date: date, managedContext: context)
			dataStoreManager.save(context)

			// Update the auto_increment identifier
			entry?.identifier = entry?.autoId ?? 0
			dataStoreManager.save(context)
		}
	}

	func deleteExpiredScanLogEntries(seconds: Int) {

		let untilDate = Date().addingTimeInterval(TimeInterval(seconds) * -1)
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			let result = ScanLogEntryModel.listEntriesUpTo(date: untilDate, managedContext: context)
			switch result {
				case let .success(entries):
					entries.forEach { context.delete($0) }
				case .failure:
					break
			}
			dataStoreManager.save(context)
		}
	}

	func reset() {

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			let result = ScanLogEntryModel.listEntries(managedContext: context)
			switch result {
				case let .success(entries):
					entries.forEach { context.delete($0) }
				case .failure:
					break
			}
			dataStoreManager.save(context)
		}
	}
}

extension NSManagedObject {

	var autoId: Int64 {
		/*
		 Core Data automatically generate auto increment id for each managed object.

		 The unique auto id is however not exposed through the api. However, there is [NSManagedObject objectID]
		 method that returns the unique path for each object.

		 Its usually in the form <x-coredata://SOME_ID/Entity/ObjectID>
		 e.g <x-coredata://197823AB-8917-408A-AD72-3BE89F0981F0/Message/p12> for object of Message entity with ID `p12.
		 The numeric part of the ID (last segment of the path) is the auto increment value for each object.
		 */

		let urlString = self.objectID.uriRepresentation().absoluteString
		let parts = urlString.components(separatedBy: "/")
		if let numberPart = parts.last?.replacingOccurrences(of: "p", with: ""),
			let value = Int64(numberPart) {
			return value
		}
		return 0
	}
}
