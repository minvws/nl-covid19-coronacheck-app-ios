/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class CredentialModelTests: XCTestCase {

	var dataStoreManager: DataStoreManaging!

	override func setUp() {
		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory)
	}

	// MARK: Tests

	func test_createCredential() {

		// Given
		var greenCard: GreenCard?
		var credential: Credential?
		let date = Date()
		let json = "test_createCredential".data(using: .utf8)

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context),
			   let unwrappedJson = json {
				greenCard = GreenCardModel.create(
					type: .domestic,
					wallet: wallet,
					managedContext: context
				)
				if let unwrappedGreenCard = greenCard {

					// When
					credential = CredentialModel.create(
						data: unwrappedJson,
						validFrom: date,
						expirationTime: date,
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
				}
			}
		}

		// Then
		expect(credential?.data).toEventually(equal(json))
		expect(credential?.validFrom).toEventually(equal(date))
		expect(credential?.greenCard).toEventually(equal(greenCard))
		expect(greenCard?.credentials).toEventually(haveCount(1))
	}

	func test_createTwoCredentials() {

		// Given
		var greenCard: GreenCard?
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context),
			   let json = "test_createTwoCredentials".data(using: .utf8) {
				greenCard = GreenCardModel.create(
					type: .domestic,
					wallet: wallet,
					managedContext: context
				)

				if let unwrappedGreenCard = greenCard {

					// When
					CredentialModel.create(
						data: json,
						validFrom: date,
						expirationTime: date,
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
					CredentialModel.create(
						data: json,
						validFrom: date,
						expirationTime: date,
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
				}
			}
		}

		// Then
		expect(greenCard?.credentials).toEventually(haveCount(2))
	}
}
