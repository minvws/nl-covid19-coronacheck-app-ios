/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

// swiftlint:disable:next type_name
final class VisitorPassCompleteCertificateViewModelTests: XCTestCase {
	
	var sut: VisitorPassCompleteCertificateViewModel!
	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	
	override func setUp() {
		super.setUp()
		
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = VisitorPassCompleteCertificateViewModel(coordinatorDelegate: holderCoordinatorDelegateSpy)
	}
	
	func test_content() {
		
		// Given
		
		// When
		
		// Then
		expect(self.sut.content.title) == L.holder_completecertificate_title()
		expect(self.sut.content.subTitle) == L.holder_completecertificate_body()
		expect(self.sut.content.primaryActionTitle) == L.holder_completecertificate_button_fetchnegativetest()
		expect(self.sut.content.secondaryActionTitle).to(beNil())
	}
	
	func test_primaryAction_shouldCallCoordinator_toNavigate() {
		
		// Given
		
		// When
		sut.content.primaryAction?()
		
		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToCreateANegativeTestQR) == true
	}
	
	func test_openUrl_shouldCallCoordinator() throws {
		
		// Given
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))
		
		// When
		sut.openUrl(url)
		
		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == true
	}
}
