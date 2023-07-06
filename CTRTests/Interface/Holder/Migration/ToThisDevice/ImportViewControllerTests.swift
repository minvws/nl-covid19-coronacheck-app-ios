/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckUI
import XCTest
import Nimble
import SnapshotTesting
import ViewControllerPresentationSpy
@testable import CTR
@testable import DataMigration
@testable import Transport

class ImportViewControllerTests: XCTestCase {

	var sut: ImportViewController!
	private var coordinatorDelegate: MigrationCoordinatorDelegateSpy!
	private var dataImportSpy: DataImportSpy!
	private var environmentSpies: EnvironmentSpies!
	var window = UIWindow()

	override func setUp() {
		super.setUp()
		coordinatorDelegate = MigrationCoordinatorDelegateSpy()
		environmentSpies = setupEnvironmentSpies()
		dataImportSpy = DataImportSpy()
		sut = ImportViewController(viewModel: ImportViewModel(coordinator: coordinatorDelegate, dataImporter: dataImportSpy))
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests
	
	func test_content() throws {
		
		// Given
		
		// When
		loadView()
		
		// Then
		expect(self.sut.title) == L.holder_scanner_title()
		expect(self.sut.sceneView.step) == L.holder_startMigration_onboarding_step("3")
		expect(self.sut.sceneView.header) == L.holder_startMigration_toThisDevice_onboarding_step3_title()
		expect(self.sut.sceneView.message) == L.holder_startMigration_toThisDevice_onboarding_step3_message()

		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_showPermissionError() {
		
		// Given
		let alertVerifier = AlertVerifier()
		loadView()
		
		// When
		sut.showPermissionError()
		
		// Then
		alertVerifier.verify(
			title: L.holder_scanner_permission_title(),
			message: L.holder_scanner_permission_message(),
			animated: true,
			actions: [
				.default(L.holder_scanner_permission_settings()),
				.cancel(L.general_cancel())
			]
		)
	}
	
	func test_found_validData() {
		
		// Given
		let dataImporter = DataImporter(version: "TEST")
		let viewModel = ImportViewModel(coordinator: coordinatorDelegate, dataImporter: dataImporter)
		dataImporter.delegate = viewModel
		sut = ImportViewController(viewModel: viewModel)
		
		// When
		sut.found(code: "eyJpIjowLCJuIjoxLCJwIjoiSDRzSUFBQUFBQUFDRXlXUzNYTGJJQkNGMzhWUEFMV1ZhWG9YU2VCWU1VdDNFVGloMHd2SDZ0Z1M2dGh4SFArbzAzZnZLcjBDZHVIc25tXC81OFdmU1RMNU5mdDJxN25VYUxxXC96XC9pTUtPTWU1YjIxYnJaMW9DaWUyN2JLb3VzM3ZrT0lxRSt1VmZsOTArOVlwYzdVcEt5bVpteWt4TXhxeklPbVpaRFJPbXFsMUQ5ZlE5eWJvM2JxdWQzbm90MitnWW9HOUY2YmRUNDNhSDYwbmEwclFVTlBjM082ajhkZnZLSk0wUlRaM3c0N3JmejFUT0N3cDdEUG9HZ1BKU0VqTkNtK0hKeHgwenVjZU9uaUdrRGlcL0VkQVRvcWcwRHMzYXljMEhDcE9SQW8zU0RGRGdGdVdPdGNhNGZxYndjc1RhY0FcL3ZGK3ViYUl1Y05SZG4wbUJ0Q1lhQzFxUWs2MjA0bGs0b0ZsZXNRNFVoUmx0dTdzalQ5N3JzV1VjcktrN0V0WjhoeFJ5RUVkREZKWXBaUnM1elgyT2ZaUDduVUVDYlBhRjh5TWdmb2xXWE0zaHhodHB6ZkpaQkgrZWYrZEhEV00rSk8xc2dhN3l3WnM4YTkzTys4OEphSzVTNU11cEVGTWIxdXNJaFBsRzVaUWJNb2gxNU1SZVg1ZENIa1FscjNudnJUdXpwTXFPMFc5dmFuNm5JaWJ3MjVHY0N5djBSYlwvNkw5VnBcLzhxbjNBOGUyS1BZZktIa0dkZUk3RFwvem1mUUROWE92QWpCcG1scytwNURrb1hhRUxqeUFQWUV2OUNFUEZ2bm5HQVhqZldGdHJCOGt6NzJ1SlNWYlk2eEpERDFZejA4NHoyejV5YmZiWDhMc2tiS21tZm9qOEI3Wm5ITXdidGZ0RWNpSHFibkVFXC84SWV4QmJia2ZrcHNIWnVRK1ByWVZmemgxdmFzbEdZS25DS2x0VGpXXC9EU29raERhTW40VzBiVU4wQ2Rtb1VoZWxmNlpNUG1DRnF2YSsybnhzMGtxY1hVREE4WG8rSmprUDVzRkRocXFcL3ZKMzVcL1wvQUtxeFZRc3lBd0FBIiwidiI6IlRFU1QifQ==")
		
		// Then
		expect(self.coordinatorDelegate.invokedPresentError) == false
		expect(self.coordinatorDelegate.invokedUserWishesToSeeScannedEvents) == true
	}
	
	func test_found_parseError() {
		
		// Given
		dataImportSpy.stubbedImportStringError = DataMigrationError.compressionError
		
		// When
		sut.found(code: "eyJpIjowLCJuIjoxLCJwIjoiSDRzSUFBQUFBQUFDRXlXUzNYTGJJQkNGMzhWUEFMV1ZhWG9YU2VCWU1VdDNFVGloMHd2SDZ0Z1M2dGh4SFArbzAzZnZLcjBDZHVIc25tXC81OFdmU1RMNU5mdDJxN25VYUxxXC96XC9pTUtPTWU1YjIxYnJaMW9DaWUyN2JLb3VzM3ZrT0lxRSt1VmZsOTArOVlwYzdVcEt5bVpteWt4TXhxeklPbVpaRFJPbXFsMUQ5ZlE5eWJvM2JxdWQzbm90MitnWW9HOUY2YmRUNDNhSDYwbmEwclFVTlBjM082ajhkZnZLSk0wUlRaM3c0N3JmejFUT0N3cDdEUG9HZ1BKU0VqTkNtK0hKeHgwenVjZU9uaUdrRGlcL0VkQVRvcWcwRHMzYXljMEhDcE9SQW8zU0RGRGdGdVdPdGNhNGZxYndjc1RhY0FcL3ZGK3ViYUl1Y05SZG4wbUJ0Q1lhQzFxUWs2MjA0bGs0b0ZsZXNRNFVoUmx0dTdzalQ5N3JzV1VjcktrN0V0WjhoeFJ5RUVkREZKWXBaUnM1elgyT2ZaUDduVUVDYlBhRjh5TWdmb2xXWE0zaHhodHB6ZkpaQkgrZWYrZEhEV00rSk8xc2dhN3l3WnM4YTkzTys4OEphSzVTNU11cEVGTWIxdXNJaFBsRzVaUWJNb2gxNU1SZVg1ZENIa1FscjNudnJUdXpwTXFPMFc5dmFuNm5JaWJ3MjVHY0N5djBSYlwvNkw5VnBcLzhxbjNBOGUyS1BZZktIa0dkZUk3RFwvem1mUUROWE92QWpCcG1scytwNURrb1hhRUxqeUFQWUV2OUNFUEZ2bm5HQVhqZldGdHJCOGt6NzJ1SlNWYlk2eEpERDFZejA4NHoyejV5YmZiWDhMc2tiS21tZm9qOEI3Wm5ITXdidGZ0RWNpSHFibkVFXC84SWV4QmJia2ZrcHNIWnVRK1ByWVZmemgxdmFzbEdZS25DS2x0VGpXXC9EU29raERhTW40VzBiVU4wQ2Rtb1VoZWxmNlpNUG1DRnF2YSsybnhzMGtxY1hVREE4WG8rSmprUDVzRkRocXFcL3ZKMzVcL1wvQUtxeFZRc3lBd0FBIiwidiI6IlRFU1QifQ==")
		
		// Then
		expect(self.coordinatorDelegate.invokedPresentError) == true
		expect(self.coordinatorDelegate.invokedPresentErrorParameters?.0.errorCode) == ErrorCode.ClientCode.compressionError.value
		expect(self.coordinatorDelegate.invokedUserWishesToSeeScannedEvents) == false
	}
}
