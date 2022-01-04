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

final class ScanNextInstructionViewControllerTests: XCTestCase {

	/// Subject under test
	private var sut: ScanNextInstructionViewController!
	
	private var verifierCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!

	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		
		verifierCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_scanNext_test() {
		// Given
		sut = ScanNextInstructionViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorDelegateSpy,
				scanNext: .test
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_scannextinstruction_title_test()
		expect(self.sut.sceneView.subtitle) == L.verifier_scannextinstruction_subtitle()
		expect(self.sut.sceneView.header) == L.verifier_scannextinstruction_header_test()
		expect(self.sut.sceneView.primaryTitle) == L.verifier_scannextinstruction_button_scan_next_test()
		expect(self.sut.sceneView.secondaryTitle) == L.verifier_scannextinstruction_button_deny_access_test()
		
		// Snapshot
		sut.assertImage()
	}
	
	func test_scanNext_vaccinationOrRecovery() {
		// Given
		sut = ScanNextInstructionViewController(
			viewModel: .init(
				coordinator: verifierCoordinatorDelegateSpy,
				scanNext: .vaccinationOrRecovery
			)
		)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.verifier_scannextinstruction_title_supplemental()
		expect(self.sut.sceneView.subtitle) == L.verifier_scannextinstruction_subtitle()
		expect(self.sut.sceneView.header) == L.verifier_scannextinstruction_header_supplemental()
		expect(self.sut.sceneView.primaryTitle) == L.verifier_scannextinstruction_button_scan_next_supplemental()
		expect(self.sut.sceneView.secondaryTitle) == L.verifier_scannextinstruction_button_deny_access_supplemental()
		
		// Snapshot
		sut.assertImage()
	}
}
