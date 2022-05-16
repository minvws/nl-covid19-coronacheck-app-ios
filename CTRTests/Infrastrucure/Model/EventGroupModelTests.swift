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

class EventGroupModelTests: XCTestCase {

	var environmentalSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		environmentalSpies = setupEnvironmentSpies()
	}

	// MARK: Tests

	func test_createEvent() {

		// Given
		var wallet: Wallet?
		var eventGroup: EventGroup?
		let date = Date()
		let json = "test_createEvent".data(using: .utf8)
		let context = Current.dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedJson = json, let unwrappedWallet = wallet {

				// When
				eventGroup = EventGroupModel.create(
					type: EventMode.test,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: date,
					jsonData: unwrappedJson,
					wallet: unwrappedWallet,
					managedContext: context
				)
			}
		}

		// Then
		expect(eventGroup?.type).toEventually(equal(EventMode.test.rawValue))
		expect(eventGroup?.providerIdentifier).toEventually(equal("CoronaCheck"))
		expect(eventGroup?.maxIssuedAt).toEventually(equal(date))
		expect(eventGroup?.jsonData).toEventually(equal(json))
		expect(eventGroup?.wallet).toEventually(equal(wallet))
		expect(wallet?.eventGroups).toEventually(haveCount(1))
	}

	func test_createTwoEvents() {

		// Given
		var wallet: Wallet?
		let context = Current.dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet,
			   let json = "test_createTwoEvents".data(using: .utf8) {

				// When
				EventGroupModel.create(
					type: EventMode.test,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: Date(),
					jsonData: json,
					wallet: unwrappedWallet,
					managedContext: context
				)
				EventGroupModel.create(
					type: EventMode.vaccination,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: Date(),
					jsonData: json,
					wallet: unwrappedWallet,
					managedContext: context
				)
			}
		}
		// Then
		expect(wallet?.eventGroups).toEventually(haveCount(2))
	}

	func test_delete_twoEvents_deleteOne() throws {
		
		// Given
		var wallet: Wallet?
		var event1: EventGroup?
		let context = Current.dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet,
			   let json = "test_createTwoEvents".data(using: .utf8) {

				// When
				event1 = EventGroupModel.create(
					type: EventMode.test,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: Date(),
					jsonData: json,
					wallet: unwrappedWallet,
					managedContext: context
				)
				EventGroupModel.create(
					type: EventMode.vaccination,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: Date(),
					jsonData: json,
					wallet: unwrappedWallet,
					managedContext: context
				)
			}
		}
		
		// When
		let objectId = try XCTUnwrap(event1?.objectID)
		let result = EventGroupModel.delete(objectId, managedObjectContext: context, save: { Current.dataStoreManager.save(Current.dataStoreManager.managedObjectContext()) })
		
		// Then
		expect(result.isSuccess) == true
		expect(wallet?.eventGroups).toEventually(haveCount(1))
	}
	
	func test_delete_twoEvents_deleteOneTwice() throws {
		
		// Given
		var wallet: Wallet?
		var event1: EventGroup?
		let context = Current.dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet,
			   let json = "test_createTwoEvents".data(using: .utf8) {

				// When
				event1 = EventGroupModel.create(
					type: EventMode.test,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: Date(),
					jsonData: json,
					wallet: unwrappedWallet,
					managedContext: context
				)
				EventGroupModel.create(
					type: EventMode.vaccination,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: Date(),
					jsonData: json,
					wallet: unwrappedWallet,
					managedContext: context
				)
			}
		}
		
		// When
		let objectId = try XCTUnwrap(event1?.objectID)
		_ = EventGroupModel.delete(objectId, managedObjectContext: context, save: { Current.dataStoreManager.save(Current.dataStoreManager.managedObjectContext()) })
		let result = EventGroupModel.delete(objectId, managedObjectContext: context, save: { Current.dataStoreManager.save(Current.dataStoreManager.managedObjectContext()) })

		// Then
		expect(result.isFailure) == true
		expect(wallet?.eventGroups).toEventually(haveCount(1))
	}
	
	func test_findBy() {
		
		// Given
		var wallet: Wallet?
		var eventGroup: EventGroup?
		let context = Current.dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet,
			   let json = "test_findBy".data(using: .utf8) {
				
				EventGroupModel.create(
					type: EventMode.test,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: now,
					jsonData: json,
					wallet: unwrappedWallet,
					managedContext: context
				)
				
				EventGroupModel.create(
					type: EventMode.test,
					providerIdentifier: "Other Provider",
					maxIssuedAt: now,
					jsonData: json,
					wallet: unwrappedWallet,
					managedContext: context
				)

				// When
				eventGroup = EventGroupModel.findBy(
					wallet: unwrappedWallet,
					type: EventMode.test,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: now,
					jsonData: json
				)
			}
		}
		// Then
		expect(eventGroup).toEventuallyNot(beNil())
		expect(eventGroup?.providerIdentifier).toEventually(equal("CoronaCheck"))
	}
	
	func test_findBy_nothingFound() {
		
		// Given
		var wallet: Wallet?
		var eventGroup: EventGroup?
		let context = Current.dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet,
			   let json = "test_findBy_nothingFound".data(using: .utf8) {
				
				EventGroupModel.create(
					type: EventMode.test,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: now,
					jsonData: json,
					wallet: unwrappedWallet,
					managedContext: context
				)
				
				EventGroupModel.create(
					type: EventMode.test,
					providerIdentifier: "Other Provider",
					maxIssuedAt: now,
					jsonData: json,
					wallet: unwrappedWallet,
					managedContext: context
				)

				// When
				eventGroup = EventGroupModel.findBy(
					wallet: unwrappedWallet,
					type: EventMode.test,
					providerIdentifier: "Third Provider",
					maxIssuedAt: now,
					jsonData: json
				)
			}
		}
		// Then
		expect(eventGroup).toEventually(beNil())
	}
}
