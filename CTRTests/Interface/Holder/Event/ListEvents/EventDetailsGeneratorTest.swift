/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import XCTest
import Nimble

class EventDetailsGeneratorTest: XCTestCase {

	private var mappingManagerSpy: MappingManagerSpy!
	private var remoteConfigManagerSpy: RemoteConfigManagingSpy!

	override func setUp() {

		super.setUp()
		remoteConfigManagerSpy = RemoteConfigManagingSpy(
			now: { now },
			userSettings: UserSettingsSpy(),
			reachability: ReachabilitySpy(),
			networkManager: NetworkSpy()
		)
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		mappingManagerSpy = MappingManagerSpy(remoteConfigManager: remoteConfigManagerSpy)
		Services.use(mappingManagerSpy)
	}

	override class func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}

	func testNegativeTestGenerator() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.negativeTestEvent
		mappingManagerSpy.stubbedGetTestManufacturerResult = "testNegativeTestGenerator"
		mappingManagerSpy.stubbedGetTestTypeResult = "Sneltest (RAT)"

		// When
		let details = NegativeTestDetailsGenerator.getDetails(identity: identity, event: event)

		// Then
		expect(details).to(haveCount(10))
		expect(details[0].value).to(beNil())
		expect(details[1].value) == "Check, Corona"
		expect(details[2].value) == "16 mei 2021"
		expect(details[3].value) == "Sneltest (RAT)"
		expect(details[4].value) == "Antigen Test"
		expect(details[5].value) == "donderdag 1 juli 02:00"
		expect(details[6].value) == "negatief (geen corona)"
		expect(details[7].value) == "GGD XL Factory"
		expect(details[8].value) == "testNegativeTestGenerator"
		expect(details[9].value) == "1234"
	}

	func testNegativeTestV2Generator() {

		// Given

		// When
		let details = NegativeTestV2DetailsGenerator.getDetails(testResult: TestResult.negativeResult)

		// Then
		expect(details).to(haveCount(5))
		expect(details[0].value) == "T D 12 DEC"
		expect(details[1].value) == "PCR"
		expect(details[2].value) == "vrijdag 1 januari 01:00"
		expect(details[3].value) == "negatief (geen corona)"
		expect(details[4].value) == "test"
	}

}
