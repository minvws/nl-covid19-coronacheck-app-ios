/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (ContactInformationProvider, RemoteConfigManagingSpy) {
			
		let remoteConfigManagerSpy = RemoteConfigManagingSpy()
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		let sut = ContactInformationProvider(remoteConfigManager: remoteConfigManagerSpy)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, remoteConfigManagerSpy)
	}
	
	func test_properties_withContent() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
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
		expect(sut.phoneNumberLink) == "<a href=\"tel:TEST\">T E S T</a>"
		expect(sut.phoneNumberAbroadLink) == "<a href=\"tel:TEST2\">T E S T 2</a>"
		expect(sut.openingDays) == "maandag t/m dinsdag"
		expect(sut.startHour) == "07:00"
		expect(sut.endHour) == "08:00"
	}
	
	func test_properties_everyDay() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
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
		expect(sut.phoneNumberLink) == "<a href=\"tel:TEST\">T E S T</a>"
		expect(sut.phoneNumberAbroadLink) == "<a href=\"tel:TEST2\">T E S T 2</a>"
		expect(sut.openingDays) == "elke dag"
		expect(sut.startHour) == "07:00"
		expect(sut.endHour) == "08:00"
	}

	func test_properties_startDayOutOfScope() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
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
		expect(sut.phoneNumberLink) == "<a href=\"tel:TEST\">T E S T</a>"
		expect(sut.phoneNumberAbroadLink) == "<a href=\"tel:TEST2\">T E S T 2</a>"
		expect(sut.openingDays) == "zondag t/m donderdag"
		expect(sut.startHour) == "07:00"
		expect(sut.endHour) == "08:00"
	}
	
	func test_properties_endDayOutOfScope() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
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
		expect(sut.phoneNumberLink) == "<a href=\"tel:TEST\">T E S T</a>"
		expect(sut.phoneNumberAbroadLink) == "<a href=\"tel:TEST2\">T E S T 2</a>"
		expect(sut.openingDays) == "elke dag"
		expect(sut.startHour) == "07:00"
		expect(sut.endHour) == "08:00"
	}
	
	func test_properties_fallbackContent() {
		
		// Given
		let (sut, remoteConfigManagerSpy) = makeSUT()
		remoteConfigManagerSpy.stubbedStoredConfiguration.contactInformation = nil
		
		// When
		
		// Then
		expect(sut.phoneNumberLink) == "<a href=\"tel:0800-1421\">0800 - 1421</a>"
		expect(sut.phoneNumberAbroadLink) == "<a href=\"tel:+31707503720\">+31 70 750 37 20</a>"
		expect(sut.openingDays) == "elke dag"
		expect(sut.startHour) == "08:00"
		expect(sut.endHour) == "18:00"
	}
}
