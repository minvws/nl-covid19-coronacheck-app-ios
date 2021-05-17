/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class GreenCardModelTests: XCTestCase {

	var dataStoreManager: DataStoreManaging!

	override func setUp() {
		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory)
	}

	// MARK: Tests

	func test_createGreenCard() {

		// Given
		var wallet: Wallet?
		var greenCard: GreenCard?
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet {

				// When
				greenCard = GreenCardModel.create(
					type: .domestic,
					issuedAt: date,
					wallet: unwrappedWallet,
					managedContext: context
				)
			}
		}

		// Then
		expect(greenCard?.type).toEventually(equal(GreenCardType.domestic.rawValue))
		expect(greenCard?.issuedAt).toEventually(equal(date))
		expect(greenCard?.wallet).toEventually(equal(wallet))
		expect(wallet?.greenCards).toEventually(haveCount(1))
	}

	func test_createTwoGreenCards() {

		// Given
		var wallet: Wallet?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet {
				let date = Date()

				// When
				GreenCardModel.create(
					type: .euAllInOne,
					issuedAt: date,
					wallet: unwrappedWallet,
					managedContext: context
				)
				GreenCardModel.create(
					type: .euTest,
					issuedAt: date,
					wallet: unwrappedWallet,
					managedContext: context
				)
			}
		}
		// Then
		expect(wallet?.greenCards).toEventually(haveCount(2))
	}

	func test_addCredential() {

		// Given
		var greenCard: GreenCard?
		var credential: Credential?
		let json = "test_addCredential".data(using: .utf8)
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.createTestWallet(managedContext: context),
			   let unwrappedJson = json {
				greenCard = GreenCardModel.create(
					type: .domestic,
					issuedAt: date,
					wallet: wallet,
					managedContext: context
				)

				if let unwrappedGreenCard = greenCard {

					// When
					credential = CredentialModel.create(
						qrData: unwrappedJson,
						validFrom: date,
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
				}
			}
		}
		
		// Then
		expect(greenCard?.credentials).to(haveCount(1))
		if case let actualCredential as Credential = greenCard?.credentials?.allObjects.first {
			expect(actualCredential) == credential
		} else {
			fail("credential does not match")
		}
	}

	func test_removeCredential() {

		// Given
		var listIsEmpty = false
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.createTestWallet(managedContext: context),
			   let greenCard = GreenCardModel.create(
				type: .euRecovery,
				issuedAt: date,
				wallet: wallet,
				managedContext: context
			   ),
			   let json = "test_removeCredential".data(using: .utf8),
			   let credential = CredentialModel.create(
				qrData: json,
				validFrom: date,
				greenCard: greenCard,
				managedContext: context
			   ) {

				// When
				greenCard.removeFromCredentials(credential)
				listIsEmpty = greenCard.credentials?.allObjects.isEmpty ?? false
			}
		}

		// Then
		expect(listIsEmpty).toEventually(beTrue())
	}
}
