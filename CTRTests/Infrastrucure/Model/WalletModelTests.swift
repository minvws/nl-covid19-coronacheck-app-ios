/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR
import CoreData

class WalletModelTests: XCTestCase {

	var dataStoreManager: DataStoreManaging!

	override func setUp() {
		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory)
	}

	// MARK: Tests

	func test_createWallet() {

		// Given
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			// When
			let newWallet = WalletModel.create(
				label: "test_createWallet",
				managedContext: context
			)

			// Then
			expect(newWallet).toNot(beNil())
			expect(newWallet?.label) == "test_createWallet"
			expect(newWallet?.eventGroups).to(haveCount(0))
			expect(newWallet?.greenCards).to(haveCount(0))
		}
	}

	func test_listWallets_noWallets() {

		// Given
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			// When
			let list = WalletModel.listAll(managedContext: context)

			// Then
			expect(list).to(beEmpty())
		}
	}

	func test_listWallets_oneWallet() {

		// Given
		let context = dataStoreManager.managedObjectContext()
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
		let context = dataStoreManager.managedObjectContext()
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

	func test_addEvent() {

		// Given
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			let wallet = WalletModel.createTestWallet(managedContext: context)!
			let date = Date()
			let json = "test_addEvent".data(using: .utf8)!

			// When
			let eventGroup = EventGroupModel.create(
				type: EventType.recovery,
				maxIssuedAt: date,
				jsonData: json,
				wallet: wallet,
				managedContext: context
			)

			// Then
			expect(wallet.eventGroups).to(haveCount(1))
			if case let walletEventGroup as EventGroup = wallet.eventGroups?.allObjects.first {
				expect(walletEventGroup) == eventGroup
			} else {
				fail("Event does not match")
			}
		}
	}

	func test_removeEvent() {

		// Given
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			let wallet = WalletModel.createTestWallet(managedContext: context)!
			let date = Date()
			let json = "test_removeEvent".data(using: .utf8)!
			let eventGroup = EventGroupModel.create(
				type: EventType.recovery,
				maxIssuedAt: date,
				jsonData: json,
				wallet: wallet,
				managedContext: context
			)!

			// When
			wallet.removeFromEventGroups(eventGroup)

			// Then
			expect(wallet.eventGroups).to(haveCount(0))
		}
	}

	func test_addGreenCard() {

		// Given
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			let wallet = WalletModel.createTestWallet(managedContext: context)!
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
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			let wallet = WalletModel.createTestWallet(managedContext: context)!
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

extension WalletModel {

	class func createTestWallet(managedContext: NSManagedObjectContext) -> Wallet? {

		return WalletModel.create(label: "testWallet", managedContext: managedContext)
	}
}
