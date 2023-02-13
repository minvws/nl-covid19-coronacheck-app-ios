/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Shared
@testable import Models

class PagedAnnouncementDelegateSpy: PagedAnnouncementDelegate {

	var invokedDidFinishPagedAnnouncement = false
	var invokedDidFinishPagedAnnouncementCount = 0

	func didFinishPagedAnnouncement() {
		invokedDidFinishPagedAnnouncement = true
		invokedDidFinishPagedAnnouncementCount += 1
	}
}

class PagedAnnouncementViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: PagedAnnouncementViewController!

	var delegateSpy: PagedAnnouncementDelegateSpy!

	let page = PagedAnnoucementItem(
		title: "Onboarding Title",
		content: "Onboarding Message",
		image: I.onboarding.safely(),
		imageBackgroundColor: C.white(),
		step: 1
	)

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		delegateSpy = PagedAnnouncementDelegateSpy()

		sut = PagedAnnouncementViewController(
			viewModel: PagedAnnouncementViewModel(
				delegate: delegateSpy,
				pages: [page],
				itemsShouldShowWithFullWidthHeaderImage: false,
				shouldShowWithVWSRibbon: true
			),
			allowsPreviousPageButton: false,
			allowsCloseButton: false,
			allowsNextPageButton: false
		)
		window = UIWindow()
	}

	func loadView() {

		_ = sut.view
	}

	// MARK: Test

	/// Test all the content
	func testContent() throws {

		// Given

		// When
		loadView()

		// Then
		XCTAssertEqual(sut.sceneView.primaryButton.titleLabel?.text, L.general_toMyOverview(), "Button title should match")
	}

	/// Test tap on the next button with only one item
	func testNextTappedWithOneItem() {

		// Given
		loadView()

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertTrue(delegateSpy.invokedDidFinishPagedAnnouncement, "Method should be called")
	}

	/// Test tap on the next button with two items
	func testNextTappedWithTwoItems() {

		// Given
		sut = PagedAnnouncementViewController(
			viewModel: PagedAnnouncementViewModel(
				delegate: delegateSpy,
				pages: [page, page],
				itemsShouldShowWithFullWidthHeaderImage: false,
				shouldShowWithVWSRibbon: true
			),
			allowsPreviousPageButton: false,
			allowsCloseButton: false,
			allowsNextPageButton: false
		)
		
		loadView()

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertFalse(delegateSpy.invokedDidFinishPagedAnnouncement, "Method should NOT be called")
	}

	/// Test tap on the next button with two items while on the second page
	func testWithTwoItemsWhileOnSecondPage() {

		// Given
		sut = PagedAnnouncementViewController(
			viewModel: PagedAnnouncementViewModel(
				delegate: delegateSpy,
				pages: [page, page],
				itemsShouldShowWithFullWidthHeaderImage: false,
				shouldShowWithVWSRibbon: true
			),
			allowsPreviousPageButton: true,
			allowsCloseButton: false,
			allowsNextPageButton: false
		)
		loadView()

		// When
		sut.primaryButtonTapped()

		// Then
		XCTAssertNotNil(sut.navigationItem.leftBarButtonItem, "There should be a back button")
	}

	/// Test tap on the next button with two items while on the second page
	func testNextTappedWithTwoItemsWhileOnSecondPage() {

		// Given
		sut = PagedAnnouncementViewController(
			viewModel: PagedAnnouncementViewModel(
				delegate: delegateSpy,
				pages: [page, page],
				itemsShouldShowWithFullWidthHeaderImage: false,
				shouldShowWithVWSRibbon: true
			),
			allowsPreviousPageButton: false,
			allowsCloseButton: false,
			allowsNextPageButton: false
		)
		loadView()
		sut.primaryButtonTapped()

		// When
		sut.sceneView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		XCTAssertTrue(delegateSpy.invokedDidFinishPagedAnnouncement, "Method should be called")
	}

	/// Test tap on the next button with two items while on the second page
	func testBackButtonTappedWithTwoItemsWhileOnSecondPage() {

		// Given
		sut = PagedAnnouncementViewController(
			viewModel: PagedAnnouncementViewModel(
				delegate: delegateSpy,
				pages: [page, page],
				itemsShouldShowWithFullWidthHeaderImage: false,
				shouldShowWithVWSRibbon: true
			),
			allowsPreviousPageButton: false,
			allowsCloseButton: false,
			allowsNextPageButton: false
		)
		loadView()
		sut.primaryButtonTapped()

		// When
		sut.previousPageButtonTapped()

		// Then
		XCTAssertFalse(delegateSpy.invokedDidFinishPagedAnnouncement, "Method should not be called")
		XCTAssertTrue(sut.sceneView.primaryButton.isEnabled)
	}
}
