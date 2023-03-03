/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
@testable import Managers
@testable import Transport
@testable import Shared

class ContactInformationProviderTests: XCTestCase {
	
	private var sut: ContactInformationProvider!
	private var remoteConfigManagerSpy: RemoteConfigManagingSpy!
	
	override func setUp() {
		
		super.setUp()
		remoteConfigManagerSpy = RemoteConfigManagingSpy()
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		sut = ContactInformationProvider(remoteConfigManager: remoteConfigManagerSpy)
	}
	
	func test_properties_withContent() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.contactInformation = ContactInformation(
			phoneNumber: "T E S T",
			phoneNumberAbroad: "T E S T 2",
			startDay: 1,
			startHour: "07:00",
			endDay: 2,
			endHour: "08:00"
		)
		
		// When
		
		// Then
		expect(self.sut.phoneNumberLink) == "<a href=\"tel:TEST\">T E S T</a>"
		expect(self.sut.phoneNumberAbroadLink) == "<a href=\"tel:TEST2\">T E S T 2</a>"
		expect(self.sut.openingDays) == "maandag t/m dinsdag"
		expect(self.sut.startHour) == "07:00"
		expect(self.sut.endHour) == "08:00"
	}
	
	func test_properties_everyDay() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.contactInformation = ContactInformation(
			phoneNumber: "T E S T",
			phoneNumberAbroad: "T E S T 2",
			startDay: 1,
			startHour: "07:00",
			endDay: 0,
			endHour: "08:00"
		)
		
		// When
		
		// Then
		expect(self.sut.phoneNumberLink) == "<a href=\"tel:TEST\">T E S T</a>"
		expect(self.sut.phoneNumberAbroadLink) == "<a href=\"tel:TEST2\">T E S T 2</a>"
		expect(self.sut.openingDays) == "elke dag"
		expect(self.sut.startHour) == "07:00"
		expect(self.sut.endHour) == "08:00"
	}

	func test_properties_startDayOutOfScope() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.contactInformation = ContactInformation(
			phoneNumber: "T E S T",
			phoneNumberAbroad: "T E S T 2",
			startDay: 1586,
			startHour: "07:00",
			endDay: 4,
			endHour: "08:00"
		)
		
		// When
		
		// Then
		expect(self.sut.phoneNumberLink) == "<a href=\"tel:TEST\">T E S T</a>"
		expect(self.sut.phoneNumberAbroadLink) == "<a href=\"tel:TEST2\">T E S T 2</a>"
		expect(self.sut.openingDays) == "zondag t/m donderdag"
		expect(self.sut.startHour) == "07:00"
		expect(self.sut.endHour) == "08:00"
	}
	
	func test_properties_endDayOutOfScope() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.contactInformation = ContactInformation(
			phoneNumber: "T E S T",
			phoneNumberAbroad: "T E S T 2",
			startDay: 1,
			startHour: "07:00",
			endDay: 158,
			endHour: "08:00"
		)
		
		// When
		
		// Then
		expect(self.sut.phoneNumberLink) == "<a href=\"tel:TEST\">T E S T</a>"
		expect(self.sut.phoneNumberAbroadLink) == "<a href=\"tel:TEST2\">T E S T 2</a>"
		expect(self.sut.openingDays) == "elke dag"
		expect(self.sut.startHour) == "07:00"
		expect(self.sut.endHour) == "08:00"
	}
	
	func test_properties_fallbackContent() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.contactInformation = nil
		
		// When
		
		// Then
		expect(self.sut.phoneNumberLink) == "<a href=\"tel:0800-1421\">0800 - 1421</a>"
		expect(self.sut.phoneNumberAbroadLink) == "<a href=\"tel:+31707503720\">+31 70 750 37 20</a>"
		expect(self.sut.openingDays) == "elke dag"
		expect(self.sut.startHour) == "08:00"
		expect(self.sut.endHour) == "18:00"
	}
}
