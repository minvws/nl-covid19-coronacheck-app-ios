/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import XCTest
import Nimble

class OpenSSLSANTests: XCTestCase {

	var sut = OpenSSL()
	let testBundle = Bundle(for: OpenSSLSANTests.self)

	override func setUp() {

		super.setUp()
		sut = OpenSSL()
	}

	// MARK: - Subject Alternative Name

	func test_subjectAlternativeNames_realLeaf() throws {

		// Chain that is identical in subjectKeyIdentifier, issuerIdentifier, etc
		// to a real one - but fake from the root down.
		//
		// See the Scripts directory:
		//  gen_fake_bananen.sh         - takes real chain and makes a fake one from it.
		//  gen_fake_cms_signed_json.sh - uses that to sign a bit of json.
		//  gen_code.pl                 - generates below hardcoded data.
		//
		// For the scripts that have generated below.
		//
		// File:       : 1002.real
		// SHA256 (DER): 19:C4:79:A1:D9:E9:BD:B3:D7:38:E8:41:45:70:16:FB:D8:15:C0:6B:71:96:12:F7:00:9A:1A:C7:E1:9B:F3:53
		// Subject     : CN = api-ct.bananenhalen.nl
		// Issuer      : C = US, O = Let's Encrypt, CN = R3
		//

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certRealLeaf", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let sans = sut.getSubjectAlternativeDNSNames(certificateData) as? [String]

		// Then
		expect(sans).to(haveCount(1))
		expect(sans?.first) == "api-ct.bananenhalen.nl"
		expect(self.sut.validateSubjectAlternativeDNSName("api-ct.bananenhalen.nl", forCertificateData: certificateData)) == true
	}

	func test_subjectAlternativeNames_fakeLeaf() throws {

		// Bizarre cert with odd extensions.
		// Regenerate with openssl req -new -x509 -subj /CN=foo/ \
		//      -addext "subjectAltName=otherName:foodofoo, otherName:1.2.3.4;UTF8,DNS:test1,DNS:test2,email:fo@bar,IP:1.2.3.4"  \
		//      -nodes -keyout /dev/null |\
		//            openssl x509 | pbcopy
		//

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certWithEmailAndIP", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let sans = sut.getSubjectAlternativeDNSNames(certificateData) as? [String]

		// Then
		expect(sans).to(haveCount(2))
		// check that we skip the IP, otherName and email entry.
		expect(sans).to(contain("test1"))
		expect(sans).to(contain("test2"))
		expect(sans).toNot(contain("1.2.3.4"))

		// OpenSSL seems to keep the order the same.
		expect(sans?.first) == "test1"
		expect(sans?.last) == "test2"

		expect(self.sut.validateSubjectAlternativeDNSName("test1", forCertificateData: certificateData)) == true
		expect(self.sut.validateSubjectAlternativeDNSName("test2", forCertificateData: certificateData)) == true
		// check that we do not see the non DNS entries. IP address is a bit of an edge case. Perhaps
		// we should allow that to match.
		expect(self.sut.validateSubjectAlternativeDNSName("fo@bar", forCertificateData: certificateData)) == false
	}

	func test_subjectAlternativeNames_certWithSanRightAndCNWrong() throws {

		// We have one case were the CN contains something like TestCentre 1234 and
		// the subjectAlternativeName contains testcenter.nl. So a pure CN match fails.
		//
		// Regenerate with openssl req -new -x509 -subj /CN=Foobar Center 100/ \
		//      -addext "subjectAltName=DNS:foobar.nl,DNS:someothercustomer.com"  \
		//      -nodes -keyout /dev/null |\
		//            openssl x509 | pbcopy
		//

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certWithSanRightAndCNWrong", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let result = sut.validateSubjectAlternativeDNSName("foobar.nl", forCertificateData: certificateData)

		// Then
		expect(result) == false
	}

	func test_subjectAlternativeNames_certWithCNfakeright() throws {

		// Example of a cert we should not let pass - even though it looks good.
		//
		// Regenerate with openssl req -new -x509 -subj /CN=foobar.nl/ \
		//      -addext "subjectAltName=DNS:certainlynotfoobar.nl,DNS:someothercustomer.com"  \
		//      -nodes -keyout /dev/null |\
		//            openssl x509 | pbcopy

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certWithCNfakeright", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let result = sut.validateSubjectAlternativeDNSName("foobar.nl", forCertificateData: certificateData)

		// Then
		expect(result) == false
	}

	func test_subjectAlternativeNames_certWithCNrightAndNoRelevantSAN() throws {

		// Regenerate with openssl req -new -x509 -subj /CN=foobar.nl/ \
		//      -addext "subjectAltName=IP:123.12.1.1"  \
		//      -nodes -keyout /dev/null |\
		//            openssl x509 | pbcopy

		// Given
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: "certWithCNrightAndNoRelevantSAN", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let result = sut.validateSubjectAlternativeDNSName("foobar.nl", forCertificateData: certificateData)

		// Then
		expect(result) == false
	}
}
