/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
		dataStoreManager = DataStoreManager(.inMemory, loadPersistentStoreCompletion: { _ in })
	}
	
	// MARK: Tests
	
	func test_createWallet() {
		
		// Given
		var wallet: Wallet?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			// When
			wallet = Wallet(
				label: "test_createWallet",
				managedContext: context
			)
		}
		
		// Then
		expect(wallet).toEventuallyNot(beNil())
		expect(wallet?.label).toEventually(equal("test_createWallet"))
		expect(wallet?.eventGroups).toEventually(haveCount(0))
		expect(wallet?.greenCards).toEventually(haveCount(0))
	}
	
	func test_listWallets_noWallets() {
		
		// Given
		var listIsEmpty = false
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			// When
			listIsEmpty = WalletModel.listAll(managedContext: context).isEmpty
		}
		// Then
		expect(listIsEmpty).toEventually(beTrue())
	}
	
	func test_listWallets_oneWallet() {
		
		// Given
		var list = [Wallet]()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			Wallet(
				label: "test_listWallets_oneWallet",
				managedContext: context
			)
			
			// When
			list = WalletModel.listAll(managedContext: context)
		}
		// Then
		expect(list).toEventuallyNot(beEmpty())
		expect(list).toEventually(haveCount(1))
		expect(list.first?.label).toEventually(equal("test_listWallets_oneWallet"))
	}
	
	func test_listWallets_twoWallets() {
		
		// Given
		var list = [Wallet]()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			Wallet(
				label: "test_listWallets_twoWallets_first",
				managedContext: context
			)
			Wallet(
				label: "test_listWallets_twoWallets_second",
				managedContext: context
			)
			
			// When
			list = WalletModel.listAll(managedContext: context)
		}
		// Then
		expect(list).toEventuallyNot(beEmpty())
		expect(list).toEventually(haveCount(2))
	}
	
	func test_addEvent() {
		
		// Given
		var wallet: Wallet?
		var eventGroup: EventGroup?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet, let json = "test_addEvent".data(using: .utf8) {
				
				// When
				eventGroup = EventGroup(
					type: EventMode.recovery,
					providerIdentifier: "CoronaCheck",
					expiryDate: nil,
					jsonData: json,
					wallet: unwrappedWallet,
					isDraft: false,
					managedContext: context
				)
			}
		}
		// Then
		expect(wallet?.eventGroups).toEventually(haveCount(1))
		if case let walletEventGroup as EventGroup = wallet?.eventGroups?.allObjects.first {
			expect(walletEventGroup) == eventGroup
		} else {
			fail("Event does not match")
		}
	}
	
	func test_removeEvent() {
		
		// Given
		var listIsEmpty = false
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context),
			   let json = "test_removeEvent".data(using: .utf8) {
			   let eventGroup = EventGroup(
				type: EventMode.recovery,
				providerIdentifier: "CoronaCheck",
				expiryDate: nil,
				jsonData: json,
				wallet: wallet,
				isDraft: false,
				managedContext: context
			   )
				
				// When
				wallet.removeFromEventGroups(eventGroup)
				listIsEmpty = wallet.eventGroups?.allObjects.isEmpty ?? false
			}
		}
		// Then
		expect(listIsEmpty).toEventually(beTrue())
	}
	
	func test_addGreenCard() {
		
		// Given
		var wallet: Wallet?
		var greenCard: GreenCard?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet {
				
				// When
				greenCard = GreenCard(
					type: .eu,
					wallet: unwrappedWallet,
					managedContext: context
				)
			}
		}
		// Then
		expect(wallet?.greenCards).toEventually(haveCount(1))
		if case let walletGreenCard as GreenCard = wallet?.greenCards?.allObjects.first {
			expect(walletGreenCard) == greenCard
		} else {
			fail("greenCard does not match")
		}
	}
	
	func test_removeGreencard() {
		
		// Given
		var listIsEmpty = false
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				let greenCard = GreenCard(
					type: .eu,
					wallet: wallet,
					managedContext: context
				)
				
				// When
				wallet.removeFromGreenCards(greenCard)
				listIsEmpty = wallet.greenCards?.allObjects.isEmpty ?? false
			}
		}
		expect(listIsEmpty).toEventually(beTrue())
	}
	
	func test_findBy_noResult() {
		
		// Given
		var resultIsNil = false
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			// When
			resultIsNil = WalletModel.findBy(label: "testWallet", managedContext: context) == nil
		}
		// Then
		expect(resultIsNil).toEventually(beTrue())
	}
	
	func test_findBy_withResult() {
		
		// Given
		var wallet: Wallet?
		var result: Wallet?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			wallet = WalletModel.createTestWallet(managedContext: context)
			
			// When
			result = WalletModel.findBy(label: "testWallet", managedContext: context)
		}
		// Then
		expect(result).toEventuallyNot(beNil())
		expect(result).toEventually(equal(wallet))
	}
	
	func test_findBy_wrongWalletName() {
		
		// Given
		var resultIsNil = false
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			WalletModel.createTestWallet(managedContext: context)
			
			// When
			resultIsNil = WalletModel.findBy(label: "wrong wallet name", managedContext: context) == nil
		}
		// Then
		expect(resultIsNil).toEventually(beTrue())
	}
}

extension WalletModel {
	
	@discardableResult class func createTestWallet(managedContext: NSManagedObjectContext) -> Wallet? {
		
		return Wallet(label: "testWallet", managedContext: managedContext)
	}
}
