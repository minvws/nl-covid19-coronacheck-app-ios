/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
@testable import CTR
import Nimble

// swiftlint:disable:next type_name
class VaccinationAssessmentNotificationManagerTests: XCTestCase {

	/// Subject under test
	var sut: VaccinationAssessmentNotificationManager!
	private var environmentSpies: EnvironmentSpies!

	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		sut = VaccinationAssessmentNotificationManager()
	}

	func test_noAssessmentOrigin_noAssessmentEvent() {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedGreencardsWithUnexpiredOriginsResult = []
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = []
		
		// When
		let result = sut.hasVaccinationAssessmentEventButNoOrigin(now: now)
		
		// Then
		expect(result) == false
	}
	
	func test_withAssessmentOrigin_noAssessmentEvent() throws {
		
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		
		environmentSpies.walletManagerSpy.stubbedGreencardsWithUnexpiredOriginsResult = [greenCard]
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = []
		
		// When
		let result = sut.hasVaccinationAssessmentEventButNoOrigin(now: now)
		
		// Then
		expect(result) == false
	}

	func test_noAssessmentOrigin_withTestEvent() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedGreencardsWithUnexpiredOriginsResult = []
		let eventGroup = try XCTUnwrap(
			EventGroup.fakeEventGroup(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: EventMode.test,
				maxIssuedAt: now
			)
		)
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		let result = sut.hasVaccinationAssessmentEventButNoOrigin(now: now)
		
		// Then
		expect(result) == false
	}
	
	func test_noAssessmentOrigin_withValidAssessmentEvent() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedGreencardsWithUnexpiredOriginsResult = []
		let eventGroup = try XCTUnwrap(
			EventGroup.fakeEventGroup(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: EventMode.vaccinationassessment,
				maxIssuedAt: now
			)
		)
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		let result = sut.hasVaccinationAssessmentEventButNoOrigin(now: now)
		
		// Then
		expect(result) == true
	}

	func test_noAssessmentOrigin_withAlmostExpiredAssessmentEvent_twoHoursBeforeExpiration() throws {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.vaccinationAssessmentEventValidityDays = 14
		environmentSpies.walletManagerSpy.stubbedGreencardsWithUnexpiredOriginsResult = []
		let eventGroup = try XCTUnwrap(
			EventGroup.fakeEventGroup(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: EventMode.vaccinationassessment,
				maxIssuedAt: now
			)
		)
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		let result = sut.hasVaccinationAssessmentEventButNoOrigin(now: now.addingTimeInterval(((14 * 24) - 2) * hours)) // two hours before expiration
		
		// Then
		expect(result) == true
	}
	
	func test_noAssessmentOrigin_withAlmostExpiredAssessmentEvent_oneHourBeforeExpiration() throws {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.vaccinationAssessmentEventValidityDays = 14
		environmentSpies.walletManagerSpy.stubbedGreencardsWithUnexpiredOriginsResult = []
		let eventGroup = try XCTUnwrap(
			EventGroup.fakeEventGroup(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: EventMode.vaccinationassessment,
				maxIssuedAt: now
			)
		)
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		let result = sut.hasVaccinationAssessmentEventButNoOrigin(now: now.addingTimeInterval(((14 * 24) - 1) * hours)) // one hour before expiration
		
		// Then
		expect(result) == false
	}
	
	func test_noAssessmentOrigin_withExpiredAssessmentEvent_atExpiration() throws {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.vaccinationAssessmentEventValidityDays = 14
		environmentSpies.walletManagerSpy.stubbedGreencardsWithUnexpiredOriginsResult = []
		let eventGroup = try XCTUnwrap(
			EventGroup.fakeEventGroup(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: EventMode.vaccinationassessment,
				maxIssuedAt: now
			)
		)
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		let result = sut.hasVaccinationAssessmentEventButNoOrigin(now: now.addingTimeInterval(14 * 24 * hours))
		
		// Then
		expect(result) == false
	}
	
	func test_noAssessmentOrigin_withExpiredAssessmentEvent_oneDayLater() throws {
		
		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.vaccinationAssessmentEventValidityDays = 14
		environmentSpies.walletManagerSpy.stubbedGreencardsWithUnexpiredOriginsResult = []
		let eventGroup = try XCTUnwrap(
			EventGroup.fakeEventGroup(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: EventMode.vaccinationassessment,
				maxIssuedAt: now
			)
		)
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		let result = sut.hasVaccinationAssessmentEventButNoOrigin(now: now.addingTimeInterval(15 * days)) // one day after expiration
		
		// Then
		expect(result) == false
	}
	
	func test_withAssessmentOrigin_withValidAssessmentEvent() throws {
		
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		
		environmentSpies.walletManagerSpy.stubbedGreencardsWithUnexpiredOriginsResult = [greenCard]
		let eventGroup = try XCTUnwrap(
			EventGroup.fakeEventGroup(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: EventMode.vaccinationassessment,
				maxIssuedAt: now
			)
		)
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		let result = sut.hasVaccinationAssessmentEventButNoOrigin(now: now)
		
		// Then
		expect(result) == false
	}
}
