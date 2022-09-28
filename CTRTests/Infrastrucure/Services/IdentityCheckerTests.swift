/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR
@testable import Transport
@testable import Shared

class IdentityCheckerTests: XCTestCase {

	var sut: IdentityChecker!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()

		environmentSpies = setupEnvironmentSpies()
		sut = IdentityChecker()
	}

	// MARK: - Tests

	func test_noEventGroups_noRemoteEvents() {

		// Given

		// When
		let matched = sut.compare(eventGroups: [], with: [])

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

	func test_eventGroupV3_noRemoteEvents() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3Identity))

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3_remoteEventv3() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3Identity))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3Identity, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3_remoteEventV3Alternative() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3Identity))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternative, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == false
	}
	
	func test_eventGroupV3Alternative_remoteEventV3AlternativeLowercase() throws {
		
		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternativeLowerCase, signedResponse: nil)
		
		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])
		
		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Alternative_remoteEventv3() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3Identity, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == false
	}

	func test_eventGroupV3Alternative_remoteEventv3Alternative() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternative, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Diacritic_remoteEventv3Alternative() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityFirstNameWithDiacritic))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityAlternative, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Alternative_remoteEventv3Diacritic() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityAlternative))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityFirstNameWithDiacritic, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Diacritic_remoteEventv3Diacritic_identicalDiacritic() throws {

		// Given
		let eventGroup = try XCTUnwrap( createEventGroup(wrapper: .fakeWithV3IdentityFirstNameWithDiacritic))
		let remoteEventV3 = RemoteEvent(wrapper: .fakeWithV3IdentityFirstNameWithDiacritic, signedResponse: nil)

		// When
		let matched = sut.compare(eventGroups: [eventGroup], with: [remoteEventV3])

		// Then
		expect(matched) == true
	}

	func test_eventGroupV3Diacritic_remoteEventv3AlternativeDiacritic() throws {

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

	// MARK: - Helper

	private func createEventGroup(wrapper: EventFlow.EventResultWrapper) -> EventGroup? {

		var eventGroup: EventGroup?
		if let payloadData = try? JSONEncoder().encode(wrapper) {
		   let base64String = payloadData.base64EncodedString()
			let signedResponse = SignedResponse(payload: base64String, signature: "does not matter for this test")
			let context = environmentSpies.dataStoreManager.managedObjectContext()
			context.performAndWait {
				if let wallet = WalletModel.createTestWallet(managedContext: context),
				   let jsonData = try? JSONEncoder().encode(signedResponse) {
					eventGroup = EventGroupModel.create(
						type: EventMode.recovery,
						providerIdentifier: "CoronaCheck",
						expiryDate: nil,
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
			"-rool": "R",
			"Jan": "J"
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

			expect(tuple.firstNameInitial) == nil
		}
	}
}
