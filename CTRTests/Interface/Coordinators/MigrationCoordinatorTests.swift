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
@testable import Models
@testable import ReusableViews

class MigrationCoordinatorTests: XCTestCase {
	
	var sut: MigrationCoordinator!

	var navigationSpy: NavigationControllerSpy!

	var delegateSpy: MigrationFlowDelegateSpy!

	override func setUp() {

		super.setUp()

		navigationSpy = NavigationControllerSpy()
		delegateSpy = MigrationFlowDelegateSpy()
		_ = setupEnvironmentSpies()
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
}

class MigrationFlowDelegateSpy: MigrationFlowDelegate {

	var invokedDataMigrationCancelled = false
	var invokedDataMigrationCancelledCount = 0

	func dataMigrationCancelled() {
		invokedDataMigrationCancelled = true
		invokedDataMigrationCancelledCount += 1
	}
}
