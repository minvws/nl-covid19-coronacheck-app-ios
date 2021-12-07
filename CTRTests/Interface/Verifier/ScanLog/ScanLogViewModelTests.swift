/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import Rswift

class ScanLogViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: ScanLogViewModel!
	private var coordinatorSpy: VerifierCoordinatorDelegateSpy!
	private var scanLogManagingSpy: ScanLogManagingSpy!
	private var appInstalledSinceManagingSpy: AppInstalledSinceManagingSpy!

	override func setUp() {

		super.setUp()

		coordinatorSpy = VerifierCoordinatorDelegateSpy()
		let config: RemoteConfiguration = .default

		scanLogManagingSpy = ScanLogManagingSpy()
		Services.use(scanLogManagingSpy)
		scanLogManagingSpy.stubbedGetScanEntriesResult = .success([])

		appInstalledSinceManagingSpy = AppInstalledSinceManagingSpy()
		Services.use(appInstalledSinceManagingSpy)

		sut = ScanLogViewModel(coordinator: coordinatorSpy, configuration: config, now: { now })
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}

	// MARK: - Tests

	func test_defaultContent() {

		// Given

		// When

		// Then
		expect(self.sut.title) == L.scan_log_title()
		expect(self.sut.message) == L.scan_log_message("60")
		expect(self.sut.listHeader) == L.scan_log_list_header(60)
	}

	func test_openUrl() throws {

		// Given
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))

		// When
		sut.openUrl(url)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.0) == url
	}

	func test_coredata_error() {

		// Given
		scanLogManagingSpy.stubbedGetScanEntriesResult = .failure(NSError(domain: "CoronaCheck", code: 4, userInfo: nil))
		let config: RemoteConfiguration = .default

		// When
		sut = ScanLogViewModel(coordinator: coordinatorSpy, configuration: config, now: { now })

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title) == L.generalErrorTitle()
		expect(self.sut.alert?.subTitle) == L.generalErrorTechnicalCustom("i 130 000 062")
	}

	func test_no_log() {

		// Given
		scanLogManagingSpy.stubbedGetScanEntriesResult = .success([])
		let config: RemoteConfiguration = .default

		// When
		sut = ScanLogViewModel(coordinator: coordinatorSpy, configuration: config, now: { now })

		// Then
		expect(self.sut.displayEntries).to(haveCount(1))
		expect(self.sut.displayEntries.first) == ScanLogDisplayEntry.message(message: L.scan_log_list_no_items())
	}

	func test_oneEntry() {

		// Given
		let scanManager = ScanLogManager(dataStoreManager: DataStoreManager(.inMemory, flavor: .verifier))
		Services.use(scanManager)
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(24 * minutes * ago))
		var config: RemoteConfiguration = .default
		config.scanLogStorageSeconds = Int(Date().timeIntervalSince1970 - now.timeIntervalSince1970 + 3600)

		// When
		sut = ScanLogViewModel(coordinator: coordinatorSpy, configuration: config, now: { now })

		// Then
		expect(self.sut.displayEntries).to(haveCount(1))
		expect(self.sut.displayEntries.first) == ScanLogDisplayEntry.entry(type: "3G", timeInterval: "16:38 - nu", message: "1 tot 10 bewijzen gescand", warning: nil)
	}

	func test_twoEntries_sameMode() {

		// Given
		let scanManager = ScanLogManager(dataStoreManager: DataStoreManager(.inMemory, flavor: .verifier))
		Services.use(scanManager)
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(24 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(22 * minutes * ago))
		var config: RemoteConfiguration = .default
		config.scanLogStorageSeconds = Int(Date().timeIntervalSince1970 - now.timeIntervalSince1970 + 3600)

		// When
		sut = ScanLogViewModel(coordinator: coordinatorSpy, configuration: config, now: { now })

		// Then
		expect(self.sut.displayEntries).to(haveCount(1))
		expect(self.sut.displayEntries.first) == ScanLogDisplayEntry.entry(type: "3G", timeInterval: "16:38 - nu", message: "1 tot 10 bewijzen gescand", warning: nil)
	}

	func test_twoEntries_differentMode() {

		// Given
		let scanManager = ScanLogManager(dataStoreManager: DataStoreManager(.inMemory, flavor: .verifier))
		Services.use(scanManager)
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(24 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .high, date: now.addingTimeInterval(22 * minutes * ago))
		var config: RemoteConfiguration = .default
		config.scanLogStorageSeconds = Int(Date().timeIntervalSince1970 - now.timeIntervalSince1970 + 3600)

		// When
		sut = ScanLogViewModel(coordinator: coordinatorSpy, configuration: config, now: { now })

		// Then
		expect(self.sut.displayEntries).to(haveCount(2))
		expect(self.sut.displayEntries[0]) == ScanLogDisplayEntry.entry(type: "2G", timeInterval: "16:40 - nu", message: "1 tot 10 bewijzen gescand", warning: nil)
		expect(self.sut.displayEntries[1]) == ScanLogDisplayEntry.entry(type: "3G", timeInterval: "16:38 - 16:38", message: "1 tot 10 bewijzen gescand", warning: nil)
	}

	func test_complexList() {

		// Given
		let scanManager = ScanLogManager(dataStoreManager: DataStoreManager(.inMemory, flavor: .verifier))
		Services.use(scanManager)
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(24 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(22 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(20 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .high, date: now.addingTimeInterval(15 * minutes * ago)) // Mode Switch
		scanManager.addScanEntry(riskLevel: .high, date: now.addingTimeInterval(14 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .high, date: now.addingTimeInterval(12 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .high, date: now.addingTimeInterval(14 * minutes * ago)) // Clock reset
		scanManager.addScanEntry(riskLevel: .high, date: now.addingTimeInterval(11 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(9 * minutes * ago)) // Another mode switch
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(8 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(7 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(6 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(5 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(4 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(3 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(2 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(1 * minutes * ago))
		scanManager.addScanEntry(riskLevel: .low, date: now.addingTimeInterval(0 * minutes * ago))

		var config: RemoteConfiguration = .default
		config.scanLogStorageSeconds = Int(Date().timeIntervalSince1970 - now.timeIntervalSince1970 + 3600)

		// When
		sut = ScanLogViewModel(coordinator: coordinatorSpy, configuration: config, now: { now })

		// Then
		expect(self.sut.displayEntries).to(haveCount(4))
		expect(self.sut.displayEntries[0]) == ScanLogDisplayEntry.entry(type: "3G", timeInterval: "16:53 - nu", message: "10 tot 20 bewijzen gescand", warning: nil)
		expect(self.sut.displayEntries[1]) == ScanLogDisplayEntry.entry(type: "2G", timeInterval: "16:48 - 16:51", message: "1 tot 10 bewijzen gescand", warning: L.scan_log_list_clock_skew_detected())
		expect(self.sut.displayEntries[2]) == ScanLogDisplayEntry.entry(type: "2G", timeInterval: "16:47 - 16:50", message: "1 tot 10 bewijzen gescand", warning: nil)
		expect(self.sut.displayEntries[3]) == ScanLogDisplayEntry.entry(type: "3G", timeInterval: "16:38 - 16:42", message: "1 tot 10 bewijzen gescand", warning: nil)
	}

	func test_firstUseDate_noDate() {

		// Given
		appInstalledSinceManagingSpy.stubbedFirstUseDate = nil
		let config: RemoteConfiguration = .default

		// When
		sut = ScanLogViewModel(coordinator: coordinatorSpy, configuration: config, now: { now })

		// Then
		expect(self.sut.appInUseSince).to(beNil())
	}

	func test_firstUseDate_now() {

		// Given
		appInstalledSinceManagingSpy.stubbedFirstUseDate = now
		let config: RemoteConfiguration = .default

		// When
		sut = ScanLogViewModel(coordinator: coordinatorSpy, configuration: config, now: { now })

		// Then
		expect(self.sut.appInUseSince) == L.scan_log_footer_in_use("15 juli 2021 17:02")
	}

	func test_firstUseDate_older() {

		// Given
		appInstalledSinceManagingSpy.stubbedFirstUseDate = now.addingTimeInterval(31 * days * ago)
		let config: RemoteConfiguration = .default

		// When
		sut = ScanLogViewModel(coordinator: coordinatorSpy, configuration: config, now: { now })

		// Then
		expect(self.sut.appInUseSince) == L.scan_log_footer_long_time()
	}
}
