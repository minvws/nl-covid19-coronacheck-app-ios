/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
import XCTest
import Nimble
@testable import CTR

class WalletModelTests: XCTestCase {

	var databaseManager = DatabaseManager()

	override func tearDown() {

		databaseManager.clearCoreData()
		super.tearDown()
	}

	// MARK: Tests

	func test_createWallet() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {

			// When
			let newWallet = WalletModel.create(
				label: "test_createWallet",
				managedContext: context
			)

			// Then
			expect(newWallet).toNot(beNil())
			expect(newWallet?.label) == "test_createWallet"
			expect(newWallet?.events).to(haveCount(0))
			expect(newWallet?.greenCards).to(haveCount(0))
		}
	}

	func test_listWallets_noWallets() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {

			// When
			let list = WalletModel.listAll(managedContext: context)

			// Then
			expect(list).to(beEmpty())
		}
	}

	func test_listWallets_oneWallet() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {

			WalletModel.create(
				label: "test_listWallets_oneWallet",
				managedContext: context
			)

			// When
			let list = WalletModel.listAll(managedContext: context)

			// Then
			expect(list).toNot(beEmpty())
			expect(list).to(haveCount(1))
			expect(list.first?.label) == "test_listWallets_oneWallet"
		}
	}

	func test_listWallets_twoWallets() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {

			WalletModel.create(
				label: "test_listWallets_twoWallets_first",
				managedContext: context
			)
			WalletModel.create(
				label: "test_listWallets_twoWallets_second",
				managedContext: context
			)

			// When
			let list = WalletModel.listAll(managedContext: context)

			// Then
			expect(list).toNot(beEmpty())
			expect(list).to(haveCount(2))
		}
	}

	func test_initializeWallet() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {

			// When
			let wallet = WalletModel.initialize(managedContext: context)

			// Then
			expect(wallet?.label) == "main"
		}
	}

	func test_initializeWallet_existingWallet() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {

			WalletModel.create(
				label: "test_initializeWallet_existingWallet",
				managedContext: context
			)

			// When
			let wallet = WalletModel.initialize(managedContext: context)

			// Then
			expect(wallet?.label) == "test_initializeWallet_existingWallet"
		}
	}

	func test_addEvent() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {

			let wallet = WalletModel.initialize(managedContext: context)!
			let date = Date()
			let json = "test_addEvent".data(using: .utf8)!

			// When
			let event = EventModel.create(
				type: EventType.recovery,
				issuedAt: date,
				jsonData: json,
				wallet: wallet,
				managedContext: context
			)

			// Then
			expect(wallet.events).to(haveCount(1))
			if case let walletEvent as Event = wallet.events?.allObjects.first {
				expect(walletEvent) == event
			} else {
				fail("Event does not match")
			}
		}
	}

	func test_removeEvent() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {

			let wallet = WalletModel.initialize(managedContext: context)!
			let date = Date()
			let json = "test_removeEvent".data(using: .utf8)!
			let event = EventModel.create(
				type: EventType.recovery,
				issuedAt: date,
				jsonData: json,
				wallet: wallet,
				managedContext: context
			)!

			// When
			wallet.removeFromEvents(event)

			// Then
			expect(wallet.events).to(haveCount(0))
		}
	}

	func test_addGreenCard() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {

			let wallet = WalletModel.initialize(managedContext: context)!
			let date = Date()

			// When
			let greenCard = GreenCardModel.create(
				type: .euTest,
				issuedAt: date,
				wallet: wallet,
				managedContext: context
			)

			// Then
			expect(wallet.greenCards).to(haveCount(1))
			if case let walletGreenCard as GreenCard = wallet.greenCards?.allObjects.first {
				expect(walletGreenCard) == greenCard
			} else {
				fail("greenCard does not match")
			}
		}
	}

	func test_removeGreencard() {

		// Given
		let context = databaseManager.managedObjectContext()
		context.performAndWait {

			let wallet = WalletModel.initialize(managedContext: context)!
			let date = Date()
			let greenCard = GreenCardModel.create(
				type: .euRecovery,
				issuedAt: date,
				wallet: wallet,
				managedContext: context
			)!

			// When
			wallet.removeFromGreenCards(greenCard)

			// Then
			expect(wallet.greenCards).to(haveCount(0))
		}
	}
}
