/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import XCTest
import Nimble

class OpenSSLTests: XCTestCase {

	var sut = OpenSSL()
	let testBundle = Bundle(for: OpenSSLTests.self)

	override func setUp() {

		super.setUp()
		sut = OpenSSL()
	}

	let authorityKeyIdentifier = Data([0x04, 0x14, /* keyID starts here: */ 0x4E, 0x00, 0x9C, 0x47, 0x62, 0x93, 0x2B, 0x7C, 0x27, 0xF7, 0x4A, 0xB5, 0x7F, 0x3A, 0xD6, 0x1F, 0xDA, 0xC8, 0xBA, 0xBF ])

	let deepAuthorityKeyIdentifier = Data([0x04, 0x14, /* keyID starts here: */ 0xA9, 0x2E, 0x01, 0x36, 0x33, 0x4D, 0x9E, 0xBE, 0x33, 0xF4, 0x30, 0x9E, 0x4C, 0x16, 0xDE, 0x61, 0x76, 0xDC, 0x96, 0x48])

	let noCommonNameAuthorityKeyIdentifier = Data([0x04, 0x14, /* keyID starts here: */ 0x43, 0x84, 0x4c, 0xb7, 0x6c, 0xb1, 0x22, 0x7e, 0x28, 0xb0, 0x2c, 0x27, 0xbf, 0xab, 0x20, 0xd6, 0x6f, 0x53, 0xba, 0x80 ])

	let payload = Data(base64Encoded: "WwogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMDYtMTdUMTA6MDA6MDAuMDAwKzAyMDAiLAogICJ1aXRzbGFnZGF0dW0iOiIyMDIwLTA2LTE3VDEwOjEwOjAwLjAwMCswMjAwIiwKICAicmVzdWx0YWF0IjoiTkVHQVRJRUYiLAogICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAiYWZzcHJhYWtJZCI6Mjc4NzE3Njh9LAogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMTEtMDhUMTA6MTU6MDAuMDAwKzAxMDAiLAogICAidWl0c2xhZ2RhdHVtIjoiMjAyMC0xMS0wOVQwNzo1MDozOS4wMDArMDEwMCIsCiAgICJyZXN1bHRhYXQiOiJQT1NJVElFRiIsCiAgICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAgImFmc3ByYWFrSWQiOjI1ODcxOTcyMTl9Cl0K" )!

	let wrongPayload = Data(base64Encoded: "WwogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMDYtMTdUMTA6MDA6MDAuMDAwKzAyMDAiLAogICJ1aXRzbGFnZGF0dW0iOiIyMDIwLTA2LTE3VDEwOjEwOjAwLjAwMCswMjAwIiwKICAicmVzdWx0YWF0IjoiTkVHQVRJRUYiLAogICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAiYWZzcHJhYWtJZCI6Mjc4NzE3Njh9LAogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMTEtMDhUMTA6MTU6MDAuMDAwKzAxMDAiLAogICAidWl0c2xhZ2RhdHVtIjoiMjAyMC0xMS0wOVQwNzo1MDozOS4wMDArMDEwMCIsCiAgICJyZXN1bHRhYXQiOiJQT1NJVElFRiIsCiAgICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAgImFmc3ByYWFrSWQiOjI1ODcxOTcyMTl9Cl1K" )!

	// Use sign.sh to generate this signature (rsa_padding_mode: pkcs1)
	let signaturePKCS = Data(base64Encoded: "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")!

	// Use sign.sh to generate this signature (rsa_padding_mode: pss)
	let signaturePPS = Data(base64Encoded: "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")!

	let signatureNoCommonName = Data(base64Encoded: "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")!

	// use long-chain.sh to generate this signature
	let deepSignature = Data(base64Encoded: "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")!

	// MARK: - Signature
/*
	func testCMSSignature_padding_pkcs_validPayload() throws {

		// Use gen-fake-pki-overheid.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: payload,
			certificateData: certificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == true
	}
*/
	func testCMSSignature_padding_pkcs_wrongPayload() throws {

		// Use gen-fake-pki-overheid.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: wrongPayload,
			certificateData: certificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == false
	}
/*
	func testCMSSignature_padding_pss_validPayload() throws {

		// Use gen-fake-pki-overheid.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePPS,
			contentData: payload,
			certificateData: certificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == true
	}
*/
	func testCMSSignature_padding_pss_wrongPayload() throws {

		// Use gen-fake-pki-overheid.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			wrongPayload,
			contentData: payload,
			certificateData: certificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == false
	}

	func testCMSSignature_test_pinning_wrongCommonName() throws {

		// Use gen-fake-pki-overheid.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: payload,
			certificateData: certificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".coronacheck.nl"
		)

		// Then
		expect(validation) == false
	}

	func testCMSSignature_test_pinning_commonNameAsPartOfDomain() throws {

		// Use gen-fake-pki-overheid.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: payload,
			certificateData: certificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl.xx.nl"
		)

		// Then
		expect(validation) == false
	}
/*
	func testCMSSignature_test_pinning_emptyCommonName() throws {

		// Use gen-fake-pki-overheid.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: payload,
			certificateData: certificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ""
		)

		// Then
		expect(validation) == true
	}

	func testCMSSignature_test_pinning_emptyAuthorityKeyIdentifier() throws {

		// Use gen-fake-pki-overheid.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: payload,
			certificateData: certificateData,
			authorityKeyIdentifier: nil,
			requiredCommonNameContent: "coronatester.nl"
		)

		// Then
		expect(validation) == true
	}

	func testCMSSignature_test_pinning_emptyAuthorityKeyIdentifier_emptyCommonName() throws {

		// Use gen-fake-pki-overheid.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: payload,
			certificateData: certificateData,
			authorityKeyIdentifier: nil,
			requiredCommonNameContent: ""
		)

		// Then
		expect(validation) == true
	}

	func testCMSSignature_verydeep() throws {

		// Use long-chain.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certDeepChain", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			deepSignature,
			contentData: payload,
			certificateData: certificateData,
			authorityKeyIdentifier: deepAuthorityKeyIdentifier,
			requiredCommonNameContent: "leaf.nl"
		)

		// Then
		expect(validation) == true
	}
*/
	func testCMSSignature_invalidAuthorityKeyIdentifier() throws {

		// Use long-chain.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certDeepChain", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validatePKCS7Signature(
			deepSignature,
			contentData: payload,
			certificateData: certificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
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
			signatureNoCommonName,
			contentData: payload,
			certificateData: certificateData,
			authorityKeyIdentifier: noCommonNameAuthorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester..nl"
		)

		// Then
		expect(validation) == false
	}
}
