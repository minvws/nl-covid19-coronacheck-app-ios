/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckTest
@testable import CTR

final class EventGroupCacheTests: XCTestCase {
	
	var sut: EventGroupCache!
	var environmentalSpies: EnvironmentSpies!
	
	override func setUp() {
		
		super.setUp()
		environmentalSpies = setupEnvironmentSpies()
		sut = EventGroupCache()
	}
	
	// MARK: - Identity Information
	
	func test_getEventResultWrapper_noEvent() {
		
		// Given
		
		// When
		let wrapper = sut.getEventResultWrapper("test")
		
		// Then
		expect(wrapper) == nil
		expect(self.sut.wrapperCache.values).to(beEmpty())
	}
	
	func test_getEventResultWrapper_withEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(
			EventGroup.createEventGroup(
				dataStoreManager: environmentalSpies.dataStoreManager,
				wrapper: EventFlow.EventResultWrapper.fakeBoosterResultWrapper
			)
		)
		environmentalSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		let wrapper = sut.getEventResultWrapper(eventGroup.uniqueIdentifier)
		
		// Then
		expect(wrapper) == EventFlow.EventResultWrapper.fakeBoosterResultWrapper
		expect(self.environmentalSpies.walletManagerSpy.invokedListEventGroups) == true
		expect(self.sut.wrapperCache.values).to(haveCount(1))
	}
	
	func test_getEventResultWrapper_withEvent_fromCache() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(
			EventGroup.createEventGroup(
				dataStoreManager: environmentalSpies.dataStoreManager,
				wrapper: EventFlow.EventResultWrapper.fakeBoosterResultWrapper
			)
		)
		sut.wrapperCache[eventGroup.uniqueIdentifier] = EventFlow.EventResultWrapper.fakeBoosterResultWrapper
		
		// When
		let wrapper = sut.getEventResultWrapper(eventGroup.uniqueIdentifier)
		
		// Then
		expect(wrapper) == EventFlow.EventResultWrapper.fakeBoosterResultWrapper
		expect(self.environmentalSpies.walletManagerSpy.invokedListEventGroups) == false
		expect(self.sut.wrapperCache.values).to(haveCount(1))
	}
	
	func test_getEUCreditialAttributes_noEvent() {
		
		// Given
		
		// When
		let wrapper = sut.getEUCreditialAttributes("test")
		
		// Then
		expect(wrapper) == nil
		expect(self.sut.euCredentialAttributesCache.values).to(beEmpty())
	}
	
	func test_ggetEUCreditialAttributes_withEvent() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(
			EventGroup.createDCCEventGroup(
				dataStoreManager: environmentalSpies.dataStoreManager,
				credential: CouplingManager.boosterDCC,
				couplingCode: CouplingManager.boosterCouplingCode
			)
		)
		environmentalSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentalSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()
		
		// When
		let wrapper = sut.getEUCreditialAttributes(eventGroup.uniqueIdentifier)
		
		// Then
		expect(wrapper) == EuCredentialAttributes.fakeVaccination()
		expect(self.environmentalSpies.walletManagerSpy.invokedListEventGroups) == true
		expect(self.environmentalSpies.cryptoManagerSpy.invokedReadEuCredentials) == true
		expect(self.sut.euCredentialAttributesCache.values).to(haveCount(1))
	}
	
	func test_ggetEUCreditialAttributes_withEvent_fromCache() throws {
		
		// Given
		let eventGroup = try XCTUnwrap(
			EventGroup.createDCCEventGroup(
				dataStoreManager: environmentalSpies.dataStoreManager,
				credential: CouplingManager.boosterDCC,
				couplingCode: CouplingManager.boosterCouplingCode
			)
		)
		
		sut.euCredentialAttributesCache[eventGroup.uniqueIdentifier] = EuCredentialAttributes.fakeVaccination()
		
		// When
		let wrapper = sut.getEUCreditialAttributes(eventGroup.uniqueIdentifier)
		
		// Then
		expect(wrapper) == EuCredentialAttributes.fakeVaccination()
		expect(self.environmentalSpies.walletManagerSpy.invokedListEventGroups) == false
		expect(self.environmentalSpies.cryptoManagerSpy.invokedReadEuCredentials) == false
		expect(self.sut.euCredentialAttributesCache.values).to(haveCount(1))
	}
	
}
