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

	override func setUp() {

		super.setUp()

		coordinatorSpy = VerifierCoordinatorDelegateSpy()
		let config: RemoteConfiguration = .default

		scanLogManagingSpy = ScanLogManagingSpy()
		Services.use(scanLogManagingSpy)

		sut = ScanLogViewModel(coordinator: coordinatorSpy, configuration: config)
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
		expect(self.sut.appInUseSince) == L.scan_log_footer_long_time()
		expect(self.sut.listHeader) == L.scan_log_list_header("60")
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
}
