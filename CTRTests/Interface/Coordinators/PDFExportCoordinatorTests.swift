/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
@testable import Models
@testable import Transport
@testable import Resources
@testable import ReusableViews

class PDFExportCoordinatorTests: XCTestCase {
	
	var sut: PDFExportCoordinator!
	var navigationSpy: NavigationControllerSpy!
	var delegateSpy: PDFExportFlowDelegateSpy!
	
	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		delegateSpy = PDFExportFlowDelegateSpy()
		_ = setupEnvironmentSpies()
		sut = PDFExportCoordinator(navigationController: navigationSpy, delegate: delegateSpy)
	}

	// MARK: - Tests

	func test_start() {
		
		// Given
		
		// When
		sut.start()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.last is PagedAnnouncementViewController) == true
		expect(self.delegateSpy.invokedExportFailed) == false
		expect(self.delegateSpy.invokedExportCompleted) == false
	}
	
	func test_consumeLink() {
		
		// Given
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let result = sut.consume(universalLink: universalLink)
		
		// Then
		expect(result) == false
	}
	
	func test_userWishesToStart() {
		
		// Given
		
		// When
		sut.userWishesToStart()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.last is PagedAnnouncementViewController) == true
		expect(self.delegateSpy.invokedExportFailed) == false
		expect(self.delegateSpy.invokedExportCompleted) == false
	}
	
	func test_userWishesToExport() {
		
		// Given
		
		// When
		sut.userWishesToExport()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.last is PDFExportViewController) == true
		expect(self.delegateSpy.invokedExportFailed) == false
		expect(self.delegateSpy.invokedExportCompleted) == false
	}
	
	func test_displayError() throws {
		
		// Given
		let content = Content(
			title: L.generalNetworkwasbusyTitle()
		)
		
		// When
		sut.displayError(content: content)
		
		// Then
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap( (self.navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.title) == L.generalNetworkwasbusyTitle()
		expect(self.delegateSpy.invokedExportFailed) == false
		expect(self.delegateSpy.invokedExportCompleted) == false
	}
	
	func test_share() throws {
		
		// Given
		let url = try XCTUnwrap(URL(string: "https://apple.com"))
		
		// When
		sut.userWishesToShare(url)
		
		// Then
		expect(self.navigationSpy.invokedPresent) == true
		expect(self.delegateSpy.invokedExportFailed) == false
		expect(self.delegateSpy.invokedExportCompleted) == false
	}
	
	func test_exportFailed() {
		
		// Given
		
		// When
		sut.exportFailed()
		
		// Then
		expect(self.delegateSpy.invokedExportCompleted) == false
		expect(self.delegateSpy.invokedExportFailed) == true
	}
	
	func test_didFinishPagedAnnouncement() {
		
		// Given
		
		// When
		sut.didFinishPagedAnnouncement()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.last is PDFExportViewController) == true
		expect(self.delegateSpy.invokedExportFailed) == false
		expect(self.delegateSpy.invokedExportCompleted) == false
	}
}
