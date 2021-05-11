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

	var databaseManager = DatabaseManager()

	override func tearDown() {

		databaseManager.clearCoreData()
		super.tearDown()
	}

	// MARK: Tests

	func test_createGreenCard() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {
			let wallet = WalletModel.createTestWallet(managedContext: context)!
			let date = Date()

			// When
			let greenCard = GreenCardModel.create(
				type: .domestic,
				issuedAt: date,
				wallet: wallet,
				managedContext: context
			)

			// Then
			expect(greenCard?.type) == GreenCardType.domestic.rawValue
			expect(greenCard?.issuedAt) == date
			expect(greenCard?.wallet) == wallet
			expect(wallet.greenCards).to(haveCount(1))
		}
	}

	func test_createTwoGreenCards() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {
			let wallet = WalletModel.createTestWallet(managedContext: context)!
			let date = Date()

			// When
			GreenCardModel.create(
				type: .euAllInOne,
				issuedAt: date,
				wallet: wallet,
				managedContext: context
			)
			GreenCardModel.create(
				type: .euTest,
				issuedAt: date,
				wallet: wallet,
				managedContext: context
			)

			// Then
			expect(wallet.greenCards).to(haveCount(2))
		}
	}

	func test_addCredential() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {

			let wallet = WalletModel.createTestWallet(managedContext: context)!
			let date = Date()
			let greenCard = GreenCardModel.create(
				type: .domestic,
				issuedAt: date,
				wallet: wallet,
				managedContext: context
			)!
			let json = "test_addCredential".data(using: .utf8)!

			// When
			let credential = CredentialModel.create(
				qrData: json,
				validFrom: date,
				greenCard: greenCard,
				managedContext: context
			)

			// Then
			expect(greenCard.credentials).to(haveCount(1))
			if case let actualCredential as Credential = greenCard.credentials?.allObjects.first {
				expect(actualCredential) == credential
			} else {
				fail("credential does not match")
			}
		}
	}

	func test_removeCredential() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {

			let wallet = WalletModel.createTestWallet(managedContext: context)!
			let date = Date()
			let greenCard = GreenCardModel.create(
				type: .euRecovery,
				issuedAt: date,
				wallet: wallet,
				managedContext: context
			)!
			let json = "test_removeCredential".data(using: .utf8)!
			let credential = CredentialModel.create(
				qrData: json,
				validFrom: date,
				greenCard: greenCard,
				managedContext: context
			)!

			// When
			greenCard.removeFromCredentials(credential)

			// Then
			expect(greenCard.credentials).to(haveCount(0))
		}
	}
}
