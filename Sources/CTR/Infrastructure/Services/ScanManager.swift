/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ScanManaging: AnyObject {

	init( dataStoreManager: DataStoreManaging)

	func didWeScanQRs(seconds: Int) -> Bool

	func getScanEntries(seconds: Int) -> [ScanLogEntry]

	func addScanEntry(highRisk: Bool, timeStamp: TimeInterval)
}

class ScanManager: ScanManaging {

	private var dataStoreManager: DataStoreManaging

	required init( dataStoreManager: DataStoreManaging = Services.dataStoreManager) {

		self.dataStoreManager = dataStoreManager
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
