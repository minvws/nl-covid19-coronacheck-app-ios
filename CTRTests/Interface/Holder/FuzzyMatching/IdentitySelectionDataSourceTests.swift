/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import Transport

final class IdentitySelectionDataSourceTests: XCTestCase {
	
	var sut: IdentitySelectionDataSource!
	var cacheSpy: EventGroupCacheSpy!
	var environmentalSpies: EnvironmentSpies!
	
	override func setUp() {
		
		super.setUp()
		cacheSpy = EventGroupCacheSpy()
		environmentalSpies = setupEnvironmentSpies()
		sut = IdentitySelectionDataSource(cache: cacheSpy)
	}
	
	// MARK: - Identity Information
	
	func test_getIdentity_noIdentity() {
		
		// Given
		
		// When
		let identity = sut.getIdentity("test")
		
		// Then
		expect(identity) == nil
		expect(self.cacheSpy.invokedGetEventResultWrapper) == true
		expect(self.cacheSpy.invokedGetEUCreditialAttributes) == true
	}
	
	func test_getIdentity_withIdentity_fromWrapper() {
		
		// Given
		cacheSpy.stubbedGetEventResultWrapperResult = EventFlow.EventResultWrapper.fakeBoosterResultWrapper
		
		// When
		let identity = sut.getIdentity("test")
		
		// Then
		expect(identity) == EventFlow.Identity.fakeIdentity
		expect(self.cacheSpy.invokedGetEventResultWrapper) == true
		expect(self.cacheSpy.invokedGetEUCreditialAttributes) == false
	}
	
	func test_getIdentity_withIdentity_fromEUCredentials() {
		
		// Given
		cacheSpy.stubbedGetEUCreditialAttributesResult = EuCredentialAttributes.fakeVaccination()
		
		// When
		let identity = sut.getIdentity("test")
		
		// Then
		expect(identity) == EventFlow.Identity(
			infix: nil,
			firstName: "Check",
			lastName: "Corona",
			birthDateString: "2021-06-01"
		)
		expect(self.cacheSpy.invokedGetEventResultWrapper) == true
		expect(self.cacheSpy.invokedGetEUCreditialAttributes) == true
	}
	
	func test_getIdentityInformation_noItems() {
		
		// Given
		
		// When
		let tuples = sut.getIdentityInformation(matchingBlobIds: [["test"]])
		
		// Then
		expect(tuples).to(beEmpty())
	}
	
	func test_getIdentityInformation_fromWrapper() {
		
		// Given
		cacheSpy.stubbedGetEventResultWrapperResult = EventFlow.EventResultWrapper.fakeBoosterResultWrapper
		
		// When
		let tuples = sut.getIdentityInformation(matchingBlobIds: [["test"]])
		
		// Then
		expect(tuples).to(haveCount(1))
		expect(tuples.first?.blobIds) == ["test"]
		expect(tuples.first?.name) == "Check, Corona"
		expect(tuples.first?.eventCountInformation) == "1 vaccinatie"
	}
	
	func test_getIdentityInformation_fromWrapper_multipleEvents() {
		
		// Given
		cacheSpy.stubbedGetEventResultWrapperResult = EventFlow.EventResultWrapper.fakeMultipleEventsResultWrapper
		
		// When
		let tuples = sut.getIdentityInformation(matchingBlobIds: [["test"]])
		
		// Then
		expect(tuples).to(haveCount(1))
		expect(tuples.first?.blobIds) == ["test"]
		expect(tuples.first?.name) == "Check, Corona"
		expect(tuples.first?.eventCountInformation) == "1 vaccinatie en 3 testuitslagen en 1 vaccinatiebeoordeling"
	}
	
	func test_getIdentityInformation_fromEUCredentials() {
		
		// Given
		cacheSpy.stubbedGetEUCreditialAttributesResult = EuCredentialAttributes.fakeVaccination()
		
		// When
		let tuples = sut.getIdentityInformation(matchingBlobIds: [["test"]])
		
		// Then
		expect(tuples).to(haveCount(1))
		expect(tuples.first?.blobIds) == ["test"]
		expect(tuples.first?.name) == "Corona, Check"
		expect(tuples.first?.eventCountInformation) == "1 vaccinatie"
	}
	
