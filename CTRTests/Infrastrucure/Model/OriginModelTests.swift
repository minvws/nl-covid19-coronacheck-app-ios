/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class OriginModelTests: XCTestCase {

	var dataStoreManager: DataStoreManaging!

	override func setUp() {
		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory)
	}

	// MARK: Tests

	func test_createOrigin() {

		// Given
		var greenCard: GreenCard?
		var origin: Origin?
		let date = Date()

		let context = dataStoreManager.backgroundContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				greenCard = GreenCardModel.create(
					type: .domestic,
					wallet: wallet,
					managedContext: context
				)
				if let unwrappedGreenCard = greenCard {

					// When
					origin = OriginModel.create(
						type: .vaccination,
						eventDate: date,
						expirationTime: date,
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
				}
			}
		}

		// Then
		expect(origin?.type).toEventually(equal(OriginType.vaccination.rawValue))
		expect(origin?.eventDate).toEventually(equal(date))
		expect(origin?.expirationTime).toEventually(equal(date))
		expect(origin?.greenCard).toEventually(equal(greenCard))
		expect(greenCard?.origins).toEventually(haveCount(1))
	}

	func test_createTwoOrigins() {

		// Given
		var greenCard: GreenCard?
		let date = Date()
		let context = dataStoreManager.backgroundContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				greenCard = GreenCardModel.create(
					type: .domestic,
					wallet: wallet,
					managedContext: context
				)

				if let unwrappedGreenCard = greenCard {

					// When
					OriginModel.create(
						type: .recovery,
						eventDate: date,
						expirationTime: date,
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
					OriginModel.create(
						type: .vaccination,
						eventDate: date,
						expirationTime: date,
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
				}
			}
		}

		// Then
		expect(greenCard?.origins).toEventually(haveCount(2))
	}
}
