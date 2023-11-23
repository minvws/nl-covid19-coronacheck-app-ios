/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length file_length

import CoronaCheckFoundation
import CoronaCheckTest
import CoronaCheckUI
@testable import CTR

class AppCoordinatorTests: XCTestCase {

	var sut: AppCoordinator!

	var navigationSpy: NavigationControllerSpy!

	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		
		navigationSpy = NavigationControllerSpy()
		sut = AppCoordinator(
			navigationController: navigationSpy
		)
	}

	// MARK: - Tests
	
	func test_start_asHolder() {

		// Given
		sut.flavor = .holder
		
		// When
		sut.start()

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(self.sut.window.rootViewController is AppStatusViewController) == true
		expect((self.sut.window.rootViewController as? AppStatusViewController)?.viewModel is AppDeactivatedViewModel) == true
	}
	
	func test_start_asVerifier() {

		// Given
		sut.flavor = .verifier
		
		// When
		sut.start()

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(self.sut.window.rootViewController is AppStatusViewController) == true
		expect((self.sut.window.rootViewController as? AppStatusViewController)?.viewModel is AppDeactivatedViewModel) == true
	}
}
