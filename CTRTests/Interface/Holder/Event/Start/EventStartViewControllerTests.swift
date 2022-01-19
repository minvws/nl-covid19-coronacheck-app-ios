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

class EventStartViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: EventStartViewController!
	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var viewModel: EventStartViewModel!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		coordinatorSpy = EventCoordinatorDelegateSpy()
		viewModel = EventStartViewModel(coordinator: coordinatorSpy, eventMode: .vaccination)
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func test_content_vaccination() {

		// Given
		sut = EventStartViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holderVaccinationStartTitle()
		expect(self.sut.sceneView.message) == L.holderVaccinationStartMessage()

		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_content_negativeTest() {
		
		// Given
		viewModel = EventStartViewModel(coordinator: coordinatorSpy, eventMode: .test)
		sut = EventStartViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_negativetest_ggd_title()
		expect(self.sut.sceneView.message) == L.holder_negativetest_ggd_message()
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_content_positiveTest() {
		
		// Given
		viewModel = EventStartViewModel(coordinator: coordinatorSpy, eventMode: .positiveTest)
		sut = EventStartViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holderPositiveTestStartTitle()
		expect(self.sut.sceneView.message) == L.holderPositiveTestStartMessage()
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_content_recovery() {
		
		// Given
		viewModel = EventStartViewModel(coordinator: coordinatorSpy, eventMode: .recovery)
		sut = EventStartViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holderRecoveryStartTitle()
		expect(self.sut.sceneView.message) == L.holderRecoveryStartMessage()
		
		sut.assertImage(containedInNavigationController: true)
	}

	func test_backButtonTapped() {

		// Given
		sut = EventStartViewController(viewModel: viewModel)
		loadView()

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .back(eventMode: .test)
	}

	func test_primaryButtonTapped() {

		// Given
		sut = EventStartViewController(viewModel: viewModel)
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .continue(eventMode: .vaccination)
	}

	func test_secondaryButtonTapped() {

		// Given
		sut = EventStartViewController(viewModel: viewModel)
		loadView()

		// When
		sut.sceneView.secondaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.0) == URL(string: L.holderVaccinationStartNodigidUrl())
	}
}
