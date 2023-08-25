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

class PDFExportCoordinatorTests: XCTestCase {
	
	override func setUp() {
		
		super.setUp()
		_ = setupEnvironmentSpies()
	}
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (PDFExportCoordinator, NavigationControllerSpy, PDFExportFlowDelegateSpy) {
		
		let navigationSpy = NavigationControllerSpy()
		let delegateSpy = PDFExportFlowDelegateSpy()
		let sut = PDFExportCoordinator(navigationController: navigationSpy, delegate: delegateSpy)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, navigationSpy, delegateSpy)
	}

	// MARK: - Tests

	func test_start() {
		
		// Given
		let (sut, navigationSpy, delegateSpy) = makeSUT()
		
		// When
		sut.start()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.last is PagedAnnouncementViewController) == true
		expect(delegateSpy.invokedExportFailed) == false
		expect(delegateSpy.invokedExportCompleted) == false
	}
	
	func test_consumeLink() {
		
		// Given
		let (sut, _, _) = makeSUT()
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
		let (sut, navigationSpy, delegateSpy) = makeSUT()
		
		// When
		sut.userWishesToStart()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.last is PagedAnnouncementViewController) == true
		expect(delegateSpy.invokedExportFailed) == false
		expect(delegateSpy.invokedExportCompleted) == false
	}
	
	func test_userWishesToExport() {
		
		// Given
		let (sut, navigationSpy, delegateSpy) = makeSUT()
		
		// When
		sut.userWishesToExport()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.last is PDFExportViewController) == true
		expect(delegateSpy.invokedExportFailed) == false
		expect(delegateSpy.invokedExportCompleted) == false
	}
	
	func test_displayError() throws {
		
		// Given
		let (sut, navigationSpy, delegateSpy) = makeSUT()
		let content = Content(
			title: L.generalNetworkwasbusyTitle()
		)
		
		// When
		sut.displayError(content: content)
		
		// Then
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ContentViewController) == true
		let viewModel = try XCTUnwrap( (navigationSpy.viewControllers.last as? ContentViewController)?.viewModel)
		expect(viewModel.content.value.title) == L.generalNetworkwasbusyTitle()
		expect(delegateSpy.invokedExportFailed) == false
		expect(delegateSpy.invokedExportCompleted) == false
	}
	
	func test_share() throws {
		
		// Given
		let (sut, navigationSpy, delegateSpy) = makeSUT()
		let url = try XCTUnwrap(URL(string: "https://apple.com"))
		
		// When
		sut.userWishesToShare(url, sender: nil)
		
		// Then
		expect(navigationSpy.invokedPresent) == true
		expect(delegateSpy.invokedExportFailed) == false
		expect(delegateSpy.invokedExportCompleted) == false
	}
	
	func test_exportFailed() {
		
		// Given
		let (sut, _, delegateSpy) = makeSUT()
		
		// When
		sut.exportFailed()
		
		// Then
		expect(delegateSpy.invokedExportCompleted) == false
		expect(delegateSpy.invokedExportFailed) == true
	}
	
	func test_didFinishPagedAnnouncement() {
		
		// Given
		let (sut, navigationSpy, delegateSpy) = makeSUT()
		
		// When
		sut.didFinishPagedAnnouncement()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.last is PDFExportViewController) == true
		expect(delegateSpy.invokedExportFailed) == false
		expect(delegateSpy.invokedExportCompleted) == false
	}
}
