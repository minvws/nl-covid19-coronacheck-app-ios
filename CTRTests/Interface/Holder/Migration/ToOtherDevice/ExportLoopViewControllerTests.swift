/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI
import XCTest
import Nimble
import SnapshotTesting
@testable import CTR
@testable import DataMigration
@testable import Managers
import Persistence

class ExportLoopViewControllerTests: XCTestCase {

	var sut: ExportLoopViewController!
	private var coordinatorDelegate: MigrationCoordinatorDelegateSpy!
	private var brightnessSpy: ScreenBrightnessProtocolSpy!
	private var dataExportSpy: DataExporterSpy!
	private var environmentSpies: EnvironmentSpies!
	var window = UIWindow()

	override func setUp() {
		super.setUp()
		coordinatorDelegate = MigrationCoordinatorDelegateSpy()
		brightnessSpy = ScreenBrightnessProtocolSpy()
		environmentSpies = setupEnvironmentSpies()
		dataExportSpy = DataExporterSpy()
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests
	
	func test_withData() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		dataExportSpy.stubbedExportResult = ["This is a test"]
		
		// When
		sut = ExportLoopViewController(viewModel: ExportLoopViewModel(delegate: coordinatorDelegate, dataExporter: dataExportSpy, screenBrightness: brightnessSpy))
		loadView()
		
		// Then
		expect(self.sut.title) == L.holder_startMigration_onboarding_toolbar()
		expect(self.sut.sceneView.step) == L.holder_startMigration_onboarding_step("3")
		expect(self.sut.sceneView.header) == L.holder_startMigration_toOtherDevice_onboarding_step3_title()
		expect(self.sut.sceneView.message) == L.holder_startMigration_toOtherDevice_onboarding_step3_message()
		expect(self.sut.sceneView.imageView.image).toEventuallyNot(beNil())
		
		sut.assertImage(containedInNavigationController: true)
	}
}
