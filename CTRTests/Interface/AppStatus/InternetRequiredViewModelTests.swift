/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import Shared

class InternetRequiredViewModelTests: XCTestCase {
	
	// MARK: Subject under test
	var sut: AppStatusViewModel!
	var appCoordinatorSpy: AppCoordinatorSpy!
	
	// MARK: Test lifecycle
	
	override func setUp() {
		
		super.setUp()
		appCoordinatorSpy = AppCoordinatorSpy()
		sut = InternetRequiredViewModel(coordinator: appCoordinatorSpy)
	}
	
	// MARK: Tests
	
	func test_initializer() {
		
		// Given
		
		// When
		
		// Then
		expect(self.sut.title.value) == L.internetRequiredTitle()
		expect(self.sut.message.value) == L.internetRequiredText()
		expect(self.sut.actionTitle.value) == L.internetRequiredButton()
		expect(self.sut.image.value) == I.noInternet()
	}
	
	func test_actionButtonTapped() {
		
		// Given
		
		// When
		sut.actionButtonTapped()
		
		// Then
		expect(self.appCoordinatorSpy.invokedRetry) == true
	}
}
