/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI
import XCTest
import Nimble
@testable import CTR
@testable import DataMigration
@testable import Managers
import Persistence

final class ExportLoopViewModelTests: XCTestCase {
	
	private var sut: ExportLoopViewModel!
	private var coordinatorDelegate: MigrationCoordinatorDelegateSpy!
	private var brightnessSpy: ScreenBrightnessProtocolSpy!
	private var dataExportSpy: DataExporterSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		coordinatorDelegate = MigrationCoordinatorDelegateSpy()
		brightnessSpy = ScreenBrightnessProtocolSpy()
		environmentSpies = setupEnvironmentSpies()
		dataExportSpy = DataExporterSpy()
		
		sut = ExportLoopViewModel(delegate: coordinatorDelegate, dataExporter: dataExportSpy, screenBrightness: brightnessSpy)
	}
	
	func test_init() {
		
		// Given
		
		// When
		
		// Then
		expect(self.sut.title.value) == L.holder_startMigration_onboarding_toolbar()
		expect(self.sut.step.value) == L.holder_startMigration_onboarding_step("3")
		expect(self.sut.header.value) == L.holder_startMigration_toOtherDevice_onboarding_step3_title()
		expect(self.sut.message.value) == L.holder_startMigration_toOtherDevice_onboarding_step3_message()
		expect(self.sut.actionTitle.value) == L.holder_startMigration_onboarding_doneButton()
		expect(self.sut.image.value) == nil
	}
	
	func test_exportWithData_singleImage() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		dataExportSpy.stubbedExportResult = ["This is a test"]
		
		// When
		sut = ExportLoopViewModel(delegate: coordinatorDelegate, dataExporter: dataExportSpy, screenBrightness: brightnessSpy)
		
		// Then
		expect(self.sut.imageList).toEventually(haveCount(1))
		expect(self.sut.image.value).toEventuallyNot(beNil())
	}
	
	func flaky_tobefixed_test_exportWithData_multipleImages() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup, eventGroup]
		dataExportSpy.stubbedExportResult = ["This is a test", "This is another test"]
		
		// When
		sut = ExportLoopViewModel(delegate: coordinatorDelegate, dataExporter: dataExportSpy, screenBrightness: brightnessSpy)
		
		// Then
		expect(self.sut.imageList).toEventually(haveCount(2))
		expect(self.sut.image.value).toEventuallyNot(beNil())
	}
	
	func test_exportWithError() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		dataExportSpy.stubbedExportError = DataMigrationError.compressionError
		
		// When
		sut = ExportLoopViewModel(delegate: coordinatorDelegate, dataExporter: dataExportSpy, screenBrightness: brightnessSpy)
		
		// Then
		expect(self.coordinatorDelegate.invokedPresentError) == true
	}
	
	func test_viewWillAppear() {
		
		// Given
		
		// When
		sut.viewWillAppear()
		
		// Then
		expect(self.brightnessSpy.invokedAnimateToFullBrightness) == true
		expect(self.brightnessSpy.invokedAnimateToInitialBrightness) == false
	}
	
	func test_viewWillDisappear() {
		
		// Given
		
		// When
		sut.viewWillDisappear()
		
		// Then
		expect(self.brightnessSpy.invokedAnimateToInitialBrightness) == true
		expect(self.brightnessSpy.invokedAnimateToFullBrightness) == false
	}
	
	func test_done() {
		
		// Given
		
		// When
		sut.done()
		
		// Then
		expect(self.coordinatorDelegate.invokedUserCompletedMigrationToOtherDevice) == true
	}
	
	func test_back() {
		
		// Given
		
		// When
		sut.backToPreviousScreen()
		
		// Then
		expect(self.coordinatorDelegate.invokedUserWishesToGoBackToPreviousScreen) == true
	}
}
