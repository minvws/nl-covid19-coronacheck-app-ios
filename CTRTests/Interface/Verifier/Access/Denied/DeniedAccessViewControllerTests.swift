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

final class DeniedAccessViewControllerTests: XCTestCase {
	
	/// Subject under test
	private var sut: DeniedAccessViewController!
	
	private var verifierCoordinatorSpy: VerifierCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		verifierCoordinatorSpy = VerifierCoordinatorDelegateSpy()
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_scanNextTapped_shouldScanAgain() {
		// Given
		sut = DeniedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				deniedAccessReason: .invalid
			)
		)
		loadView()
		
		// When
		sut.sceneView.scanNextTappedCommand?()
		
		// Then
		expect(self.verifierCoordinatorSpy.invokedNavigateToScan) == true
	}
	
	func test_readMoreTapped_shouldScanAgain() {
		// Given
		sut = DeniedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				deniedAccessReason: .invalid
			)
		)
		loadView()
		
		// When
		sut.sceneView.readMoreTappedCommand?()
		
		// Then
		expect(self.verifierCoordinatorSpy.invokedDisplayContent) == true
	}
	
	func test_deniedAccessReason_invalid() {
		// Given
		sut = DeniedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				deniedAccessReason: .invalid
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifierResultDeniedTitle()
		expect(self.sut.sceneView.primaryTitle) == L.verifierResultNext()
		expect(self.sut.sceneView.secondaryTitle) == L.verifierResultDeniedReadmore()
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_deniedAccessReason_identityMismatch() {
		// Given
		sut = DeniedAccessViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorSpy,
				deniedAccessReason: .identityMismatch
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_result_denied_personal_data_mismatch_title()
		expect(self.sut.sceneView.primaryTitle) == L.verifierResultNext()
		expect(self.sut.sceneView.secondaryTitle).to(beNil())
		
		// Snapshot
		sut.assertImage()
	}
}
