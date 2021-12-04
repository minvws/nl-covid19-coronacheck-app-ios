/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import XCTest
import Nimble

class ScanLogManagerTests: XCTestCase {

	private var sut: ScanLogManager!
	private var dataStoreManager: DataStoreManaging!

	override func setUp() {

		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory, flavor: .verifier)
		sut = ScanLogManager(dataStoreManager: dataStoreManager)
	}

	func test_didWeScanQR_nothingScanned() {

		// Given

		// When
		let result = sut.didWeScanQRs(seconds: 3600)

		// Then
		expect(result) == false
	}

	func test_didWeScanQR_oneScan_inTimeWindow() {

		// Given
		let date = Date()
		sut.addScanEntry(highRisk: true, date: date)

		// When
		let result = sut.didWeScanQRs(seconds: 3600)

		// Then
		expect(result) == true
	}

	func test_didWeScanQR_oneScan_outsideTimeWindow() {

		// Given
		let date = Date().addingTimeInterval(ago * 4000 * seconds)
		sut.addScanEntry(highRisk: true, date: date)

		// When
		let result = sut.didWeScanQRs(seconds: 3600)

		// Then
		expect(result) == false
	}

	func test_getScanEntries_nothingScanned() {

		// Given

		// When
		let result = sut.getScanEntries(seconds: 3600)

		// Then
		expect(result).to(beEmpty())
	}

	func test_getScanEntries_oneScan_inTimeWindow_highrisk() {

		// Given
		let date = Date()
		sut.addScanEntry(highRisk: true, date: date)

		// When
		let result = sut.getScanEntries(seconds: 3600)

		// Then
		expect(result).toNot(beEmpty())
		expect(result).to(haveCount(1))
		expect(result.first?.mode) == ScanLogManager.highRisk
	}

	func test_getScanEntries_oneScan_inTimeWindow_lowisk() {

		// Given
		let date = Date()
		sut.addScanEntry(highRisk: false, date: date)

		// When
		let result = sut.getScanEntries(seconds: 3600)

		// Then
		expect(result).toNot(beEmpty())
		expect(result).to(haveCount(1))
		expect(result.first?.mode) == ScanLogManager.lowRisk
	}

	func test_getScanEntries_oneScan_outsideTimeWindow() {

		// Given
		let date = Date().addingTimeInterval(ago * 4000 * seconds)
		sut.addScanEntry(highRisk: true, date: date)

		// When
		let result = sut.getScanEntries(seconds: 3600)

		// Then
		expect(result).to(beEmpty())
	}
}
