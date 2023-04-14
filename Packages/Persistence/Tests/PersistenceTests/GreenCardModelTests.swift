/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
@testable import Persistence
@testable import TestingShared

class GreenCardModelTests: XCTestCase {
	
	var dataStoreManager: DataStoreManaging!
	
	override func setUp() {
		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory, persistentContainerName: "CoronaCheck", loadPersistentStoreCompletion: { _ in })
	}
	
	// MARK: Tests
	
	func test_createGreenCard_euType() {
		
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
				greenCard = GreenCard(
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
				GreenCard(
					type: .eu,
					wallet: unwrappedWallet,
					managedContext: context
				)
				GreenCard(
					type: .eu,
					wallet: unwrappedWallet,
					managedContext: context
				)
			}
		}
		// Then
		expect(wallet?.greenCards).toEventually(haveCount(2))
	}
}

// MARK: Credential

extension GreenCardModelTests {
	
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
				greenCard = GreenCard(
					type: .eu,
					wallet: wallet,
					managedContext: context
				)
				
				if let unwrappedGreenCard = greenCard {
					
					// When
					credential = Credential(
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
			   let json = "test_removeCredential".data(using: .utf8) {
				let greenCard = GreenCard(
					type: .eu,
					wallet: wallet,
					managedContext: context
				)
				let credential = Credential(
					data: json,
					validFrom: date,
					expirationTime: date,
					greenCard: greenCard,
					managedContext: context
				)
				
				// When
				greenCard.removeFromCredentials(credential)
				listIsEmpty = greenCard.credentials?.allObjects.isEmpty ?? false
			}
		}
		
		// Then
		expect(listIsEmpty).toEventually(beTrue())
	}
}

// MARK: Origin

extension GreenCardModelTests {
	
	func test_addOrigin() {
		
		// Given
		var greenCard: GreenCard?
		var origin: Origin?
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				greenCard = GreenCard(
					type: .eu,
					wallet: wallet,
					managedContext: context
				)
				
				if let unwrappedGreenCard = greenCard {
					// When
					origin = Origin(
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
			
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				let greenCard = GreenCard(
					type: .eu,
					wallet: wallet,
					managedContext: context
				)
				let origin = Origin(
					type: .vaccination,
					eventDate: date,
					expirationTime: date,
					validFromDate: date,
					doseNumber: 1,
					greenCard: greenCard,
					managedContext: context
				)
				
				// When
				greenCard.removeFromOrigins(origin)
				listIsEmpty = greenCard.origins?.allObjects.isEmpty ?? false
			}
		}
		
		// Then
		expect(listIsEmpty).toEventually(beTrue())
	}
}

// MARK: activeCredentialsNowOrInFuture

extension GreenCardModelTests {
	
	func test_activeCredentialsNowOrInFuture_noCredentials() {
		
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
		expect(greenCard?.activeCredentialsNowOrInFuture(forDate: now)).to(beEmpty())
		expect(greenCard?.hasActiveCredentialNowOrInFuture(forDate: now)) == false
		expect(greenCard?.currentOrNextActiveCredential(forDate: now)) == nil
	}
	
	func test_activeCredentialsNowOrInFuture_singleActiveCredential() throws {
		
		// Given
		var wallet: Wallet?
		var greenCard: GreenCard?
		var credential: Credential?
		let context = dataStoreManager.managedObjectContext()
		let json = try XCTUnwrap("test_activeCredentialsNowOrInFuture_singleActiveCredential".data(using: .utf8))
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet {
				
				// When
				greenCard = GreenCard(
					type: .eu,
					wallet: unwrappedWallet,
					managedContext: context
				)
				if let unwrappedGreenCard = greenCard {
					
					// When
					credential = Credential(
						data: json,
						validFrom: now.addingTimeInterval(1 * days * ago),
						expirationTime: now.addingTimeInterval(1 * days),
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
				}
			}
		}
		
		// Then
		expect(greenCard?.activeCredentialsNowOrInFuture(forDate: now)).to(haveCount(1))
		expect(greenCard?.hasActiveCredentialNowOrInFuture(forDate: now)) == true
		expect(greenCard?.currentOrNextActiveCredential(forDate: now)) == credential
		expect(greenCard?.getLatestInternationalCredential()) == credential
	}
	
	func test_activeCredentialsNowOrInFuture_singleExpiredCredential() throws {
		
		// Given
		var wallet: Wallet?
		var greenCard: GreenCard?
		var credential: Credential?
		let context = dataStoreManager.managedObjectContext()
		let json = try XCTUnwrap("test_activeCredentialsNowOrInFuture_singleExpiredCredential".data(using: .utf8))
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet {
				
				// When
				greenCard = GreenCard(
					type: .eu,
					wallet: unwrappedWallet,
					managedContext: context
				)
				if let unwrappedGreenCard = greenCard {
					
					// When
					credential = Credential(
						data: json,
						validFrom: now.addingTimeInterval(2 * days * ago),
						expirationTime: now.addingTimeInterval(1 * days * ago),
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
				}
			}
		}
		
		// Then
		expect(greenCard?.activeCredentialsNowOrInFuture(forDate: now)).to(beEmpty())
		expect(greenCard?.hasActiveCredentialNowOrInFuture(forDate: now)) == false
		expect(greenCard?.currentOrNextActiveCredential(forDate: now)) == nil
		expect(greenCard?.getLatestInternationalCredential()) == credential
	}
	
	func test_activeCredentialsNowOrInFuture_twoActiveCredentials() throws {
		
		// Given
		var wallet: Wallet?
		var greenCard: GreenCard?
		var credentialValidFrom10HoursAgo: Credential?
		var credentialValidFrom5HoursAgo: Credential?
		let context = dataStoreManager.managedObjectContext()
		let json = try XCTUnwrap("test_activeCredentialsNowOrInFuture_twoActiveCredentials".data(using: .utf8))
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet {
				
				// When
				greenCard = GreenCard(
					type: .eu,
					wallet: unwrappedWallet,
					managedContext: context
				)
				if let unwrappedGreenCard = greenCard {
					
					// When
					credentialValidFrom10HoursAgo = Credential(
						data: json,
						validFrom: now.addingTimeInterval(10 * hour * ago),
						expirationTime: now.addingTimeInterval(1 * days),
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
					credentialValidFrom5HoursAgo = Credential(
						data: json,
						validFrom: now.addingTimeInterval(5 * hour * ago),
						expirationTime: now.addingTimeInterval(1 * days),
						greenCard: unwrappedGreenCard,
						managedContext: context
					)
				}
			}
		}
		
		// Then
		expect(greenCard?.activeCredentialsNowOrInFuture(forDate: now)).to(haveCount(2))
		expect(greenCard?.hasActiveCredentialNowOrInFuture(forDate: now)) == true
		expect(greenCard?.currentOrNextActiveCredential(forDate: now)) == credentialValidFrom10HoursAgo
		expect(greenCard?.currentOrNextActiveCredential(forDate: now)) != credentialValidFrom5HoursAgo
	}
}