	// MARK: Event Overview
	
	func test_getEventOverview_noEvents() {
		
		// Given
		
		// When
		let overview = sut.getEventOveriew(blobIds: ["test"])
		
		// Then
		expect(overview).to(beEmpty())
	}
	
	func test_getEventOverview_multipleEvents() {
		
		// Given
		cacheSpy.stubbedGetEventResultWrapperResult = EventFlow.EventResultWrapper.fakeMultipleEventsResultWrapper
		
		// When
		let overview = sut.getEventOveriew(blobIds: ["test"])
		
		// Then
		expect(overview).to(haveCount(5))
		expect(overview[0][0]) == "Vaccinatiebeoordeling"
		expect(overview[1][0]) == "Negatieve testuitslag"
		expect(overview[1][1]) == "Opgehaald bij CC"
		expect(overview[1][2]) == "1 juli 2021"
		expect(overview[2][0]) == "Herstelbewijs"
		expect(overview[2][1]) == "Opgehaald bij CC"
		expect(overview[2][2]) == "1 juli 2021"
		expect(overview[3][0]) == "Vaccinatie"
		expect(overview[3][1]) == "Opgehaald bij CC"
		expect(overview[3][2]) == "16 mei 2021"
		expect(overview[4][0]) == "Positieve testuitslag"
		expect(overview[4][1]) == "Opgehaald bij CC"
		expect(overview[4][2]) == "1 juli 2020"
	}
	
	func test_getEventOverview_vaccinationFromEUCredential() {
		
		// Given
		cacheSpy.stubbedGetEUCreditialAttributesResult = EuCredentialAttributes.fakeVaccination()
		
		// When
		let overview = sut.getEventOveriew(blobIds: ["test"])
		
		// Then
		expect(overview).to(haveCount(1))
		expect(overview[0][0]) == "Vaccinatie dosis 1/2"
		expect(overview[0][1]) == "Ingescand bewijs"
		expect(overview[0][2]) == "1 juni 2021"
	}
	
	func test_getEventOverview_recoveryFromEUCredential() {
		
		// Given
		cacheSpy.stubbedGetEUCreditialAttributesResult = EuCredentialAttributes.fakeRecovery
		
		// When
		let overview = sut.getEventOveriew(blobIds: ["test"])
		
		// Then
		expect(overview).to(haveCount(1))
		expect(overview[0][0]) == "Herstelbewijs"
		expect(overview[0][1]) == "Ingescand bewijs"
		expect(overview[0][2]) == "31 juli 2021"
	}
	
	func test_getEventOverview_negativeTestFromEUCredential() {
		
		// Given
		cacheSpy.stubbedGetEUCreditialAttributesResult = EuCredentialAttributes.fakeTest
		
		// When
		let overview = sut.getEventOveriew(blobIds: ["test"])
		
		// Then
		expect(overview).to(haveCount(1))
		expect(overview[0][0]) == "Negatieve testuitslag"
		expect(overview[0][1]) == "Ingescand bewijs"
		expect(overview[0][2]) == "31 juli 2021"
	}
	
	// MARK: - Cache proxy
	
	func test_getEventResultWrapper() {
		
		// Given
		cacheSpy.stubbedGetEventResultWrapperResult = EventFlow.EventResultWrapper.fakeBoosterResultWrapper
		
		// When
		let wrapper = sut.getEventResultWrapper("test")
		
		// Then
		expect(wrapper) == EventFlow.EventResultWrapper.fakeBoosterResultWrapper
		expect(self.cacheSpy.invokedGetEventResultWrapper) == true
		expect(self.cacheSpy.invokedGetEUCreditialAttributes) == false
	}
	
	func test_getEUCreditialAttributes() {
		
		// Given
		cacheSpy.stubbedGetEUCreditialAttributesResult = EuCredentialAttributes.fakeVaccination()
		
		// When
		let attributes = sut.getEUCreditialAttributes("test")
		
		// Then
		expect(attributes) == EuCredentialAttributes.fakeVaccination()
		expect(self.cacheSpy.invokedGetEventResultWrapper) == false
		expect(self.cacheSpy.invokedGetEUCreditialAttributes) == true
	}
}
