/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import SnapshotTesting

class ChooseProviderViewControllerTests: XCTestCase {

	/// Subject under test
	private var sut: ChooseProviderViewController!

	private var viewModel: ChooseProviderViewModel!
	private var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	private var openIdManagerSpy: OpenIdManagerSpy!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		openIdManagerSpy = OpenIdManagerSpy()
		viewModel = ChooseProviderViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			openIdManager: openIdManagerSpy
		)
		sut = ChooseProviderViewController(viewModel: viewModel)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
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
		expect(self.sut.title) == .holderChooseProviderTitle
		expect(self.sut.sceneView.title) == .holderChooseProviderHeader
		expect(self.sut.sceneView.message) == .holderChooseProviderMessage
		expect(self.sut.sceneView.headerImage) == .create
		expect(self.sut.sceneView.innerStackView.arrangedSubviews)
			.to(haveCount(1), description: "There should only be 1 element")

		// Snapshot
		sut.assertImage()
	}

	func test_content_ggdEnabled() {

		// Given
		viewModel = ChooseProviderViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			openIdManager: openIdManagerSpy,
			enableGGD: true
		)
		sut = ChooseProviderViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.title) == .holderChooseProviderTitle
		expect(self.sut.sceneView.title) == .holderChooseProviderHeader
		expect(self.sut.sceneView.message) == .holderChooseProviderMessage
		expect(self.sut.sceneView.headerImage) == .create
		expect(self.sut.sceneView.innerStackView.arrangedSubviews)
			.to(haveCount(2), description: "There should be 2 elements")

		// Snapshot
		sut.assertImage()
	}

	func test_chooseFirstOption() {

		// Given
		loadView()
		let firstOption = sut.sceneView.innerStackView.arrangedSubviews.first as? DisclosureButton

		// When
		firstOption?.primaryButtonTapped()

		// Then
		expect(self.holderCoordinatorDelegateSpy.navigateToTokenOverviewCalled) == true
	}
}
