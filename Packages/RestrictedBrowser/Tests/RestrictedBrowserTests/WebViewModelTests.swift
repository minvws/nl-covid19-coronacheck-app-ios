/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import RestrictedBrowser
import Nimble

final class WebViewModelTests: XCTestCase {

	var sut: WebViewModel!
	private var domainDeciderSpy: DomainDeciderSpy!
	
	override func setUp() {
		
		super.setUp()
		domainDeciderSpy = DomainDeciderSpy()
	}
	
	func testAllowedDomains_allowed() throws {
		
		// Given
		let url = try XCTUnwrap(URL(string: "https://apple.com"))
		sut = WebViewModel(url: url, title: "testAllowedDomains_allowed", domainDecider: domainDeciderSpy)
		domainDeciderSpy.stubbedIsDomainAllowedResult = true
		
		// When
		let result = sut.isDomainAllowed(url)
		
		// Then
		expect(result) == true
		expect(self.domainDeciderSpy.invokedIsDomainAllowed) == true
	}
	
	func testAllowedDomains_notAllowed() throws {
		
		// Given
		let url = try XCTUnwrap(URL(string: "https://apple.com"))
		sut = WebViewModel(url: url, title: "testAllowedDomains_notAllowed", domainDecider: domainDeciderSpy)
		domainDeciderSpy.stubbedIsDomainAllowedResult = false
		
		// When
		let result = sut.isDomainAllowed(url)
		
		// Then
		expect(result) == false
		expect(self.domainDeciderSpy.invokedIsDomainAllowed) == true
	}
	
	func testHandleUnallowedDomain() throws {
		
		// Given
		let url = try XCTUnwrap(URL(string: "https://apple.com"))
		sut = WebViewModel(url: url, title: "testAllowedDomains_notAllowed", domainDecider: domainDeciderSpy)
		
		// When
		sut.handleUnallowedDomain(url)
		
		// Then
		expect(self.domainDeciderSpy.invokedHandleUnallowedDomain) == true
	}
}

class DomainDeciderSpy: DomainDecider {

	var invokedIsDomainAllowed = false
	var invokedIsDomainAllowedCount = 0
	var invokedIsDomainAllowedParameters: (url: URL, Void)?
	var invokedIsDomainAllowedParametersList = [(url: URL, Void)]()
	var stubbedIsDomainAllowedResult: Bool! = false

	func isDomainAllowed(_ url: URL) -> Bool {
		invokedIsDomainAllowed = true
		invokedIsDomainAllowedCount += 1
		invokedIsDomainAllowedParameters = (url, ())
		invokedIsDomainAllowedParametersList.append((url, ()))
		return stubbedIsDomainAllowedResult
	}

	var invokedHandleUnallowedDomain = false
	var invokedHandleUnallowedDomainCount = 0
	var invokedHandleUnallowedDomainParameters: (url: URL, Void)?
	var invokedHandleUnallowedDomainParametersList = [(url: URL, Void)]()

	func handleUnallowedDomain(_ url: URL) {
		invokedHandleUnallowedDomain = true
		invokedHandleUnallowedDomainCount += 1
		invokedHandleUnallowedDomainParameters = (url, ())
		invokedHandleUnallowedDomainParametersList.append((url, ()))
	}
}
