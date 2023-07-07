/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckTest
@testable import CTR

class RemoteEventDetailsViewModelTests: XCTestCase {
	
	/// Subject under test
	private var sut: RemoteEventDetailsViewModel!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		
		environmentSpies = setupEnvironmentSpies()
	}
	
	func test_vaccination() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.vaccinationEvent
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationBrandResult = "Comirnaty (Pfizer)"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationTypeResult = "SARS-CoV-2 mRNA vaccine"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationManufacturerResult = "Biontech"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		let details = VaccinationDetailsGenerator.getDetails(identity: identity, event: event, providerIdentifier: "CC")
		
		// When
		sut = RemoteEventDetailsViewModel(
			title: "Title Vaccination",
			details: details,
			footer: "Footer Vaccination"
		)
		
		// Then
		expect(self.sut.title) == "Title Vaccination"
		expect(self.sut.footer) == "Footer Vaccination"
		expect(self.sut.details).to(haveCount(11))
	}
	
	func test_positiveTest() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.positiveTestEvent
		environmentSpies.mappingManagerSpy.stubbedGetTestManufacturerResult = "testPositiveTestGenerator"
		environmentSpies.mappingManagerSpy.stubbedGetTestTypeResult = "Sneltest (RAT)"
		let details = PositiveTestDetailsGenerator.getDetails(identity: identity, event: event)
		
		// When
		sut = RemoteEventDetailsViewModel(
			title: "Title Positive Test",
			details: details,
			footer: "Footer Positive Test"
		)
		
		// Then
		expect(self.sut.title) == "Title Positive Test"
		expect(self.sut.footer) == "Footer Positive Test"
		expect(self.sut.details).to(haveCount(10))
	}
	
	func test_positiveTest_withInvalidTags() {
		
		// Given
		let identity = EventFlow.Identity.identityWithTags
		let event = EventFlow.Event.positiveTestEvent
		environmentSpies.mappingManagerSpy.stubbedGetTestManufacturerResult = "<i>testPositiveTest<a/>Generator</i>"
		environmentSpies.mappingManagerSpy.stubbedGetTestTypeResult = "Sneltest (RAT)"
		let details = PositiveTestDetailsGenerator.getDetails(identity: identity, event: event)
		
		// When
		sut = RemoteEventDetailsViewModel(
			title: "Title Positive Test",
			details: details,
			footer: "Footer Positive Test"
		)
		
		// Then
		expect(self.sut.details[1].detail) == "Naam: <b>Check, Corona</b>"
		expect(self.sut.details[7].detail) == "Testproducent: <b>testPositiveTestGenerator</b>"
	}
}
