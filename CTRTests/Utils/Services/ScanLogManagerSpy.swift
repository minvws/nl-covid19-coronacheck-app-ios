/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ScanLogManagingSpy: ScanLogManaging {

	var invokedDidWeScanQRs = false
	var invokedDidWeScanQRsCount = 0
	var invokedDidWeScanQRsParameters: (withinLastNumberOfSeconds: Int, Void)?
	var invokedDidWeScanQRsParametersList = [(withinLastNumberOfSeconds: Int, Void)]()
	var stubbedDidWeScanQRsResult: Bool! = false

	func didWeScanQRs(withinLastNumberOfSeconds: Int) -> Bool {
		invokedDidWeScanQRs = true
		invokedDidWeScanQRsCount += 1
		invokedDidWeScanQRsParameters = (withinLastNumberOfSeconds, ())
		invokedDidWeScanQRsParametersList.append((withinLastNumberOfSeconds, ()))
		return stubbedDidWeScanQRsResult
	}

	var invokedGetScanEntries = false
	var invokedGetScanEntriesCount = 0
	var invokedGetScanEntriesParameters: (withinLastNumberOfSeconds: Int, Void)?
	var invokedGetScanEntriesParametersList = [(withinLastNumberOfSeconds: Int, Void)]()
	var stubbedGetScanEntriesResult: Result<[ScanLogEntry], Error>!

	func getScanEntries(withinLastNumberOfSeconds: Int) -> Result<[ScanLogEntry], Error> {
		invokedGetScanEntries = true
		invokedGetScanEntriesCount += 1
		invokedGetScanEntriesParameters = (withinLastNumberOfSeconds, ())
		invokedGetScanEntriesParametersList.append((withinLastNumberOfSeconds, ()))
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

	var invokedDeleteExpiredScanLogEntries = false
	var invokedDeleteExpiredScanLogEntriesCount = 0
	var invokedDeleteExpiredScanLogEntriesParameters: (seconds: Int, Void)?
	var invokedDeleteExpiredScanLogEntriesParametersList = [(seconds: Int, Void)]()

	func deleteExpiredScanLogEntries(seconds: Int) {
		invokedDeleteExpiredScanLogEntries = true
		invokedDeleteExpiredScanLogEntriesCount += 1
		invokedDeleteExpiredScanLogEntriesParameters = (seconds, ())
		invokedDeleteExpiredScanLogEntriesParametersList.append((seconds, ()))
	}

	var invokedWipePersistedData = false
	var invokedWipePersistedDataCount = 0

	func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
