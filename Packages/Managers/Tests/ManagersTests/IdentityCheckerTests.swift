/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
import TestingShared
@testable import Managers
@testable import Models
@testable import Persistence
@testable import Transport
@testable import Shared

class IdentityCheckerTests: XCTestCase {
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (IdentityChecker, DataStoreManager) {
			
		let cryptoManagerSpy = CryptoManagerSpy()
		let dataStoreManager = DataStoreManager(.inMemory, persistentContainerName: "CoronaCheck", loadPersistentStoreCompletion: { _ in })
		let sut = IdentityChecker(cryptoManager: cryptoManagerSpy)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, dataStoreManager)
	}

	// MARK: - Tests

	func test_noEventGroups_noRemoteEvents() {

		// Given
		let (sut, _) = makeSUT()

		// When
		let matched = sut.compare(eventGroups: [], with: [])

		// Then
		expect(matched) == true
	}

	func test_noEventGroup_remoteEventV3() {

		// Given
		let (sut, _) = makeSUT()
		let remoteEvent = RemoteEvent(wrapper: .fakeWithV3Identity, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [], with: [remoteEvent])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3_noRemoteEvents() throws {

		// Given
		let (sut, dataStoreManager) = makeSUT()
		let eventGroup = try XCTUnwrap( createEventGroup(dataStoreManager: dataStoreManager, wrapper: .fakeWithV3Identity))

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3_remoteEventv3() throws {

		// Given
		let (sut, dataStoreManager) = makeSUT()
		let eventGroup = try XCTUnwrap( createEventGroup(dataStoreManager: dataStoreManager, wrapper: .fakeWithV3Identity))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3Identity, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3_remoteEventV3Alternative() throws {

		// Given
		let (sut, dataStoreManager) = makeSUT()
		let eventGroup = try XCTUnwrap( createEventGroup(dataStoreManager: dataStoreManager, wrapper: .fakeWithV3Identity))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternative, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == false
	}
	
	func test_eventGroupV3Alternative_remoteEventV3AlternativeLowercase() throws {
		
		// Given
		let (sut, dataStoreManager) = makeSUT()
		let eventGroup = try XCTUnwrap( createEventGroup(dataStoreManager: dataStoreManager, wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternativeLowerCase, signedResponse: nil)
		
		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])
		
		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Alternative_remoteEventv3() throws {

		// Given
		let (sut, dataStoreManager) = makeSUT()
		let eventGroup = try XCTUnwrap( createEventGroup(dataStoreManager: dataStoreManager, wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3Identity, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == false
	}

	func test_eventGroupV3Alternative_remoteEventv3Alternative() throws {

		// Given
		let (sut, dataStoreManager) = makeSUT()
		let eventGroup = try XCTUnwrap( createEventGroup(dataStoreManager: dataStoreManager, wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternative, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Diacritic_remoteEventv3Alternative() throws {

		// Given
		let (sut, dataStoreManager) = makeSUT()
		let eventGroup = try XCTUnwrap( createEventGroup(dataStoreManager: dataStoreManager, wrapper: .fakeWithV3IdentityFirstNameWithDiacritic))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternative, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Alternative_remoteEventv3Diacritic() throws {

		// Given
		let (sut, dataStoreManager) = makeSUT()
		let eventGroup = try XCTUnwrap( createEventGroup(dataStoreManager: dataStoreManager, wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityFirstNameWithDiacritic, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Diacritic_remoteEventv3Diacritic_identicalDiacritic() throws {

		// Given
		let (sut, dataStoreManager) = makeSUT()
		let eventGroup = try XCTUnwrap( createEventGroup(dataStoreManager: dataStoreManager, wrapper: .fakeWithV3IdentityFirstNameWithDiacritic))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityFirstNameWithDiacritic, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Diacritic_remoteEventv3AlternativeDiacritic() throws {

		// Given
		let (sut, dataStoreManager) = makeSUT()
		let eventGroup = try XCTUnwrap( createEventGroup(dataStoreManager: dataStoreManager, wrapper: .fakeWithV3IdentityFirstNameWithDiacriticAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityFirstNameWithDiacritic, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3IdentityAlternative_remoteEventV3IdentityAlternative2() throws {

		// Given
		let (sut, dataStoreManager) = makeSUT()
		let eventGroup = try XCTUnwrap( createEventGroup(dataStoreManager: dataStoreManager, wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternative2, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	// MARK: - Helper

	private func createEventGroup(dataStoreManager: DataStoreManaging, wrapper: EventFlow.EventResultWrapper) -> EventGroup? {

		var eventGroup: EventGroup?
		if let payloadData = try? JSONEncoder().encode(wrapper) {
		   let base64String = payloadData.base64EncodedString()
			let signedResponse = SignedResponse(payload: base64String, signature: "does not matter for this test")
			let context = dataStoreManager.managedObjectContext()
			context.performAndWait {
				if let wallet = WalletModel.createTestWallet(managedContext: context),
				   let jsonData = try? JSONEncoder().encode(signedResponse) {
					eventGroup = EventGroup(
						type: EventMode.recovery,
						providerIdentifier: "CoronaCheck",
						expiryDate: nil,
						jsonData: jsonData,
						wallet: wallet,
						isDraft: false,
						managedContext: context
					)
				}
			}
		}
		return eventGroup
	}
}
