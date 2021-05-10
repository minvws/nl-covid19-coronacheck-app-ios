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

	var databaseManager = DatabaseManager()

	override func tearDown() {

		databaseManager.clearCoreData()
		super.tearDown()
	}

	// MARK: Tests

	func test_createCredential() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {
			let date = Date()
			let wallet = WalletModel.initialize(managedContext: context)!
			let greenCard = GreenCardModel.create(
				type: .domestic,
				issuedAt: date,
				wallet: wallet,
				managedContext: context
			)!
			let json = "test_createCredential".data(using: .utf8)!

			// When
			let credential = CredentialModel.create(
				qrData: json,
				validFrom: date,
				greenCard: greenCard,
				managedContext: context
			)

			// Then
			expect(credential?.qrData) == json
			expect(credential?.validFrom) == date
			expect(credential?.greenCard) == greenCard
			expect(greenCard.credentials).to(haveCount(1))
		}
	}

	func test_createTwoCredentials() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {
			let date = Date()
			let wallet = WalletModel.initialize(managedContext: context)!
			let greenCard = GreenCardModel.create(
				type: .domestic,
				issuedAt: date,
				wallet: wallet,
				managedContext: context
			)!
			let json = "test_createTwoCredentials".data(using: .utf8)!

			// When
			CredentialModel.create(
				qrData: json,
				validFrom: date,
				greenCard: greenCard,
				managedContext: context
			)
			CredentialModel.create(
				qrData: json,
				validFrom: date,
				greenCard: greenCard,
				managedContext: context
			)

			// Then
			expect(greenCard.credentials).to(haveCount(2))
		}
	}
}
