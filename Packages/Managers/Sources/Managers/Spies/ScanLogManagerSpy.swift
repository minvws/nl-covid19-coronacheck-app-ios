/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Persistence
import Models

public class ScanLogManagingSpy: ScanLogManaging {

	public init() {}
	
	public var invokedDidWeScanQRs = false
	public var invokedDidWeScanQRsCount = 0
	public var invokedDidWeScanQRsParameters: (withinLastNumberOfSeconds: Int, now: Date)?
	public var invokedDidWeScanQRsParametersList = [(withinLastNumberOfSeconds: Int, now: Date)]()
	public var stubbedDidWeScanQRsResult: Bool! = false

	public func didWeScanQRs(withinLastNumberOfSeconds: Int, now: Date) -> Bool {
		invokedDidWeScanQRs = true
		invokedDidWeScanQRsCount += 1
		invokedDidWeScanQRsParameters = (withinLastNumberOfSeconds, now)
		invokedDidWeScanQRsParametersList.append((withinLastNumberOfSeconds, now))
		return stubbedDidWeScanQRsResult
	}

	public var invokedGetScanEntries = false
	public var invokedGetScanEntriesCount = 0
	public var invokedGetScanEntriesParameters: (withinLastNumberOfSeconds: Int, now: Date)?
	public var invokedGetScanEntriesParametersList = [(withinLastNumberOfSeconds: Int, now: Date)]()
	public var stubbedGetScanEntriesResult: Result<[ScanLogEntry], Error>!

	public func getScanEntries(withinLastNumberOfSeconds: Int, now: Date) -> Result<[ScanLogEntry], Error> {
		invokedGetScanEntries = true
		invokedGetScanEntriesCount += 1
		invokedGetScanEntriesParameters = (withinLastNumberOfSeconds, now)
		invokedGetScanEntriesParametersList.append((withinLastNumberOfSeconds, now))
		return stubbedGetScanEntriesResult
	}

	public var invokedAddScanEntry = false
	public var invokedAddScanEntryCount = 0
	public var invokedAddScanEntryParameters: (verificationPolicy: VerificationPolicy, date: Date)?
	public var invokedAddScanEntryParametersList = [(verificationPolicy: VerificationPolicy, date: Date)]()

	public func addScanEntry(verificationPolicy: VerificationPolicy, date: Date) {
		invokedAddScanEntry = true
		invokedAddScanEntryCount += 1
		invokedAddScanEntryParameters = (verificationPolicy, date)
		invokedAddScanEntryParametersList.append((verificationPolicy, date))
	}

	public var invokedWipePersistedData = false
	public var invokedWipePersistedDataCount = 0

	public func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}
