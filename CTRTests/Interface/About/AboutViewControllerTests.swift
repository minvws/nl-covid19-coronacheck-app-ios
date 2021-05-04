/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import ViewControllerPresentationSpy
@testable import CTR
import Nimble
import SnapshotTesting

class AboutViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: AboutViewController!
	private var coordinatorSpy: OpenUrlProtocolSpy!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		coordinatorSpy = OpenUrlProtocolSpy()
		let viewModel = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.holder
		)

		sut = AboutViewController(viewModel: viewModel)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: Test

	func test_content() {

		// Given

		// When
		loadView()

		// Then
		expect(self.sut.title) == .holderAboutTitle
		expect(self.sut.sceneView.message) == .holderAboutText
		expect(self.sut.sceneView.listHeader) == .holderAboutReadMore
		expect(self.sut.sceneView.version).toNot(beNil(), description: "Version should not be nil")
	}
}
