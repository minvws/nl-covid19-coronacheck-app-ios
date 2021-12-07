/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import SnapshotTesting
import Nimble

class ScanLogViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: ScanLogViewController!

	private var coordinatorSpy: VerifierCoordinatorDelegateSpy!
	private var viewModel: ScanLogViewModel!
	private var scanLogManagingSpy: ScanLogManagingSpy!
	private var appInstalledSinceManagingSpy: AppInstalledSinceManagingSpy!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		coordinatorSpy = VerifierCoordinatorDelegateSpy()
		let config: RemoteConfiguration = .default

		scanLogManagingSpy = ScanLogManagingSpy()
		Services.use(scanLogManagingSpy)
		scanLogManagingSpy.stubbedGetScanEntriesResult = .success([])

		appInstalledSinceManagingSpy = AppInstalledSinceManagingSpy()
		appInstalledSinceManagingSpy.stubbedFirstUseDate = now.addingTimeInterval(31 * days * ago)
		Services.use(appInstalledSinceManagingSpy)

		viewModel = ScanLogViewModel(coordinator: coordinatorSpy, configuration: config, now: { now })
		sut = ScanLogViewController(viewModel: viewModel)
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
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
		expect(self.sut.sceneView.message) == L.scan_log_message("60")
		expect(self.sut.sceneView.footer) == L.scan_log_footer_long_time()
		expect(self.sut.sceneView.listHeader) == L.scan_log_list_header(60)

		// Snapshot
		sut.assertImage(containedInNavigationController: true)
	}
}
