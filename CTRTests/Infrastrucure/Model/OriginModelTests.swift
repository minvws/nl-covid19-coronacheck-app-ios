/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
		dataStoreManager = DataStoreManager(.inMemory, loadPersistentStoreCompletion: { _ in })
	}

	// MARK: Tests

	func test_createOrigin() {

		// Given
		var greenCard: GreenCard?
		var origin: Origin?
		let date = Date()
		let validFromDate = Date(timeIntervalSinceNow: -10)

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				greenCard = GreenCard(
					type: .domestic,
					wallet: wallet,
					managedContext: context
				)
				if let unwrappedGreenCard = greenCard {

					// When
					origin = Origin(
						type: .vaccination,
						eventDate: date,
						expirationTime: date,
						validFromDate: validFromDate,
						doseNumber: 1,
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
		expect(origin?.validFromDate).toEventually(equal(validFromDate))
		expect(origin?.greenCard).toEventually(equal(greenCard))
		expect(greenCard?.origins).toEventually(haveCount(1))
	}

	func test_createTwoOrigins() {

		// Given
		var greenCard: GreenCard?
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				greenCard = GreenCard(
					type: .domestic,
					wallet: wallet,
					managedContext: context
				)

				if let unwrappedGreenCard = greenCard {

					// When
					Origin(
						type: .recovery,
						eventDate: date,
						expirationTime: date,
						validFromDate: date,
						doseNumber: nil,
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
					Origin(
						type: .vaccination,
						eventDate: date,
						expirationTime: date,
						validFromDate: date,
						doseNumber: 1,
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
