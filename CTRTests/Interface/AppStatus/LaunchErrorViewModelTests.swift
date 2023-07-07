/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckUI
import XCTest
@testable import CTR
import Nimble

class LaunchErrorViewModelTests: XCTestCase {
	
	// MARK: Subject under test
	var sut: AppStatusViewModel!
	private var environmentalSpies: EnvironmentSpies!
	
	// MARK: Test lifecycle
	
	override func setUp() {
		
		environmentalSpies = setupEnvironmentSpies()
		environmentalSpies.contactInformationSpy.stubbedPhoneNumberLink = "<a href=\"tel:TEST\">TEST</a>"
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
		expect(self.sut.message.value) == L.appstatus_launchError_body("<a href=\"tel:TEST\">TEST</a>", "i 010 000 123")
		expect(self.environmentalSpies.contactInformationSpy.invokedPhoneNumberLinkGetter) == true
		expect(self.sut.actionTitle.value) == L.appstatus_launchError_button()
		expect(self.sut.image.value) == I.launchError()
		expect(self.environmentalSpies.contactInformationSpy.invokedPhoneNumberLinkGetter) == true
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
