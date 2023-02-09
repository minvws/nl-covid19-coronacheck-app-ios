/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
@testable import Persistence

class OriginHintModelTests: XCTestCase {
	
	var dataStoreManager: DataStoreManaging!
	
	override func setUp() {
		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory, persistentContainerName: "CoronaCheck", loadPersistentStoreCompletion: { _ in })
	}
	
	// MARK: Tests
	
	func test_createHint() {
		
		// Given
		var greenCard: GreenCard?
		var origin: Origin?
		var hint: OriginHint?
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
					
					if let unwrappedOrigin = origin {
						hint = OriginHint(origin: unwrappedOrigin, hint: "test hint", managedContext: context)
					}
				}
			}
		}
		
		// Then
		expect(origin?.hints).toEventually(haveCount(1))
		expect(hint?.hint).toEventually(equal("test hint"))
	}
	
	func test_createTwoHints() {
		
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
					
					if let unwrappedOrigin = origin {
						OriginHint(origin: unwrappedOrigin, hint: "hint one", managedContext: context)
						OriginHint(origin: unwrappedOrigin, hint: "hint two", managedContext: context)
					}
				}
			}
		}
		
		// Then
		expect(origin?.hints).toEventually(haveCount(2))
	}
}
