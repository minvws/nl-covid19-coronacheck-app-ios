/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

final class UpdatedDisclosurePolicyFactoryTests: XCTestCase {
	
	private var environmentSpies: EnvironmentSpies!

	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
	}

	func test_content_0G() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreZeroDisclosurePoliciesEnabledResult = true
		
		// When
		let result = UpdatedDisclosurePolicyFactory().create()
		
		// Then
		expect(result).to(haveCount(1))
		expect(result[0].tagline) == L.general_newintheapp()
		expect(result[0].title) == L.holder_newintheapp_content_onlyInternationalCertificates_0G_title()
		expect(result[0].content) == L.holder_newintheapp_content_onlyInternationalCertificates_0G_body()
		expect(result[0].image) == I.onboarding.validity()
		expect(result[0].imageBackgroundColor) == nil
		expect(result[0].nextButtonTitle) == nil
	}
	
	func test_content_1G() {

		// Given
		environmentSpies.userSettingsSpy.stubbedLastKnownConfigDisclosurePolicy = ["3G"] // not 0g, as that's special-cased.
		environmentSpies.featureFlagManagerSpy.stubbedIs1GExclusiveDisclosurePolicyEnabledResult = true

		// When
		let result = UpdatedDisclosurePolicyFactory().create()

		// Then
		expect(result).to(haveCount(1))
		expect(result[0].tagline) == L.general_newpolicy()
		expect(result[0].title) == L.holder_newintheapp_content_only1G_title()
		expect(result[0].content) == L.holder_newintheapp_content_only1G_body()
		expect(result[0].image) == I.disclosurePolicy.newInTheApp()
		expect(result[0].imageBackgroundColor) == nil
		expect(result[0].nextButtonTitle) == nil
	}
	
	func test_content_1G_from_0G() {

		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GExclusiveDisclosurePolicyEnabledResult = true

		// When
		let result = UpdatedDisclosurePolicyFactory().create()

		// Then
		expect(result).to(haveCount(2))
		expect(result[0].tagline) == L.general_newintheapp()
		expect(result[0].title) == L.holder_newintheapp_content_dutchAndInternationalCertificates_title()
		expect(result[0].content) == L.holder_newintheapp_content_dutchAndInternationalCertificates_body()
		expect(result[0].image) == I.disclosurePolicy.dutchAndInternationalQRCards()
		expect(result[0].imageBackgroundColor) == nil
		expect(result[0].nextButtonTitle) == nil
		
		expect(result[1].tagline) == L.general_newpolicy()
		expect(result[1].title) == L.holder_newintheapp_content_only1G_title()
		expect(result[1].content) == L.holder_newintheapp_content_only1G_body()
		expect(result[1].image) == I.disclosurePolicy.newInTheApp()
		expect(result[1].nextButtonTitle) == L.holder_newintheapp_content_dutchAndInternationalCertificates_button_toMyCertificates()
		expect(result[1].imageBackgroundColor) == nil
	}

	func test_content_3G() {

		// Given
		environmentSpies.userSettingsSpy.stubbedLastKnownConfigDisclosurePolicy = ["1G"] // not 0g, as that's special-cased.
		environmentSpies.featureFlagManagerSpy.stubbedIs3GExclusiveDisclosurePolicyEnabledResult = true

		// When
		let result = UpdatedDisclosurePolicyFactory().create()

		// Then
		expect(result).to(haveCount(1))
		expect(result[0].tagline) == L.general_newpolicy()
		expect(result[0].title) == L.holder_newintheapp_content_only3G_title()
		expect(result[0].content) == L.holder_newintheapp_content_only3G_body()
		expect(result[0].image) == I.disclosurePolicy.newInTheApp()
		expect(result[0].imageBackgroundColor) == nil
		expect(result[0].nextButtonTitle) == nil
	}

	func test_content_3G_from_0G() {

		// Given
		environmentSpies.userSettingsSpy.stubbedLastKnownConfigDisclosurePolicy = [] // special case
		environmentSpies.featureFlagManagerSpy.stubbedIs3GExclusiveDisclosurePolicyEnabledResult = true

		// When
		let result = UpdatedDisclosurePolicyFactory().create()

		// Then
		expect(result).to(haveCount(2))
		expect(result[0].tagline) == L.general_newintheapp()
		expect(result[0].title) == L.holder_newintheapp_content_dutchAndInternationalCertificates_title()
		expect(result[0].content) == L.holder_newintheapp_content_dutchAndInternationalCertificates_body()
		expect(result[0].image) == I.disclosurePolicy.dutchAndInternationalQRCards()
		expect(result[0].imageBackgroundColor) == nil
		expect(result[0].nextButtonTitle) == nil
		
		expect(result[1].tagline) == L.general_newpolicy()
		expect(result[1].title) == L.holder_newintheapp_content_only3G_title()
		expect(result[1].content) == L.holder_newintheapp_content_only3G_body()
		expect(result[1].image) == I.disclosurePolicy.newInTheApp()
		expect(result[1].nextButtonTitle) == L.holder_newintheapp_content_dutchAndInternationalCertificates_button_toMyCertificates()
		expect(result[1].imageBackgroundColor) == nil
	}

	func test_content_1GWith3G() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreBothDisclosurePoliciesEnabledResult = true
		environmentSpies.userSettingsSpy.stubbedLastKnownConfigDisclosurePolicy = ["1G"] // not 0g, as that's special-cased.

		// When
		let result = UpdatedDisclosurePolicyFactory().create()

		// Then
		expect(result).to(haveCount(1))
		expect(result[0].tagline) == L.general_newpolicy()
		expect(result[0].title) == L.holder_newintheapp_content_3Gand1G_title()
		expect(result[0].content) == L.holder_newintheapp_content_3Gand1G_body()
		expect(result[0].image) == I.disclosurePolicy.newInTheApp()
		expect(result[0].imageBackgroundColor) == nil
		expect(result[0].nextButtonTitle) == nil
	}
	
	func test_content_1GWith3G_from_0G() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreBothDisclosurePoliciesEnabledResult = true

		// When
		let result = UpdatedDisclosurePolicyFactory().create()

		// Then
		expect(result).to(haveCount(2))
		expect(result[0].tagline) == L.general_newintheapp()
		expect(result[0].title) == L.holder_newintheapp_content_dutchAndInternationalCertificates_title()
		expect(result[0].content) == L.holder_newintheapp_content_dutchAndInternationalCertificates_body()
		expect(result[0].image) == I.disclosurePolicy.dutchAndInternationalQRCards()
		expect(result[0].imageBackgroundColor) == nil
		expect(result[0].nextButtonTitle) == nil
		
		expect(result[1].tagline) == L.general_newpolicy()
		expect(result[1].title) == L.holder_newintheapp_content_3Gand1G_title()
		expect(result[1].content) == L.holder_newintheapp_content_3Gand1G_body()
		expect(result[1].image) == I.disclosurePolicy.newInTheApp()
		expect(result[1].nextButtonTitle) == L.holder_newintheapp_content_dutchAndInternationalCertificates_button_toMyCertificates()
		expect(result[1].imageBackgroundColor) == nil
	}

	func test_content_noPolicy() {
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedIs1GExclusiveDisclosurePolicyEnabledResult = false
		environmentSpies.featureFlagManagerSpy.stubbedIs3GExclusiveDisclosurePolicyEnabledResult = false
		environmentSpies.featureFlagManagerSpy.stubbedAreBothDisclosurePoliciesEnabledResult = false

		// When
		let result = UpdatedDisclosurePolicyFactory().create()

		// Then
		expect(result).to(beEmpty())
	}
}
