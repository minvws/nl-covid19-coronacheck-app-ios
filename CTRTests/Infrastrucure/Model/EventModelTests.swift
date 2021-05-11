/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
import XCTest
import Nimble
@testable import CTR

class EventModelTests: XCTestCase {

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
			let event = EventModel.create(
				type: EventType.test,
				issuedAt: date,
				jsonData: json,
				wallet: wallet,
				managedContext: context
			)

			// Then
			expect(event?.type) == EventType.test.rawValue
			expect(event?.issuedAt) == date
			expect(event?.jsonData) == json
			expect(event?.wallet) == wallet
			expect(wallet.events).to(haveCount(1))
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
			EventModel.create(
				type: EventType.test,
				issuedAt: date,
				jsonData: json,
				wallet: wallet,
				managedContext: context
			)
			EventModel.create(
				type: EventType.vaccination,
				issuedAt: date,
				jsonData: json,
				wallet: wallet,
				managedContext: context
			)

			// Then
			expect(wallet.events).to(haveCount(2))
		}
	}
}
