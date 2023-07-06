/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI
import XCTest
@testable import CTR
import Nimble
import SnapshotTesting
import TestingShared

class RemoteEventStartViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: RemoteEventStartViewController!
	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var viewModel: RemoteEventStartViewModel!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		coordinatorSpy = EventCoordinatorDelegateSpy()
		viewModel = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .vaccination)
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func test_content_vaccination() {

		// Given
		sut = RemoteEventStartViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holder_addVaccination_title()
		expect(self.sut.sceneView.message) == L.holder_addVaccination_message()
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_content_negativeTest() {
		
		// Given
		viewModel = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .test(.ggd))
		sut = RemoteEventStartViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_negativetest_ggd_title()
		expect(self.sut.sceneView.message) == L.holder_negativetest_ggd_message()
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_content_recovery() {
		
		// Given
		viewModel = RemoteEventStartViewModel(coordinator: coordinatorSpy, eventMode: .recovery)
		sut = RemoteEventStartViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holderRecoveryStartTitle()
		expect(self.sut.sceneView.message) == L.holderRecoveryStartMessage()
		
		sut.assertImage(containedInNavigationController: true)
	}

	func test_primaryButtonTapped() {

		// Given
		sut = RemoteEventStartViewController(viewModel: viewModel)
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .continue(eventMode: .vaccination)
	}

	func test_secondaryButtonTapped() {

		// Given
		sut = RemoteEventStartViewController(viewModel: viewModel)
		loadView()

		// When
		sut.sceneView.secondaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .alternativeRoute(eventMode: .vaccination)
	}
	
	func test_checkBoxTapped() {
		
		// Given
		sut = RemoteEventStartViewController(viewModel: viewModel)
		loadView()
		
		// When
		sut.sceneView.didToggleCheckboxCommand?(true)
		sut.sceneView.primaryButtonTapped()
		
		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .continue(eventMode: .vaccinationAndPositiveTest)
	}
	
	func test_secondaryButtonTapped_checBoxTapped() {

		// Given
		sut = RemoteEventStartViewController(viewModel: viewModel)
		loadView()

		// When
		sut.sceneView.didToggleCheckboxCommand?(true)
		sut.sceneView.secondaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .alternativeRoute(eventMode: .vaccinationAndPositiveTest)
	}
}
