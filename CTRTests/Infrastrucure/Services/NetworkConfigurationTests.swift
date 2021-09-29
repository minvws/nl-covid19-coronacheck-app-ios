/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import XCTest
import Nimble

class NetworkConfigurationTests: XCTestCase {

	private var sut: NetworkConfiguration!

	func test_development_accessTokens() {

		// Given
		sut = NetworkConfiguration.development

		// When
		let url = sut.vaccinationAccessTokensUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/access_tokens")) == true
	}

	func test_acceptance_accessTokens() {

		// Given
		sut = NetworkConfiguration.acceptance

		// When
		let url = sut.vaccinationAccessTokensUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/access_tokens")) == true
	}

	func test_production_accessTokens() {

		// Given
		sut = NetworkConfiguration.production

		// When
		let url = sut.vaccinationAccessTokensUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v5")) == true
		expect(url?.absoluteString.contains("holder/access_tokens")) == true
	}

	func test_development_prepareIssue() {

		// Given
		sut = NetworkConfiguration.development

		// When
		let url = sut.prepareIssueUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/prepare_issue")) == true
	}

	func test_acceptance_prepareIssue() {

		// Given
		sut = NetworkConfiguration.acceptance

		// When
		let url = sut.prepareIssueUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/prepare_issue")) == true
	}

	func test_production_prepareIssue() {

		// Given
		sut = NetworkConfiguration.production

		// When
		let url = sut.prepareIssueUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v5")) == true
		expect(url?.absoluteString.contains("holder/prepare_issue")) == true
	}

	func test_development_credentials() {

		// Given
		sut = NetworkConfiguration.development

		// When
		let url = sut.credentialUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/credentials")) == true
	}

	func test_acceptance_credentials() {

		// Given
		sut = NetworkConfiguration.acceptance

		// When
		let url = sut.credentialUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/credentials")) == true
	}

	func test_production_credentials() {

		// Given
		sut = NetworkConfiguration.production

		// When
		let url = sut.credentialUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v5")) == true
		expect(url?.absoluteString.contains("holder/credentials")) == true
	}

	func test_development_coupling() {

		// Given
		sut = NetworkConfiguration.development

		// When
		let url = sut.couplingUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/coupling")) == true
	}

	func test_acceptance_coupling() {

		// Given
		sut = NetworkConfiguration.acceptance

		// When
		let url = sut.couplingUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/coupling")) == true
	}

	func test_production_coupling() {

		// Given
		sut = NetworkConfiguration.production

		// When
		let url = sut.couplingUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v5")) == true
		expect(url?.absoluteString.contains("holder/coupling")) == true
	}

	func test_development_publicKeys() {

		// Given
		sut = NetworkConfiguration.development

		// When
		let url = sut.publicKeysUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/public_keys")) == true
	}

	func test_acceptance_publicKeys() {

		// Given
		sut = NetworkConfiguration.acceptance

		// When
		let url = sut.publicKeysUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/public_keys")) == true
	}

	func test_production_publicKeys() {

		// Given
		sut = NetworkConfiguration.production

		// When
		let url = sut.publicKeysUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v5")) == true
		expect(url?.absoluteString.contains("holder/public_keys")) == true
	}

	func test_development_remoteConfig() {

		// Given
		sut = NetworkConfiguration.development

		// When
		let url = sut.remoteConfigurationUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/config")) == true
	}

	func test_acceptance_remoteConfig() {

		// Given
		sut = NetworkConfiguration.acceptance

		// When
		let url = sut.remoteConfigurationUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/config")) == true
	}

	func test_production_remoteConfig() {

		// Given
		sut = NetworkConfiguration.production

		// When
		let url = sut.remoteConfigurationUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v5")) == true
		expect(url?.absoluteString.contains("holder/config")) == true
	}

	func test_development_providers() {

		// Given
		sut = NetworkConfiguration.development

		// When
		let url = sut.providersUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/config_providers")) == true
	}

	func test_acceptance_providers() {

		// Given
		sut = NetworkConfiguration.acceptance

		// When
		let url = sut.providersUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.acc.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v6")) == true
		expect(url?.absoluteString.contains("holder/config_providers")) == true
	}

	func test_production_providers() {

		// Given
		sut = NetworkConfiguration.production

		// When
		let url = sut.providersUrl

		// Then
		expect(url?.absoluteString.contains("https://holder-api.coronacheck.nl")) == true
		expect(url?.absoluteString.contains("v5")) == true
		expect(url?.absoluteString.contains("holder/config_providers")) == true
	}

}
