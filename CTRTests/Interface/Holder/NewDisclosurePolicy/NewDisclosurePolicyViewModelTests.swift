/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

final class NewDisclosurePolicyViewModelTests: XCTestCase {
	
	private var sut: NewDisclosurePolicyViewModel?

	private var coordinatorSpy: HolderCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!

	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = HolderCoordinatorDelegateSpy()
	}
	
	func test_content_1G() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GExclusiveDisclosurePolicyEnabledResult = true
		
		// When
		sut = .init(coordinator: coordinatorSpy)

		// Then
		expect(self.sut?.tagline) == L.general_newpolicy()
		expect(self.sut?.title) == L.holder_newintheapp_content_only1G_title()
		expect(self.sut?.content) == L.holder_newintheapp_content_only1G_body()
		expect(self.sut?.image) == I.disclosurePolicy.newInTheApp()
	}
	
	func test_content_3G() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs3GExclusiveDisclosurePolicyEnabledResult = true
		
		// When
		sut = .init(coordinator: coordinatorSpy)
		
		// Then
		expect(self.sut?.tagline) == L.general_newpolicy()
		expect(self.sut?.title) == L.holder_newintheapp_content_only3G_title()
		expect(self.sut?.content) == L.holder_newintheapp_content_only3G_body()
		expect(self.sut?.image) == I.disclosurePolicy.newInTheApp()
	}
	
	func test_content_1GWith3G() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreBothDisclosurePoliciesEnabledResult = true
		
		// When
		sut = .init(coordinator: coordinatorSpy)
		
		// Then
		expect(self.sut?.tagline) == L.general_newintheapp()
		expect(self.sut?.title) == L.holder_newintheapp_content_3Gand1G_title()
		expect(self.sut?.content) == L.holder_newintheapp_content_3Gand1G_body()
		expect(self.sut?.image) == I.disclosurePolicy.newInTheApp()
	}
	
	func test_content_noPolicy() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GExclusiveDisclosurePolicyEnabledResult = false
		environmentSpies.featureFlagManagerSpy.stubbedIs3GExclusiveDisclosurePolicyEnabledResult = false
		environmentSpies.featureFlagManagerSpy.stubbedAreBothDisclosurePoliciesEnabledResult = false
		
		// When
		sut = .init(coordinator: coordinatorSpy)
		
		// Then
		expect(self.sut).to(beNil())
	}
	
	func test_dismiss() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreBothDisclosurePoliciesEnabledResult = true
		sut = .init(coordinator: coordinatorSpy)
		
		// When
		sut?.dismiss()
		
		// Then
		expect(self.coordinatorSpy.invokedDismiss) == true
	}
}
