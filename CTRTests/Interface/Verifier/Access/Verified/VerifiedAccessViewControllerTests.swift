/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import SnapshotTesting
import Nimble

final class VerifiedAccessViewControllerTests: XCTestCase {

	/// Subject under test
	private var sut: VerifiedAccessViewController!
	
	private var verifierCoordinatorSpy: VerifierCoordinatorDelegateSpy!
	
	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		
		verifierCoordinatorSpy = VerifierCoordinatorDelegateSpy()
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_demo_riskLevelLow() {
		// Given
		sut = VerifiedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				verifiedType: .demo(.low)
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifierResultAccessTitle()
		expect(self.sut.preferredStatusBarStyle) == .default
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_demo_riskLevelHigh() {
		// Given
		sut = VerifiedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				verifiedType: .demo(.high)
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_result_access_title_highrisk()
		expect(self.sut.preferredStatusBarStyle) == .default
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_verified_riskLevelLow() {
		// Given
		sut = VerifiedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				verifiedType: .verified(.low)
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifierResultAccessTitle()
		expect(self.sut.preferredStatusBarStyle) == .default
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_verified_riskLevelHigh() {
		// Given
		sut = VerifiedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				verifiedType: .verified(.high)
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_result_access_title_highrisk()
		expect(self.sut.preferredStatusBarStyle) == .lightContent
		
		// Snapshot
		sut.assertImage()
	}
}
