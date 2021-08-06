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

	func test_subjectAlternativeNames_realLeaf() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let sans = sut.getSubjectAlternativeDNSNames(OpenSSLData.realLeaf) as? [String]

		// Then
		expect(sans).to(haveCount(1))
		expect(sans?.first) == "api-ct.bananenhalen.nl"
		expect(self.sut.validateSubjectAlternativeDNSName("api-ct.bananenhalen.nl", forCertificateData: OpenSSLData.realLeaf)) == true
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
