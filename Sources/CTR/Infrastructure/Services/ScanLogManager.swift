/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import SwiftUI

protocol ScanLogManaging: AnyObject {

	init( dataStoreManager: DataStoreManaging)

	func didWeScanQRs(seconds: Int) -> Bool

	func getScanEntries(seconds: Int) -> [ScanLogEntry]

	func addScanEntry(highRisk: Bool, date: Date)
}

class ScanLogManager: ScanLogManaging {

	static let highRisk: String = "2G"
	static let lowRisk: String = "3G"

	private var dataStoreManager: DataStoreManaging

	required init( dataStoreManager: DataStoreManaging = Services.dataStoreManager) {

		self.dataStoreManager = dataStoreManager
	}

	func didWeScanQRs(seconds: Int) -> Bool {

		return !getScanEntries(seconds: seconds).isEmpty
	}

	func getScanEntries(seconds: Int) -> [ScanLogEntry] {

		var result: [ScanLogEntry] = []
		let fromDate = Date().addingTimeInterval(TimeInterval(seconds) * -1)

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			result = ScanLogEntryModel.listEntriesStartingFrom(date: fromDate, managedContext: context)
		}
		return result
	}

	func addScanEntry(highRisk: Bool, date: Date) {

		// Nothing for now
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			let mode: String = highRisk ? ScanLogManager.highRisk : ScanLogManager.lowRisk
			ScanLogEntryModel.create(mode: mode, date: date, managedContext: context)
			dataStoreManager.save(context)
		}
	}
}
