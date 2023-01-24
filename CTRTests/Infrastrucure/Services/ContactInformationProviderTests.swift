/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import CTR
@testable import Transport
@testable import Shared
import XCTest
import Nimble

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
		expect(self.sut.startDay) == "maandag"
		expect(self.sut.startHour) == "07:00"
		expect(self.sut.endDay) == "dinsdag"
		expect(self.sut.endHour) == "08:00"
	}
	
	func test_properties_fallbackContent() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.contactInformation = nil
		
		// When
		
		// Then
		expect(self.sut.phoneNumberLink) == "<a href=\"tel:0800-1421\">0800 - 1421</a>"
		expect(self.sut.phoneNumberAbroadLink) == "<a href=\"tel:+31707503720\">+31 70 750 37 20</a>"
		expect(self.sut.startDay) == "maandag"
		expect(self.sut.startHour) == "08:00"
		expect(self.sut.endDay) == "vrijdag"
		expect(self.sut.endHour) == "18:00"
	}
}
