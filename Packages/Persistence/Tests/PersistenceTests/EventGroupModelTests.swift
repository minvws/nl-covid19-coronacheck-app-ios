/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import Persistence
import CoreData

class EventGroupModelTests: XCTestCase {

	var dataStoreManager: DataStoreManaging!

	override func setUp() {
		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory, persistentContainerName: "CoronaCheck", loadPersistentStoreCompletion: { _ in })
	}

	// MARK: Tests

	func test_createEvent() {

		// Given
		var wallet: Wallet?
		var eventGroup: EventGroup?
		let date = Date()
		let json = "test_createEvent".data(using: .utf8)
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedJson = json, let unwrappedWallet = wallet {

				// When
				eventGroup = EventGroup(
					type: EventMode.test(.ggd),
					providerIdentifier: "CoronaCheck",
					expiryDate: date,
					jsonData: unwrappedJson,
					wallet: unwrappedWallet,
					isDraft: false,
					managedContext: context
				)
			}
		}

		// Then
		expect(eventGroup?.type).toEventually(equal(EventMode.test(.ggd).rawValue))
		expect(eventGroup?.providerIdentifier).toEventually(equal("CoronaCheck"))
		expect(eventGroup?.expiryDate).toEventually(equal(date))
		expect(eventGroup?.jsonData).toEventually(equal(json))
		expect(eventGroup?.wallet).toEventually(equal(wallet))
		expect(wallet?.eventGroups).toEventually(haveCount(1))
	}

	func test_createTwoEvents() {

		// Given
		var wallet: Wallet?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet,
			   let json = "test_createTwoEvents".data(using: .utf8) {

				// When
				EventGroup(
					type: EventMode.test(.ggd),
					providerIdentifier: "CoronaCheck",
					expiryDate: nil,
					jsonData: json,
					wallet: unwrappedWallet,
					isDraft: false,
					managedContext: context
				)
				EventGroup(
					type: EventMode.vaccination,
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
		expect(wallet?.eventGroups).toEventually(haveCount(2))
	}

	func test_delete_twoEvents_deleteOne() throws {
		
		// Given
		var wallet: Wallet?
		var event1: EventGroup?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet,
			   let json = "test_createTwoEvents".data(using: .utf8) {

				// When
				event1 = EventGroup(
					type: EventMode.test(.ggd),
					providerIdentifier: "CoronaCheck",
					expiryDate: nil,
					jsonData: json,
					wallet: unwrappedWallet,
					isDraft: false,
					managedContext: context
				)
				EventGroup(
					type: EventMode.vaccination,
					providerIdentifier: "CoronaCheck",
					expiryDate: nil,
					jsonData: json,
					wallet: unwrappedWallet,
					isDraft: false,
					managedContext: context
				)
			}
		}
		
		// When
		let objectId = try XCTUnwrap(event1?.objectID)
		let result = dataStoreManager.delete(objectId)
		
		// Then
		expect(result.isSuccess) == true
		expect(wallet?.eventGroups).toEventually(haveCount(1))
	}
	
	func test_delete_twoEvents_deleteOneTwice() throws {
		
		// Given
		var wallet: Wallet?
		var event1: EventGroup?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet,
			   let json = "test_createTwoEvents".data(using: .utf8) {

				// When
				event1 = EventGroup(
					type: EventMode.test(.ggd),
					providerIdentifier: "CoronaCheck",
					expiryDate: nil,
					jsonData: json,
					wallet: unwrappedWallet,
					isDraft: false,
					managedContext: context
				)
				EventGroup(
					type: EventMode.vaccination,
					providerIdentifier: "CoronaCheck",
					expiryDate: nil,
					jsonData: json,
					wallet: unwrappedWallet,
					isDraft: false,
					managedContext: context
				)
			}
		}
		
		// When
		let objectId = try XCTUnwrap(event1?.objectID)
		_ = dataStoreManager.delete(objectId)
		let result = dataStoreManager.delete(objectId)

		// Then
		expect(result.isFailure) == true
		expect(wallet?.eventGroups).toEventually(haveCount(1))
	}
	
	func test_findBy() {
		
		// Given
		var wallet: Wallet?
		var eventGroup: EventGroup?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet,
			   let json = "test_findBy".data(using: .utf8) {
				
				EventGroup(
					type: EventMode.test(.ggd),
					providerIdentifier: "CoronaCheck",
					expiryDate: nil,
					jsonData: json,
					wallet: unwrappedWallet,
					isDraft: false,
					managedContext: context
				)
				
				EventGroup(
					type: EventMode.test(.commercial),
					providerIdentifier: "Other Provider",
					expiryDate: nil,
					jsonData: json,
					wallet: unwrappedWallet,
					isDraft: false,
					managedContext: context
				)

				// When
				eventGroup = EventGroupModel.findBy(
					wallet: unwrappedWallet,
					type: EventMode.test(.ggd),
					providerIdentifier: "CoronaCheck",
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
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			wallet = WalletModel.createTestWallet(managedContext: context)
			if let unwrappedWallet = wallet,
			   let json = "test_findBy_nothingFound".data(using: .utf8) {
				
				EventGroup(
					type: EventMode.test(.ggd),
					providerIdentifier: "CoronaCheck",
					expiryDate: nil,
					jsonData: json,
					wallet: unwrappedWallet,
					isDraft: false,
					managedContext: context
				)
				
				EventGroup(
					type: EventMode.test(.ggd),
					providerIdentifier: "Other Provider",
					expiryDate: nil,
					jsonData: json,
					wallet: unwrappedWallet,
					isDraft: false,
					managedContext: context
				)

				// When
				eventGroup = EventGroupModel.findBy(
					wallet: unwrappedWallet,
					type: EventMode.test(.ggd),
					providerIdentifier: "Third Provider",
					jsonData: json
				)
			}
		}
		// Then
		expect(eventGroup).toEventually(beNil())
	}
}
