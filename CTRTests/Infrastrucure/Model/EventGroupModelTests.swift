/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class EventGroupModelTests: XCTestCase {

	var dataStoreManager: DataStoreManaging!

	override func setUp() {
		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory)
	}

	// MARK: Tests

	func test_createEvent() {

		// Given
		var wallet: Wallet?
		var eventGroup: EventGroup?
		let date = Date()
		let json = "test_createEvent".data(using: .utf8)
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedJson = json, let unwrappedWallet = wallet {

				// When
				eventGroup = EventGroupModel.create(
					type: EventMode.test,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: date,
					jsonData: unwrappedJson,
					wallet: unwrappedWallet,
					managedContext: context
				)
			}
		}

		// Then
		expect(eventGroup?.type).toEventually(equal(EventMode.test.rawValue))
		expect(eventGroup?.providerIdentifier).toEventually(equal("CoronaCheck"))
		expect(eventGroup?.maxIssuedAt).toEventually(equal(date))
		expect(eventGroup?.jsonData).toEventually(equal(json))
		expect(eventGroup?.wallet).toEventually(equal(wallet))
		expect(wallet?.eventGroups).toEventually(haveCount(1))
	}

	func test_createTwoEvents() {

		// Given
		var wallet: Wallet?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet,
			   let json = "test_createTwoEvents".data(using: .utf8) {

				// When
				EventGroupModel.create(
					type: EventMode.test,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: Date(),
					jsonData: json,
					wallet: unwrappedWallet,
					managedContext: context
				)
				EventGroupModel.create(
					type: EventMode.vaccination,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: Date(),
					jsonData: json,
					wallet: unwrappedWallet,
					managedContext: context
				)
			}
		}
		// Then
		expect(wallet?.eventGroups).toEventually(haveCount(2))
	}
}
