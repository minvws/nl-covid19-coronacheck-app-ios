/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR
@testable import DataMigration
@testable import Managers
@testable import Resources
@testable import Transport
@testable import Shared

final class ImportViewModelTests: XCTestCase {
	
	private var sut: ImportViewModel!
	private var coordinatorDelegate: MigrationCoordinatorDelegateSpy!
	private var dataImportSpy: DataImportSpy!
	private var environmentSpies: EnvironmentSpies!

	override func setUp() {
		super.setUp()
		coordinatorDelegate = MigrationCoordinatorDelegateSpy()
		environmentSpies = setupEnvironmentSpies()
		dataImportSpy = DataImportSpy()

		sut = ImportViewModel(coordinator: coordinatorDelegate, dataImporter: dataImportSpy)
	}

	func test_init() {

		// Given

		// When

		// Then
		expect(self.sut.title.value) == L.holder_scanner_title()
		expect(self.sut.step.value) == L.holder_startMigration_onboarding_step("3")
		expect(self.sut.header.value) == L.holder_startMigration_toThisDevice_onboarding_step3_title()
		expect(self.sut.message.value) == L.holder_startMigration_toThisDevice_onboarding_step3_message()
		expect(self.sut.progress.value) == nil
		expect(self.sut.shouldStopScanning.value) == false
	}
	
	func test_progress() {
		
		// Given
		
		// When
		sut.progress(17)
		
		// Then
		expect(self.sut.header.value) == L.holder_startMigration_toThisDevice_onboarding_step3_titleScanning()
		expect(self.sut.message.value) == L.holder_startMigration_toThisDevice_onboarding_step3_messageKeepPointing()
		expect(self.sut.progress.value) == 0.17
	}
	
	func test_completed_invalidData() throws {
		
		// Given
		let data = try XCTUnwrap("This is wrong".data(using: .utf8))
		
		// When
		sut.completed(data)
		
		// Then
		expect(self.coordinatorDelegate.invokedPresentError) == true
		expect(self.coordinatorDelegate.invokedUserWishesToSeeScannedEvents) == false
		expect(self.sut.shouldStopScanning.value) == true
	}
	
	func test_completed_validData() throws {
		
		// Given
		let data = try XCTUnwrap("This is correct".data(using: .utf8))
		let parcel = EventGroupParcel(jsonData: data)
		let encoded = try XCTUnwrap(JSONEncoder().encode([parcel]))
		
		// When
		sut.completed(encoded)
		
		// Then
		expect(self.coordinatorDelegate.invokedPresentError) == false
		expect(self.coordinatorDelegate.invokedUserWishesToSeeScannedEvents) == true
		expect(self.sut.shouldStopScanning.value) == true
	}
	
	func test_parseQRMessage_compressionError() {
		
		// Given
		dataImportSpy.stubbedImportStringError = DataMigrationError.compressionError
		
		// When
		sut.parseQRMessage("compression error")
		
		// Then
		expect(self.sut.shouldStopScanning.value) == true
		expect(self.coordinatorDelegate.invokedPresentError) == true
		expect(self.coordinatorDelegate.invokedPresentErrorParameters?.0.errorCode) == ErrorCode.ClientCode.compressionError.value
	}
	
	func test_parseQRMessage_invalidVersion() {
		
		// Given
		dataImportSpy.stubbedImportStringError = DataMigrationError.invalidVersion
		
		// When
		sut.parseQRMessage("invalid version")
		
		// Then
		expect(self.sut.shouldStopScanning.value) == true
		expect(self.coordinatorDelegate.invokedPresentError) == true
		expect(self.coordinatorDelegate.invokedPresentErrorParameters?.0.errorCode) == ErrorCode.ClientCode.invalidVersion.value
	}
	
	func test_parseQRMessage_invalidNumberOfPackages() {
		
		// Given
		dataImportSpy.stubbedImportStringError = DataMigrationError.invalidNumberOfPackages
		
		// When
		sut.parseQRMessage("invalid number of packages")
		
		// Then
		expect(self.sut.shouldStopScanning.value) == true
		expect(self.coordinatorDelegate.invokedPresentError) == true
		expect(self.coordinatorDelegate.invokedPresentErrorParameters?.0.errorCode) == ErrorCode.ClientCode.invalidNumberOfPackages.value
	}
	
