/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class IdentityCheckerTests: XCTestCase {

	var sut: IdentityChecker!
	var cryptoSpy: CryptoManagerSpy!
	var dataStoreManager: DataStoreManaging!

	override func setUp() {
		super.setUp()

		dataStoreManager = DataStoreManager(.inMemory)
		cryptoSpy = CryptoManagerSpy()
		sut = IdentityChecker(cryptoManager: cryptoSpy)
	}

	// MARK: - Tests

	func test_noEventGroups_noRemoteEvents() {

		// Given

		// When
		let matched = sut.compare(eventGroups: [], with: [])

		// Then
		expect(matched) == true
	}

	func test_noEventGroup_remoteEventV2() {

		// Given
		let remoteEvent = RemoteEvent(wrapper: .fakeWithV2Identity, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [], with: [remoteEvent])

		// Then
		expect(matched) == true
	}

	func test_noEventGroup_remoteEventV3() {

		// Given
		let remoteEvent = RemoteEvent(wrapper: .fakeWithV3Identity, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [], with: [remoteEvent])

		// Then
		expect(matched) == true
	}

	func test_noEventGroup_remoteEventV2_andV3() {

		// Given
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3Identity, signedResponse: nil)
		let remoteEventV2 = RemoteEvent(wrapper: .fakeWithV2Identity, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [], with: [remoteEventV2, remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3_noRemoteEvents() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3Identity))

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3_removeEventv3() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3Identity))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3Identity, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV2_removeEventv3() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV2Identity))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3Identity, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3_removeEventv2() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3Identity))
		let remoteEventV2 = RemoteEvent(wrapper: .fakeWithV2Identity, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV2])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3_removeEventV3Alternative() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3Identity))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternative, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == false
	}

	func test_eventGroupV3Alternative_removeEventv3() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3Identity, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == false
	}

	func test_eventGroupV3Alternative_removeEventv3Alternative() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternative, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Diacritic_removeEventv3Alternative() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityFirstNameWithDiacritic))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternative, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Alternative_removeEventv3Diacritic() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityFirstNameWithDiacritic, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Diacritic_removeEventv3Diacritic_identicalDiacritic() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityFirstNameWithDiacritic))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityFirstNameWithDiacritic, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Diacritic_removeEventv3AlternativeDiacritic() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityFirstNameWithDiacriticAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityFirstNameWithDiacritic, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3IdentityAlternative_remoteEventV3IdentityAlternative2() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternative2, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV2IdentityAlternative_remoteEventV3IdentityAlternative2() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV2IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternative2, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	// MARK: - Helper

	private func createEventGroup(wrapper: EventFlow.EventResultWrapper) -> EventGroup? {

		var eventGroup: EventGroup?
		if let payloadData = try? JSONEncoder().encode(wrapper) {
		   let base64String = payloadData.base64EncodedString()
			let signedResponse = SignedResponse(payload: base64String, signature: "does not matter for this test")
			let context = dataStoreManager.managedObjectContext()
			context.performAndWait {
				if let wallet = WalletModel.createTestWallet(managedContext: context),
				   let jsonData = try? JSONEncoder().encode(signedResponse) {
					eventGroup = EventGroupModel.create(
						type: EventMode.recovery,
						providerIdentifier: "CoronaCheck",
						maxIssuedAt: Date(),
						jsonData: jsonData,
						wallet: wallet,
						managedContext: context
					)
				}
			}
		}
		return eventGroup
	}

	func test_normalization() {

		// Given
		let values: [String: String] = [
			"'Doorn": "D",
			"Rool": "R",
			"rool": "R",
			" rool": "R",
			"-rool": "R"
		]
		for (value, expected) in values {
			let identity = EventFlow.Identity(infix: nil, firstName: value, lastName: nil, birthDateString: nil)

			// When
			let tuple = identity.asIdentityTuple()

			expect(tuple.firstNameInitial) == expected
		}
	}

	func test_normalization_valuesShouldReturnNil() {

		// Given
		let values: [String] = [
			"#$pietje",
			"παράδειγμα δοκιμής",
			"Ægir",
			"Özturk",
			"ТЕСТ МИЛИЦА",
			"王",
			"Şımarık",
			"Ådne",
			"محمود عبدالرحيم",
			"أحمد‎"
		]
		for value in values {
			let identity = EventFlow.Identity(infix: nil, firstName: value, lastName: nil, birthDateString: nil)

			// When
			let tuple = identity.asIdentityTuple()

			expect(tuple.firstNameInitial).to(beNil())
		}
	}
}

extension EventFlow.EventResultWrapper {

	static var fakeWithV3Identity: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Test", lastName: "de Tester", birthDateString: "1990-12-12"),
			status: .complete,
			result: nil
		)
	}

	static var fakeWithV3IdentityAlternative: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Rool", lastName: "Paap", birthDateString: "1970-05-27"),
			status: .complete,
			result: nil
		)
	}

	static var fakeWithV3IdentityAlternative2: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Henk", lastName: "Paap", birthDateString: "1970-05-27"),
			status: .complete,
			result: nil
		)
	}

	static var fakeWithV3IdentityFirstNameWithDiacritic: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Ådne", lastName: "Paap", birthDateString: "1970-05-27"),
			status: .complete,
			result: nil
		)
	}

	static var fakeWithV3IdentityFirstNameWithDiacriticAlternative: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Ægir", lastName: "Paap", birthDateString: "1970-05-27"),
			status: .complete,
			result: nil
		)
	}

	static var fakeWithV2Identity: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "2,0",
			identity: nil,
			status: .complete,
			result: TestResult(
				unique: "test",
				sampleDate: "2021-01-01T12:00:00",
				testType: "PCR",
				negativeResult: true,
				holder: TestHolderIdentity(
					firstNameInitial: "T",
					lastNameInitial: "D",
					birthDay: "12",
					birthMonth: "12"
				)
			)
		)
	}

	static var fakeWithV2IdentityAlternative: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "2,0",
			identity: nil,
			status: .complete,
			result: TestResult(
				unique: "test",
				sampleDate: "2021-01-01T12:00:00",
				testType: "PCR",
				negativeResult: true,
				holder: TestHolderIdentity(
					firstNameInitial: "H",
					lastNameInitial: "P",
					birthDay: "27",
					birthMonth: "5"
				)
			)
		)
	}
}
