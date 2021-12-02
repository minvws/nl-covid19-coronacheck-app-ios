/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// Temp, to be replaced by CoreData Class
struct ScanLogEntry {

	let timeStamp: TimeInterval

	let highRisk: Bool

	let sequenceNumber: Int64
}

protocol ScanManaging: AnyObject {

	init( dataStoreManager: DataStoreManaging)

	func didWeScanQRs(seconds: Int) -> Bool

	func getScanEntries(seconds: Int) -> [ScanLogEntry]

	func addScanEntry(highRisk: Bool, timeStamp: TimeInterval)
}

class ScanManager: ScanManaging {

	required init( dataStoreManager: DataStoreManaging) {
		// Required by protocol
	}

	func didWeScanQRs(seconds: Int) -> Bool {
		return true
	}

	func getScanEntries(seconds: Int) -> [ScanLogEntry] {
		return []
	}

	func addScanEntry(highRisk: Bool, timeStamp: TimeInterval) {

		// Nothing for now
	}
}