	func test_parseQRMessage_other() {
		
		// Given
		dataImportSpy.stubbedImportStringError = NSError(domain: "CoronaCheck", code: -1)
		
		// When
		sut.parseQRMessage("some other error")
		
		// Then
		expect(self.sut.shouldStopScanning.value) == true
		expect(self.coordinatorDelegate.invokedPresentError) == true
		expect(self.coordinatorDelegate.invokedPresentErrorParameters?.0.errorCode) == ErrorCode.ClientCode.other.value
	}
	
	func test_realData() {
		
		// Given
		let dataImporter = DataImporter(version: "TEST")
		sut = ImportViewModel(coordinator: coordinatorDelegate, dataImporter: dataImporter)
		dataImporter.delegate = sut
		
		// When
		sut.parseQRMessage("eyJpIjowLCJuIjoxLCJwIjoiSDRzSUFBQUFBQUFDRXlXUzNYTGJJQkNGMzhWUEFMV1ZhWG9YU2VCWU1VdDNFVGloMHd2SDZ0Z1M2dGh4SFArbzAzZnZLcjBDZHVIc25tXC81OFdmU1RMNU5mdDJxN25VYUxxXC96XC9pTUtPTWU1YjIxYnJaMW9DaWUyN2JLb3VzM3ZrT0lxRSt1VmZsOTArOVlwYzdVcEt5bVpteWt4TXhxeklPbVpaRFJPbXFsMUQ5ZlE5eWJvM2JxdWQzbm90MitnWW9HOUY2YmRUNDNhSDYwbmEwclFVTlBjM082ajhkZnZLSk0wUlRaM3c0N3JmejFUT0N3cDdEUG9HZ1BKU0VqTkNtK0hKeHgwenVjZU9uaUdrRGlcL0VkQVRvcWcwRHMzYXljMEhDcE9SQW8zU0RGRGdGdVdPdGNhNGZxYndjc1RhY0FcL3ZGK3ViYUl1Y05SZG4wbUJ0Q1lhQzFxUWs2MjA0bGs0b0ZsZXNRNFVoUmx0dTdzalQ5N3JzV1VjcktrN0V0WjhoeFJ5RUVkREZKWXBaUnM1elgyT2ZaUDduVUVDYlBhRjh5TWdmb2xXWE0zaHhodHB6ZkpaQkgrZWYrZEhEV00rSk8xc2dhN3l3WnM4YTkzTys4OEphSzVTNU11cEVGTWIxdXNJaFBsRzVaUWJNb2gxNU1SZVg1ZENIa1FscjNudnJUdXpwTXFPMFc5dmFuNm5JaWJ3MjVHY0N5djBSYlwvNkw5VnBcLzhxbjNBOGUyS1BZZktIa0dkZUk3RFwvem1mUUROWE92QWpCcG1scytwNURrb1hhRUxqeUFQWUV2OUNFUEZ2bm5HQVhqZldGdHJCOGt6NzJ1SlNWYlk2eEpERDFZejA4NHoyejV5YmZiWDhMc2tiS21tZm9qOEI3Wm5ITXdidGZ0RWNpSHFibkVFXC84SWV4QmJia2ZrcHNIWnVRK1ByWVZmemgxdmFzbEdZS25DS2x0VGpXXC9EU29raERhTW40VzBiVU4wQ2Rtb1VoZWxmNlpNUG1DRnF2YSsybnhzMGtxY1hVREE4WG8rSmprUDVzRkRocXFcL3ZKMzVcL1wvQUtxeFZRc3lBd0FBIiwidiI6IlRFU1QifQ==")
		
		// Then
		expect(self.coordinatorDelegate.invokedPresentError) == false
		expect(self.coordinatorDelegate.invokedUserWishesToSeeScannedEvents) == true
		expect(self.sut.shouldStopScanning.value) == true
	}
}
