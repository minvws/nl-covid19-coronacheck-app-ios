/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import SnapshotTesting
@testable import CTR

final class DCCQRDetailsViewControllerTests: XCTestCase {
	
	private var sut: DCCQRDetailsViewController!
	private var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	private var viewModel: DCCQRDetailsViewModel!
	
	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		
		viewModel = DCCQRDetailsViewModel(
			coordinator: coordinatorDelegateSpy,
			title: "title",
			description: "body",
			details: [
				DCCQRDetails(field: DCCQRDetailsTest.name, value: "Corona, Check"),
				DCCQRDetails(field: DCCQRDetailsTest.dateOfBirth, value: "1970-01-01")
			],
			dateInformation: "information"
		)
		sut = DCCQRDetailsViewController(viewModel: viewModel)
	}

	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_content() {
		
		// Given
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == "title"
		expect(self.sut.sceneView.detailsDescription) == "body"
		expect(self.sut.sceneView.dateInformation) == "information"
		
		sut.assertImage()
	}
	
	func test_dosageLinkTouchedCommand_shouldOpenUrl() throws {
		
		// Given
		loadView()
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))
		
		// When
		sut.sceneView.dosageLinkTouchedCommand?(url)
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.0) == url
	}
}
