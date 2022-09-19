/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class SignatureValidationFactoryTests: XCTestCase {
	
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
	}
	
	// MARK: Strategy none

	func test_securityCheckerNone_validate() {

		// Given
		let sut = SignatureValidationFactory().getSignatureValidator(.none)

		// When
		let result = sut.validate(signature: Data(), content: Data())

		// Then
		expect(result) == true
	}

	// MARK: Strategy config

	func test_securityCheckerConfig_validate_emptyData() {

		// Given
		let sut = SignatureValidationFactory().getSignatureValidator(.config)

		// When
		let result = sut.validate(signature: Data(), content: Data())

		// Then
		expect(result) == false
	}

	func test_securityCheckerConfig_validate_untrustedSigner() {

		// Given
		let sut = SignatureValidationFactory().getSignatureValidator(.config)

		// When
		let result = sut.validate(signature: OpenSSLData.signaturePKCS, content: OpenSSLData.payload)

		// Then
		expect(result) == false
	}

//	func test_securityCheckerConfig_validate_trustedSigner() {
//
//		// Given
//		let sut = SignatureValidationFactory().getSignatureValidator(.config)
//
//		// When
//		let result = sut.validate(signature: OpenSSLData.remoteConfigSignature, content: OpenSSLData.remoteConfigPayload)
//
//		// Then
//		expect(result) == true
//	}

	// MARK: Strategy data

	func test_securityCheckerData_validate_emptyData() {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.backendTLSCertificates = []
		let sut = SignatureValidationFactory().getSignatureValidator(.data)

		// When
		let result = sut.validate(signature: Data(), content: Data())

		// Then
		expect(result) == false
	}

	func test_securityCheckerData_validate_untrustedSigner() {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.backendTLSCertificates = []
		let sut = SignatureValidationFactory().getSignatureValidator(.data)

		// When
		let result = sut.validate(signature: OpenSSLData.signaturePKCS, content: OpenSSLData.payload)

		// Then
		expect(result) == false
	}

	// MARK: Strategy provider

	func test_securityCheckerProvider_validate_emptyData() {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.backendTLSCertificates = []
		let provider = EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiUrl: URL(string: "https://coronacheck.nl"),
			eventUrl: URL(string: "https://coronacheck.nl"),
			cmsCertificates: [OpenSSLData.providerCertificate],
			tlsCertificates: [OpenSSLData.providerCertificate],
			accessToken: nil,
			eventInformationAvailable: nil,
			usages: [.vaccination],
			providerAuthentication: [.manyAuthenticationExchange]
		)

		let sut = SignatureValidationFactory().getSignatureValidator(.provider(provider))

		// When
		let result = sut.validate(signature: Data(), content: Data())

		// Then
		expect(result) == false
	}

	func test_securityCheckerProvider_validate_untrustedSigner() {

		// Given
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.backendTLSCertificates = []
		let provider = EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiUrl: URL(string: "https://coronacheck.nl"),
			eventUrl: URL(string: "https://coronacheck.nl"),
			cmsCertificates: [OpenSSLData.providerCertificate],
			tlsCertificates: [OpenSSLData.providerCertificate],
			accessToken: nil,
			eventInformationAvailable: nil,
			usages: [.vaccination],
			providerAuthentication: [.manyAuthenticationExchange]
		)

		let sut = SignatureValidationFactory().getSignatureValidator(.provider(provider))

		// When
		let result = sut.validate(signature: OpenSSLData.signaturePKCS, content: OpenSSLData.payload)

		// Then
		expect(result) == false
	}

//	func test_securityCheckerProvider_validate_trustedSigner() {
//
//		// Given
//		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.backendTLSCertificates = []
//		let provider = EventFlow.EventProvider(
//			identifier: "CC",
//			name: "CoronaCheck",
//			unomiUrl: URL(string: "https://coronacheck.nl"),
//			eventUrl: URL(string: "https://coronacheck.nl"),
//			cmsCertificates: [OpenSSLData.providerCertificate],
//			tlsCertificates: [OpenSSLData.providerCertificate],
//			accessToken: nil,
//			eventInformationAvailable: nil,
//			usages: [.vaccination],
//			providerAuthentication: [.manyAuthenticationExchange]
//		)
//
//		let sut = SignatureValidationFactory().getSignatureValidator(.provider(provider))
//
//		// When
//		let result = sut.validate(signature: OpenSSLData.providerSignature, content: OpenSSLData.providerPayload)
//
//		// Then
//		expect(result) == true
//	}
}
