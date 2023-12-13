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

class AppCoordinatorTests: XCTestCase {

	var sut: AppCoordinator!

	var navigationSpy: NavigationControllerSpy!
	
	var fileManagerSpy: FileStorageSpy!

	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		
		navigationSpy = NavigationControllerSpy()
		fileManagerSpy = FileStorageSpy()
		sut = AppCoordinator(
			navigationController: navigationSpy
		)
		sut.fileManager = fileManagerSpy
	}

	// MARK: - Tests
	
	func test_start_asHolder() {

		// Given
		sut.flavor = .holder
		
		// When
		sut.start()

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(self.sut.window.rootViewController is UINavigationController) == true
		expect((self.sut.window.rootViewController as? UINavigationController)?.viewControllers.first is AppStatusViewController) == true
		expect(((self.sut.window.rootViewController as? UINavigationController)?.viewControllers.first as? AppStatusViewController)?.viewModel is AppDeactivatedViewModel) == true
		
		expect(self.fileManagerSpy.invokedRemoveDatabase) == true
		expect(self.fileManagerSpy.invokedFileExists) == true
		expect(self.fileManagerSpy.invokedFileExistsCount) == 2
	}
	
	func test_start_asVerifier() {

		// Given
		sut.flavor = .verifier
		
		// When
		sut.start()

		// Then
		expect(self.sut.childCoordinators).to(haveCount(0))
		expect(self.sut.window.rootViewController is UINavigationController) == true
		expect((self.sut.window.rootViewController as? UINavigationController)?.viewControllers.first is AppStatusViewController) == true
		expect(((self.sut.window.rootViewController as? UINavigationController)?.viewControllers.first as? AppStatusViewController)?.viewModel is AppDeactivatedViewModel) == true

		expect(self.fileManagerSpy.invokedRemoveDatabase) == true
		expect(self.fileManagerSpy.invokedFileExists) == true
		expect(self.fileManagerSpy.invokedFileExistsCount) == 2
	}
}
