/*
 * Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import Transport
@testable import Models
@testable import ReusableViews
@testable import Resources
import TestingShared
import Persistence
@testable import Managers

class MigrationCoordinatorTests: XCTestCase {
	
	private var sut: MigrationCoordinator!

	private var navigationSpy: NavigationControllerSpy!
	private var environmentSpies: EnvironmentSpies!
	private var delegateSpy: MigrationFlowDelegateSpy!

	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		delegateSpy = MigrationFlowDelegateSpy()
		environmentSpies = setupEnvironmentSpies()
		sut = MigrationCoordinator(navigationController: navigationSpy, delegate: delegateSpy)
	}

	// MARK: - Tests

	func test_start() {

		// Given

		// When
		sut.start()

		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.first is ContentWithImageViewController) == true
		expect((self.navigationSpy.viewControllers.first as? ContentWithImageViewController)?.viewModel)
			.to(beAnInstanceOf(MigrationStartViewModel.self))
		expect(self.delegateSpy.invokedDataMigrationCancelled) == false

	}

	func test_consume_redeemHolder() {

		// Given
		let universalLink = UniversalLink.redeemHolderToken(
			requestToken: RequestToken(
				token: "STXT2VF3389TJ2",
				protocolVersion: "3.0",
				providerIdentifier: "XXX"
			)
		)

		// When
		let consumed = sut.consume(universalLink: universalLink)

		// Then
		expect(consumed) == false
	}
	
	func test_userCompletedStart_withEvents() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		sut.userCompletedStart()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.first is ListOptionsViewController) == true
		expect((self.navigationSpy.viewControllers.first as? ListOptionsViewController)?.viewModel)
			.to(beAnInstanceOf(MigrationTransferOptionsViewModel.self))
	}
	
	func test_userCompletedStart_noEvents() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = []
		
		// When
		sut.userCompletedStart()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.first is PagedAnnouncementViewController) == true
		let pages = try XCTUnwrap((self.navigationSpy.viewControllers.first as? PagedAnnouncementViewController)?.viewModel.pages)
		expect(pages).to(haveCount(2))
		expect(pages.first?.title) == L.holder_startMigration_toThisDevice_onboarding_step1_title()
		expect(pages.last?.title) == L.holder_startMigration_toThisDevice_onboarding_step2_title()
	}
	
	func test_userWishesToSeeToThisDeviceInstructions() throws {
		
		// Given
		
		// When
		sut.userWishesToSeeToThisDeviceInstructions()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.first is PagedAnnouncementViewController) == true
		let pages = try XCTUnwrap((self.navigationSpy.viewControllers.first as? PagedAnnouncementViewController)?.viewModel.pages)
		expect(pages).to(haveCount(2))
		expect(pages.first?.title) == L.holder_startMigration_toThisDevice_onboarding_step1_title()
		expect(pages.last?.title) == L.holder_startMigration_toThisDevice_onboarding_step2_title()
	}

	func test_userWishesToSeeToOtherDeviceInstructions() throws {
		
		// Given
		
		// When
		sut.userWishesToSeeToOtherDeviceInstructions()
		
		// Then
		expect(self.navigationSpy.viewControllers).to(haveCount(1))
		expect(self.navigationSpy.viewControllers.first is PagedAnnouncementViewController) == true
		let pages = try XCTUnwrap((self.navigationSpy.viewControllers.first as? PagedAnnouncementViewController)?.viewModel.pages)
		expect(pages).to(haveCount(2))
		expect(pages.first?.title) == L.holder_startMigration_toOtherDevice_onboarding_step1_title()
		expect(pages.last?.title) == L.holder_startMigration_toOtherDevice_onboarding_step2_title()
	}
	
	func test_userCompletedMigrationToOtherDevice() {
		
		// Given
		
		// When
		sut.userCompletedMigrationToOtherDevice()
		
		// Then
		expect(self.delegateSpy.invokedDataMigrationExportCompleted) == true
	}
}

class MigrationFlowDelegateSpy: MigrationFlowDelegate {

	var invokedDataMigrationCancelled = false
	var invokedDataMigrationCancelledCount = 0

	func dataMigrationCancelled() {
		invokedDataMigrationCancelled = true
		invokedDataMigrationCancelledCount += 1
	}

	var invokedDataMigrationExportCompleted = false
	var invokedDataMigrationExportCompletedCount = 0

	func dataMigrationExportCompleted() {
		invokedDataMigrationExportCompleted = true
		invokedDataMigrationExportCompletedCount += 1
	}

	var invokedDataMigrationImportCompleted = false
	var invokedDataMigrationImportCompletedCount = 0

	func dataMigrationImportCompleted() {
		invokedDataMigrationImportCompleted = true
		invokedDataMigrationImportCompletedCount += 1
	}
}
