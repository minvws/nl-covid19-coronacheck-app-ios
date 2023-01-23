/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import Transport
import Shared

class LaunchErrorViewModelTests: XCTestCase {
	
	// MARK: Subject under test
	var sut: AppStatusViewModel!
	
	// MARK: Test lifecycle
	
	override func setUp() {
		
		super.setUp()
	}
	
	// MARK: Tests
	
	func test_initializer() {
		
		// Given
		sut = LaunchErrorViewModel(
			errorCodes: [ErrorCode(flow: .onboarding, step: .configuration, errorCode: "123")],
			urlHandler: { _ in },
			closeHandler: {}
		)
		// When
		
		// Then
		expect(self.sut.title.value) == L.appstatus_launchError_title()
		expect(self.sut.message.value) == L.appstatus_launchError_body("i 010 000 123")
		expect(self.sut.actionTitle.value) == L.appstatus_launchError_button()
		expect(self.sut.image.value) == I.launchError()
	}
	
	func test_actionButtonTapped() {
		
		// Given
		var actionButtonTapped = false
		sut = LaunchErrorViewModel(
			errorCodes: [ErrorCode(flow: .onboarding, step: .configuration, errorCode: "123")],
			urlHandler: { _ in },
			closeHandler: { actionButtonTapped = true }
		)
		
		// When
		sut.actionButtonTapped()
		
		// Then
		expect(actionButtonTapped) == true
	}
	
	func test_urlHandler() throws {
		
		// Given
		var urlHandlerCalled = false
		sut = LaunchErrorViewModel(
			errorCodes: [ErrorCode(flow: .onboarding, step: .configuration, errorCode: "123")],
			urlHandler: { _ in urlHandlerCalled = true },
			closeHandler: { }
		)
		let url = try XCTUnwrap(URL(string: "https://apple.com"))
		
		// When
		sut.userDidTapURL(url: url)
		
		// Then
		expect(urlHandlerCalled) == true
	}
}
