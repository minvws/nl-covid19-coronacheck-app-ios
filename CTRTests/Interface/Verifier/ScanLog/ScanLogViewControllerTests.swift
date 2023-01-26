/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
@testable import Transport
@testable import Shared
import SnapshotTesting
import Nimble
import TestingShared

class ScanLogViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: ScanLogViewController!

	private var coordinatorSpy: VerifierCoordinatorDelegateSpy!
	private var viewModel: ScanLogViewModel!
	private var environmentSpies: EnvironmentSpies!
	
	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		coordinatorSpy = VerifierCoordinatorDelegateSpy()
		environmentSpies = setupEnvironmentSpies()
		environmentSpies.dataStoreManager = DataStoreManager(.inMemory, flavor: .verifier, loadPersistentStoreCompletion: { _ in })

		viewModel = ScanLogViewModel(coordinator: coordinatorSpy)
		sut = ScanLogViewController(viewModel: viewModel)
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func test_content() {
		
		// Given
		
		// When
		loadView()
		
		// Then
		expect(self.sut.title) == L.scan_log_title()
		expect(self.sut.sceneView.message) == L.scan_log_message(60)
		expect(self.sut.sceneView.footer) == L.scan_log_footer_long_time()
		expect(self.sut.sceneView.listHeader) == L.scan_log_list_header(60)
		expect(self.sut.sceneView.logStackView.arrangedSubviews).to(haveCount(3))
		
		// Snapshot
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_oneEntry() {
		
		// Given
		let entry: ScanLogEntry! = ScanLogEntry(mode: ScanLogManager.policy3G, date: now.addingTimeInterval(24 * minutes * ago), managedContext: environmentSpies.dataStoreManager.managedObjectContext())
		environmentSpies.scanLogManagerSpy.stubbedGetScanEntriesResult = .success([entry])
		
		var config: RemoteConfiguration = .default
		config.scanLogStorageSeconds = 3600
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration = config
		sut = ScanLogViewController(viewModel: ScanLogViewModel(coordinator: coordinatorSpy))
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.logStackView.arrangedSubviews).to(haveCount(3))
		
		// Snapshot
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_twoEntries_differentMode() {
		
		// Given
		let entry1: ScanLogEntry! = ScanLogEntry(mode: ScanLogManager.policy3G, date: now.addingTimeInterval(24 * minutes * ago), managedContext: environmentSpies.dataStoreManager.managedObjectContext())
		let entry2: ScanLogEntry! = ScanLogEntry(mode: ScanLogManager.policy1G, date: now.addingTimeInterval(22 * minutes * ago), managedContext: environmentSpies.dataStoreManager.managedObjectContext())
		environmentSpies.scanLogManagerSpy.stubbedGetScanEntriesResult = .success([entry1, entry2])
		
		var config: RemoteConfiguration = .default
		config.scanLogStorageSeconds = 3600
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration = config
		sut = ScanLogViewController(viewModel: ScanLogViewModel(coordinator: coordinatorSpy))
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.logStackView.arrangedSubviews).to(haveCount(5))
		
		// Snapshot
		sut.assertImage(containedInNavigationController: true)
	}
}
