/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ScanLogManagingSpy: ScanLogManaging {

	required init(dataStoreManager: DataStoreManaging) {}

	var invokedDidWeScanQRs = false
	var invokedDidWeScanQRsCount = 0
	var invokedDidWeScanQRsParameters: (seconds: Int, Void)?
	var invokedDidWeScanQRsParametersList = [(seconds: Int, Void)]()
	var stubbedDidWeScanQRsResult: Bool! = false

	func didWeScanQRs(seconds: Int) -> Bool {
		invokedDidWeScanQRs = true
		invokedDidWeScanQRsCount += 1
		invokedDidWeScanQRsParameters = (seconds, ())
		invokedDidWeScanQRsParametersList.append((seconds, ()))
		return stubbedDidWeScanQRsResult
	}

	var invokedGetScanEntries = false
	var invokedGetScanEntriesCount = 0
	var invokedGetScanEntriesParameters: (seconds: Int, Void)?
	var invokedGetScanEntriesParametersList = [(seconds: Int, Void)]()
	var stubbedGetScanEntriesResult: [ScanLogEntry]! = []

	func getScanEntries(seconds: Int) -> [ScanLogEntry] {
		invokedGetScanEntries = true
		invokedGetScanEntriesCount += 1
		invokedGetScanEntriesParameters = (seconds, ())
		invokedGetScanEntriesParametersList.append((seconds, ()))
		return stubbedGetScanEntriesResult
	}

	var invokedAddScanEntry = false
	var invokedAddScanEntryCount = 0
	var invokedAddScanEntryParameters: (riskLevel: RiskLevel, date: Date)?
	var invokedAddScanEntryParametersList = [(riskLevel: RiskLevel, date: Date)]()

	func addScanEntry(riskLevel: RiskLevel, date: Date) {
		invokedAddScanEntry = true
		invokedAddScanEntryCount += 1
		invokedAddScanEntryParameters = (riskLevel, date)
		invokedAddScanEntryParametersList.append((riskLevel, date))
	}
}

extension ScanLogManagingSpy {
	convenience init() {
		self.init(dataStoreManager: DataStoreManager(.inMemory, flavor: .verifier))
	}
}
