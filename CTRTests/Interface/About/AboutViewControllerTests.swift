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
	private var sut: AboutViewController!
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
		expect(self.sut.title) == L.holderAboutTitle()
		expect(self.sut.sceneView.message) == L.holderAboutText()
		expect(self.sut.sceneView.listHeader) == L.holderAboutReadmore()
		expect(self.sut.sceneView.itemStackView.arrangedSubviews)
			.to(haveCount(3))
		expect(self.sut.sceneView.version).toNot(beNil())

		sut.assertImage()
	}
}
