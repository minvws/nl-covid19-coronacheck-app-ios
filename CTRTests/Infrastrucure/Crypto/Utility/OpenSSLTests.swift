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

class OpenSSLTests: XCTestCase {

	var sut = OpenSSL()
	let testBundle = Bundle(for: OpenSSLTests.self)

	override func setUp() {

		super.setUp()
		sut = OpenSSL()
	}
	
	func testCMSSignature_padding_pkcs_validPayload() throws {

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			OpenSSLData.signaturePKCS,
			contentData: OpenSSLData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: OpenSSLData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == true
	}

	func testCMSSignature_padding_pkcs_wrongPayload() throws {

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			OpenSSLData.signaturePKCS,
			contentData: OpenSSLData.wrongPayload,
			certificateData: certificateData,
			authorityKeyIdentifier: OpenSSLData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == false
	}

	func testCMSSignature_padding_pss_validPayload() throws {

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			OpenSSLData.signaturePSS,
			contentData: OpenSSLData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: OpenSSLData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == true
	}

	func testCMSSignature_padding_pss_wrongPayload() throws {

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			OpenSSLData.wrongPayload,
			contentData: OpenSSLData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: OpenSSLData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == false
	}

	func testCMSSignature_test_pinning_wrongCommonName() throws {

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			OpenSSLData.signaturePKCS,
			contentData: OpenSSLData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: OpenSSLData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronacheck.nl"
		)

		// Then
		expect(validation) == false
	}

	func testCMSSignature_test_pinning_commonNameAsPartOfDomain() throws {

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			OpenSSLData.signaturePKCS,
			contentData: OpenSSLData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: OpenSSLData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl.xx.nl"
		)

		// Then
		expect(validation) == false
	}

	func testCMSSignature_test_pinning_emptyCommonName() throws {

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			OpenSSLData.signaturePKCS,
			contentData: OpenSSLData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: OpenSSLData.authorityKeyIdentifier,
			requiredCommonNameContent: ""
		)

		// Then
		expect(validation) == true
	}

	func testCMSSignature_test_pinning_emptyAuthorityKeyIdentifier() throws {

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			OpenSSLData.signaturePKCS,
			contentData: OpenSSLData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: nil,
			requiredCommonNameContent: "coronatester.nl"
		)

		// Then
		expect(validation) == true
	}

	func testCMSSignature_test_pinning_emptyAuthorityKeyIdentifier_emptyCommonName() throws {

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			OpenSSLData.signaturePKCS,
			contentData: OpenSSLData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: nil,
			requiredCommonNameContent: ""
		)

		// Then
		expect(validation) == true
	}

	func testCMSSignature_verydeep() throws {

		// Use long-chain.sh to generate this certificate (0.pem -> certDeepChain.pem)

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certDeepChain", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			OpenSSLData.deepSignature,
			contentData: OpenSSLData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: OpenSSLData.deepAuthorityKeyIdentifier,
			requiredCommonNameContent: "leaf"
		)

		// Then
		expect(validation) == true
	}

	func testCMSSignature_invalidAuthorityKeyIdentifier() throws {

		// Use long-chain.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certDeepChain", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			OpenSSLData.deepSignature,
			contentData: OpenSSLData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: OpenSSLData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == false
	}

	func testCMSSignature_noCommonName() throws {

		// Use long-chain.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certWithoutCN", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			OpenSSLData.signatureNoCommonName,
			contentData: OpenSSLData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: OpenSSLData.noCommonNameAuthorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester..nl"
		)

		// Then
		expect(validation) == false
	}
	
	func test_getAuthorityKeyIdentifier_privateRoot_shouldBeNil() {
		
		// Given
		let certificateData = TrustConfiguration.sdNPrivateRootCertificate.getCertificateData()
		
		// When
		let key = sut.getAuthorityKeyIdentifier(forCertificate: certificateData)
		
		// Then
		expect(key) == nil
	}

	func test_getAuthorityKeyIdentifier_emptyData_shouldBeNil() {
		
		// Given
		let certificateData = Data()
		
		// When
		let key = sut.getAuthorityKeyIdentifier(forCertificate: certificateData)
		
		// Then
		expect(key) == nil
	}
	
	func test_getAuthorityKeyIdentifier_certRealLeaf_shouldMatch() throws {
		
		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certRealLeaf", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)
		
		let expectedAuthorityKeyIdentifier = Data([0x04, 0x14, /* keyID starts here: */ 0x14, 0x2e, 0xb3, 0x17, 0xb7, 0x58, 0x56, 0xcb, 0xae, 0x50, 0x09, 0x40, 0xe6, 0x1f, 0xaf, 0x9d, 0x8b, 0x14, 0xc2, 0xc6])

		// When
		let key = sut.getAuthorityKeyIdentifier(forCertificate: certificateData)
		
		// Then
		expect(key) == expectedAuthorityKeyIdentifier
	}
	
	func test_getCommonName_emptyData() {
		
		// Given
		let certificateData = Data()
		
		// When
		let name = sut.getCommonName(forCertificate: certificateData)
		
		// Then
		expect(name) == nil
	}
	
	func test_getCommonName_noCommonName() throws {
		
		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certWithoutCN", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)
		
		// When
		let name = sut.getCommonName(forCertificate: certificateData)
		
		// Then
		expect(name) == nil
	}
	
	func test_getCommonName_PrivateRootCA_G1() {
		
		// Given
		let certificateData = TrustConfiguration.sdNPrivateRoot
		
		// When
		let name = sut.getCommonName(forCertificate: certificateData)

		// Then
		expect(name) == "Staat der Nederlanden Private Root CA - G1"
	}
	
	func test_getCommonName_RootCA_G3() {
		
		// Given
		let certificateData = TrustConfiguration.sdNRootCAG3
		
		// When
		let name = sut.getCommonName(forCertificate: certificateData)
		
		// Then
		expect(name) == "Staat der Nederlanden Root CA - G3"
	}
	
	func test_getCommonName_EVRootCA() {
		
		// Given
		let certificateData = TrustConfiguration.sdNEVRootCA
		
		// When
		let name = sut.getCommonName(forCertificate: certificateData)
		
		// Then
		expect(name) == "Staat der Nederlanden EV Root CA"
	}
}
