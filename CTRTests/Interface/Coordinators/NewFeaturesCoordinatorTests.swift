/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckTest
import CoronaCheckUI
@testable import CTR

class NewFeaturesCoordinatorTests: XCTestCase {
	
	override func setUp() {
		
		super.setUp()
		_ = setupEnvironmentSpies()
	}
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (NewFeaturesCoordinator, NavigationControllerSpy, NewFeaturesManagerSpy, NewFeaturesDelegateSpy) {
		
		let navigationSpy = NavigationControllerSpy()
		let newFeaturesManagerSpy = NewFeaturesManagerSpy()
		let delegateSpy = NewFeaturesDelegateSpy()
		let sut = NewFeaturesCoordinator(
			navigationController: navigationSpy,
			newFeaturesManager: newFeaturesManagerSpy,
			delegate: delegateSpy
		)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, navigationSpy, newFeaturesManagerSpy, delegateSpy)
	}
	
	// MARK: - Tests
	
	/// Test the start method with update page
	func test_start_shouldInvokeFinishNewFeatures() {
		
		// Given
		let (sut, navigationSpy, newFeaturesManagerSpy, delegateSpy) = makeSUT()
		newFeaturesManagerSpy.stubbedPagedAnnouncementItemsResult = [PagedAnnoucementItem(
			title: "test",
			content: "test",
			imageBackgroundColor: C.white(),
			tagline: "test",
			step: 0
		)]
		
		// When
		sut.start()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(delegateSpy.invokedFinishNewFeatures) == false
	}
	
	/// Test the start methoud without update page
	func test_start_withoutUpdatePage() {
		
		// Given
		let (sut, navigationSpy, newFeaturesManagerSpy, delegateSpy) = makeSUT()
		newFeaturesManagerSpy.stubbedPagedAnnouncementItemsResult = nil
		
		// When
		sut.start()
		
		// Then
		expect(navigationSpy.viewControllers).to(beEmpty())
		expect(delegateSpy.invokedFinishNewFeatures) == true
	}
	
	/// Test the start method without consent content
	func testStartWithoutConsent() {
		
		// Given
		let (sut, navigationSpy, newFeaturesManagerSpy, delegateSpy) = makeSUT()
		newFeaturesManagerSpy.stubbedPagedAnnouncementItemsResult = nil
		
		// When
		sut.start()
		
		// Then
		expect(navigationSpy.viewControllers).to(beEmpty())
		expect(delegateSpy.invokedFinishNewFeatures) == true
	}
}
