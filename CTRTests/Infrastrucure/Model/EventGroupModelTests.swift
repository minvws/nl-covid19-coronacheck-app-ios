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
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			let wallet = WalletModel.createTestWallet(managedContext: context)!
			let date = Date()
			let json = "test_createEvent".data(using: .utf8)!

			// When
			let eventGroup = EventGroupModel.create(
				type: EventType.test,
				maxIssuedAt: date,
				jsonData: json,
				wallet: wallet,
				managedContext: context
			)

			// Then
			expect(eventGroup?.type) == EventType.test.rawValue
			expect(eventGroup?.maxIssuedAt) == date
			expect(eventGroup?.jsonData) == json
			expect(eventGroup?.wallet) == wallet
			expect(wallet.eventGroups).to(haveCount(1))
		}
	}

	func test_createTwoEvents() {

		// Given
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			let wallet = WalletModel.createTestWallet(managedContext: context)!
			let date = Date()
			let json = "test_createTwoEvents".data(using: .utf8)!

			// When
			EventGroupModel.create(
				type: EventType.test,
				maxIssuedAt: date,
				jsonData: json,
				wallet: wallet,
				managedContext: context
			)
			EventGroupModel.create(
				type: EventType.vaccination,
				maxIssuedAt: date,
				jsonData: json,
				wallet: wallet,
				managedContext: context
			)

			// Then
			expect(wallet.eventGroups).to(haveCount(2))
		}
	}
}
