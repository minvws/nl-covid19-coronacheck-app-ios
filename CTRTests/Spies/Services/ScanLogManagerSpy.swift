/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import TestingShared
import Persistence

class ScanLogManagingSpy: ScanLogManaging {

	var invokedDidWeScanQRs = false
	var invokedDidWeScanQRsCount = 0
	var invokedDidWeScanQRsParameters: (withinLastNumberOfSeconds: Int, now: Date)?
	var invokedDidWeScanQRsParametersList = [(withinLastNumberOfSeconds: Int, now: Date)]()
	var stubbedDidWeScanQRsResult: Bool! = false

	func didWeScanQRs(withinLastNumberOfSeconds: Int, now: Date) -> Bool {
		invokedDidWeScanQRs = true
		invokedDidWeScanQRsCount += 1
		invokedDidWeScanQRsParameters = (withinLastNumberOfSeconds, now)
		invokedDidWeScanQRsParametersList.append((withinLastNumberOfSeconds, now))
		return stubbedDidWeScanQRsResult
	}

	var invokedGetScanEntries = false
	var invokedGetScanEntriesCount = 0
	var invokedGetScanEntriesParameters: (withinLastNumberOfSeconds: Int, now: Date)?
	var invokedGetScanEntriesParametersList = [(withinLastNumberOfSeconds: Int, now: Date)]()
	var stubbedGetScanEntriesResult: Result<[ScanLogEntry], Error>!

	func getScanEntries(withinLastNumberOfSeconds: Int, now: Date) -> Result<[ScanLogEntry], Error> {
		invokedGetScanEntries = true
		invokedGetScanEntriesCount += 1
		invokedGetScanEntriesParameters = (withinLastNumberOfSeconds, now)
		invokedGetScanEntriesParametersList.append((withinLastNumberOfSeconds, now))
		return stubbedGetScanEntriesResult
	}

	var invokedAddScanEntry = false
	var invokedAddScanEntryCount = 0
	var invokedAddScanEntryParameters: (verificationPolicy: VerificationPolicy, date: Date)?
	var invokedAddScanEntryParametersList = [(verificationPolicy: VerificationPolicy, date: Date)]()

	func addScanEntry(verificationPolicy: VerificationPolicy, date: Date) {
		invokedAddScanEntry = true
		invokedAddScanEntryCount += 1
		invokedAddScanEntryParameters = (verificationPolicy, date)
		invokedAddScanEntryParametersList.append((verificationPolicy, date))
	}

	var invokedWipePersistedData = false
	var invokedWipePersistedDataCount = 0

	func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
