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

final class NewDisclosurePolicyViewControllerTests: XCTestCase {
	
	private var sut: NewDisclosurePolicyViewController!

	private var coordinatorSpy: HolderCoordinatorDelegateSpy!
	private var viewModel: NewDisclosurePolicyViewModel!
	private var environmentSpies: EnvironmentSpies!

	var window = UIWindow()

	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = HolderCoordinatorDelegateSpy()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func test_view_1G() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GExclusiveDisclosurePolicyEnabledResult = true
		environmentSpies.riskLevelManagerSpy.stubbedState = nil
		sut = NewDisclosurePolicyViewController(
			viewModel: .init(
				coordinator: coordinatorSpy
			)
		)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.tagline) == L.generalNewintheapp()
		expect(self.sut.sceneView.title) == L.holder_newintheapp_content_only1G_title()
		expect(self.sut.sceneView.content) == L.holder_newintheapp_content_only1G_body()

		// Snapshot
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_view_3G() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs3GExclusiveDisclosurePolicyEnabledResult = true
		environmentSpies.riskLevelManagerSpy.stubbedState = nil
		sut = NewDisclosurePolicyViewController(
			viewModel: .init(
				coordinator: coordinatorSpy
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.tagline) == L.generalNewintheapp()
		expect(self.sut.sceneView.title) == L.holder_newintheapp_content_only3G_title()
		expect(self.sut.sceneView.content) == L.holder_newintheapp_content_only3G_body()
		
		// Snapshot
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_view_1GWith3G() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreBothDisclosurePoliciesEnabledResult = true
		environmentSpies.riskLevelManagerSpy.stubbedState = nil
		sut = NewDisclosurePolicyViewController(
			viewModel: .init(
				coordinator: coordinatorSpy
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.tagline) == L.generalNewintheapp()
		expect(self.sut.sceneView.title) == L.holder_newintheapp_content_3Gand1G_title()
		expect(self.sut.sceneView.content) == L.holder_newintheapp_content_3Gand1G_body()
		
		// Snapshot
		sut.assertImage(containedInNavigationController: true)
	}
}
