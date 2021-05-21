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

	func test_createGreenCard_domesticType() {

		// Given
		var wallet: Wallet?
		var greenCard: GreenCard?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet {

				// When
				greenCard = GreenCardModel.create(
					type: .domestic,
					wallet: unwrappedWallet,
					managedContext: context
				)
			}
		}

		// Then
		expect(greenCard?.type).toEventually(equal(GreenCardType.domestic.rawValue))
		expect(greenCard?.getType()).toEventually(equal(GreenCardType.domestic))
		expect(greenCard?.wallet).toEventually(equal(wallet))
		expect(wallet?.greenCards).toEventually(haveCount(1))
	}

	func test_createGreenCard_euType() {

		// Given
		var wallet: Wallet?
		var greenCard: GreenCard?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet {

				// When
				greenCard = GreenCardModel.create(
					type: .eu,
					wallet: unwrappedWallet,
					managedContext: context
				)
			}
		}

		// Then
		expect(greenCard?.type).toEventually(equal(GreenCardType.eu.rawValue))
		expect(greenCard?.getType()).toEventually(equal(GreenCardType.eu))
		expect(greenCard?.wallet).toEventually(equal(wallet))
		expect(wallet?.greenCards).toEventually(haveCount(1))
	}

	func test_createGreenCard_unknownType() {

		// Given
		var wallet: Wallet?
		var greenCard: GreenCard?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet {

				// When
				greenCard = GreenCardModel.create(
					type: .eu,
					wallet: unwrappedWallet,
					managedContext: context
				)
				greenCard?.type = "unknown"
			}
		}

		// Then
		expect(greenCard?.type).toEventually(equal("unknown"))
		expect(greenCard?.getType()).toEventually(beNil())
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

				// When
				GreenCardModel.create(
					type: .domestic,
					wallet: unwrappedWallet,
					managedContext: context
				)
				GreenCardModel.create(
					type: .eu,
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
					wallet: wallet,
					managedContext: context
				)

				if let unwrappedGreenCard = greenCard {

					// When
					credential = CredentialModel.create(
						data: unwrappedJson,
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
				type: .eu,
				wallet: wallet,
				managedContext: context
			   ),
			   let json = "test_removeCredential".data(using: .utf8),
			   let credential = CredentialModel.create(
				data: json,
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

	func test_addOrigin() {

		// Given
		var greenCard: GreenCard?
		var origin: Origin?
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
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
						expireDate: date,
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
				}
			}
		}

		// Then
		expect(greenCard?.origins).to(haveCount(1))
		if case let actualOrigin as Origin = greenCard?.origins?.allObjects.first {
			expect(actualOrigin) == origin
		} else {
			fail("origin does not match")
		}
	}

	func test_removeOrigin() {

		// Given
		var listIsEmpty = false
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.createTestWallet(managedContext: context),
			   let greenCard = GreenCardModel.create(
				type: .eu,
				wallet: wallet,
				managedContext: context
			   ),
			   let origin = OriginModel.create(
				type: .vaccination,
				eventDate: date,
				expireDate: date,
				greenCard: greenCard,
				managedContext: context
			   ) {

				// When
				greenCard.removeFromOrigins(origin)
				listIsEmpty = greenCard.origins?.allObjects.isEmpty ?? false
			}
		}

		// Then
		expect(listIsEmpty).toEventually(beTrue())
	}
}
