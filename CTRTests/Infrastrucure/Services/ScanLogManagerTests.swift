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
		let result = sut.didWeScanQRs(withinLastNumberOfSeconds: 3600)

		// Then
		expect(result) == false
	}

	func test_didWeScanQR_oneScan_inTimeWindow() {

		// Given
		let date = Date()
		sut.addScanEntry(verificationPolicy: .policy1G, date: date)

		// When
		let result = sut.didWeScanQRs(withinLastNumberOfSeconds: 3600)

		// Then
		expect(result) == true
	}

	func test_didWeScanQR_oneScan_outsideTimeWindow() {

		// Given
		let date = Date().addingTimeInterval(ago * 4000 * seconds)
		sut.addScanEntry(verificationPolicy: .policy1G, date: date)

		// When
		let result = sut.didWeScanQRs(withinLastNumberOfSeconds: 3600)

		// Then
		expect(result) == false
	}

	func test_getScanEntries_nothingScanned() throws {

		// Given

		// When
		let result = try XCTUnwrap(sut.getScanEntries(withinLastNumberOfSeconds: 3600).successValue)

		// Then
		expect(result).to(beEmpty())
	}

	func test_getScanEntries_oneScan_inTimeWindow_highRisk() throws {

		// Given
		let date = Date()
		sut.addScanEntry(verificationPolicy: .policy1G, date: date)

		// When
		let result = try XCTUnwrap(sut.getScanEntries(withinLastNumberOfSeconds: 3600).successValue)

		// Then
		expect(result).toNot(beEmpty())
		expect(result).to(haveCount(1))
		expect(result.first?.mode) == ScanLogManager.policy1G
	}

	func test_getScanEntries_oneScan_inTimeWindow_lowRisk() throws {

		// Given
		let date = Date()
		sut.addScanEntry(verificationPolicy: .policy3G, date: date)

		// When
		let result = try XCTUnwrap(sut.getScanEntries(withinLastNumberOfSeconds: 3600).successValue)

		// Then
		expect(result).toNot(beEmpty())
		expect(result).to(haveCount(1))
		expect(result.first?.mode) == ScanLogManager.policy3G
	}

	func test_getScanEntries_oneScan_outsideTimeWindow() throws {

		// Given
		let date = Date().addingTimeInterval(ago * 4000 * seconds)
		sut.addScanEntry(verificationPolicy: .policy1G, date: date)

		// When
		let result = try XCTUnwrap(sut.getScanEntries(withinLastNumberOfSeconds: 3600).successValue)

		// Then
		expect(result).to(beEmpty())
	}

	func test_deleteScans_oneScan_outsideTimeWindow() throws {

		// Given
		let date = Date().addingTimeInterval(ago * 4000 * seconds)
		sut.addScanEntry(verificationPolicy: .policy1G, date: date)

		// When
		sut.deleteExpiredScanLogEntries(seconds: 3600)
		let result = try XCTUnwrap(sut.getScanEntries(withinLastNumberOfSeconds: 3600).successValue)

		// Then
		expect(result).to(beEmpty())
	}

	func test_deleteScans_oneScan_inTimeWindow() throws {

		// Given
		let date = Date().addingTimeInterval(ago * 3000 * seconds)
		sut.addScanEntry(verificationPolicy: .policy1G, date: date)

		// When
		sut.deleteExpiredScanLogEntries(seconds: 3600)
		let result = try XCTUnwrap(sut.getScanEntries(withinLastNumberOfSeconds: 3600).successValue)

		// Then
		expect(result).toNot(beEmpty())
	}

	func test_reset() {

		// Given
		let date = Date()
		sut.addScanEntry(verificationPolicy: .policy1G, date: date)
		sut.addScanEntry(verificationPolicy: .policy1G, date: date)
		sut.addScanEntry(verificationPolicy: .policy1G, date: date)

		// When
		sut.wipePersistedData()

		var list = [ScanLogEntry]()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			list = ScanLogEntryModel.listEntries(managedContext: context).successValue ?? []
		}

		// Then
		expect(list).toEventually(beEmpty())
	}
	
	func test_notification_outsideTimeWindow() throws {
		
		// Given
		let date = Date().addingTimeInterval(ago * 4000 * seconds)
		sut.addScanEntry(verificationPolicy: .policy1G, date: date)
		
		// When
		NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
		
		// Then
		let result = try XCTUnwrap(sut.getScanEntries(withinLastNumberOfSeconds: 3600).successValue)
		
		// Then
		expect(result).toEventually(beEmpty())
	}
	
	func test_notification_insideTimeWindow() throws {
		
		// Given
		let date = Date().addingTimeInterval(ago * 3000 * seconds)
		sut.addScanEntry(verificationPolicy: .policy1G, date: date)
		
		// When
		NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
		
		// Then
		let result = try XCTUnwrap(sut.getScanEntries(withinLastNumberOfSeconds: 3600).successValue)
		
		// Then
		expect(result).toEventuallyNot(beEmpty())
	}
}
