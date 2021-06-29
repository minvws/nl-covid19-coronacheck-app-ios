/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest

class CryptoUtilityTests: XCTestCase {

	var sut = CryptoUtility(signatureValidator: SignatureValidator())

	override func setUp() {

		super.setUp()
		sut = CryptoUtility(signatureValidator: SignatureValidator())
	}

	/// Test the signature 
	func testSignature() {

		// Given
		let data = "SomeData".data(using: .utf8)!
		let key = "SomeKey".data(using: .utf8)!

		// When
		let signature = sut.signature(forData: data, key: key)
		let hexBytes = signature.map { String(format: "%02hhx", $0) }

		// Then
		XCTAssertEqual("\(hexBytes.joined())", "a1118b1288eb8b20075f7b5d65d6809ad95f571856e3b831a43c39094f509beb")
	}

    let rootCertificateData = Data(base64Encoded: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURsVENDQW4yZ0F3SUJBZ0lVZmg1bXBLc25XdXJyVkZsK09mRkVHdHJFWHJBd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1dqRXJNQ2tHQTFVRUF3d2lVM1JoWVhRZ1pHVnlJRTVsWkdWeWJHRnVaR1Z1SUZKdmIzUWdRMEVnTFNCSApNekVlTUJ3R0ExVUVDZ3dWVTNSaFlYUWdaR1Z5SUU1bFpHVnliR0Z1WkdWdU1Rc3dDUVlEVlFRR0V3Sk9UREFlCkZ3MHlNVEEyTWprd09EUTJORGxhRncweU1UQTNNamt3T0RRMk5EbGFNRm94S3pBcEJnTlZCQU1NSWxOMFlXRjAKSUdSbGNpQk9aV1JsY214aGJtUmxiaUJTYjI5MElFTkJJQzBnUnpNeEhqQWNCZ05WQkFvTUZWTjBZV0YwSUdSbApjaUJPWldSbGNteGhibVJsYmpFTE1Ba0dBMVVFQmhNQ1Rrd3dnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCCkR3QXdnZ0VLQW9JQkFRQzlRWlJiRVNhb3h1NVJmVVFLSzlyOEtSNnJsUDhYNS9vZUtxSDVsa2UwdDRXVWcvNlAKYmFQcjMxS0Z3QWs1Wm5xd2NMWGI4d0lrcHpLelFWdmVybTVHMDUrRkE5V2RKRENBd3h5Z3hLTDZ4Z2o5ZTlmNwoyUHdZTVJtdU5IalhSaEwxK2ZNZk4wU0dkSVhJWFZHYVl1NWdwd3RaNnQ5aGRzaTdyY1hwbUlpRmg4WlZQU3FYCkZoNUx5UDdJYld1MWJTZU9iWlhZUjRLR0ZRZWthaWxDZUVjMWg1L1VQeFFZUWZzTlhQRW1wTFRGOU9JK0dwZXkKbGdaSVZONm15bm91Lzhhb3lVeVUzQlA3c2Flak93MVpZVCtuTDhUWEFUdlMrL3NCR3Z0bHAzeEY1RWM2TkhyaAp1aWQ0SnBxYzFEMWxOMDE3eDVUQWxGVzE2blZ0L1c5bld4VUxBZ01CQUFHalV6QlJNQjBHQTFVZERnUVdCQlN6CjAxRVhUOHIwbFdNZGIzVlI0MWFhdElwZVdEQWZCZ05WSFNNRUdEQVdnQlN6MDFFWFQ4cjBsV01kYjNWUjQxYWEKdElwZVdEQVBCZ05WSFJNQkFmOEVCVEFEQVFIL01BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQzUxZzFuRVN6TgpkcVpyNmJPMm1PRm5oUERMempaaVRHMSsra0V1cEFlUHhubCsvanEyQ3hhaHZkWXhtYUd0ZEZkMVhEdm9TTFFrCmRKMk1qMVhzM2tnOUdBWk9JK3U5ZExtS0JpYWtTMTJrV1BybGlubzMxRS85c2tNdWRiZnhPRWxLK0tQcWNSR1gKaDIxV28yd0hBMkZrOVV4ckJkcUR0ZWNRMTZ5TG5WdS9CTVU0Q1o2bUNkRzcycHlBRHp6b2dLMHNQeE9qdll3agpwMzVHNDZaYWxhTHh0R0RyYWozU0R1bjFWc0NWTWdsTnNSSzlZWUtuZDNrMkdYSEVSZ1BsbnhqTVk3N3d5amlmCjNzUmYyOWpMYmV2TGl4TURaMnlCM01mWDMwemVjNUdoR2RaQUE1YTJsOElSemdXaXl1bTNWMTNlSXV6UFhXT2wKbE1UYWpoSkF4Q0JnCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K" )!
    let authorityKeyIdentifier = Data([0x04, 0x14, /* keyID starts here: */ 0xF2, 0x88, 0x35, 0x9B, 0xD9, 0x4D, 0xF4, 0xF5, 0x92, 0x29, 0x7D, 0x59, 0xFE, 0x15, 0xF2, 0xAB, 0xF4, 0xD2, 0x56, 0xFB ])
    let payload = Data(base64Encoded: "WwogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMDYtMTdUMTA6MDA6MDAuMDAwKzAyMDAiLAogICJ1aXRzbGFnZGF0dW0iOiIyMDIwLTA2LTE3VDEwOjEwOjAwLjAwMCswMjAwIiwKICAicmVzdWx0YWF0IjoiTkVHQVRJRUYiLAogICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAiYWZzcHJhYWtJZCI6Mjc4NzE3Njh9LAogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMTEtMDhUMTA6MTU6MDAuMDAwKzAxMDAiLAogICAidWl0c2xhZ2RhdHVtIjoiMjAyMC0xMS0wOVQwNzo1MDozOS4wMDArMDEwMCIsCiAgICJyZXN1bHRhYXQiOiJQT1NJVElFRiIsCiAgICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAgImFmc3ByYWFrSWQiOjI1ODcxOTcyMTl9Cl0K" )!

    let wrongPayload = Data(base64Encoded: "WwogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMDYtMTdUMTA6MDA6MDAuMDAwKzAyMDAiLAogICJ1aXRzbGFnZGF0dW0iOiIyMDIwLTA2LTE3VDEwOjEwOjAwLjAwMCswMjAwIiwKICAicmVzdWx0YWF0IjoiTkVHQVRJRUYiLAogICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAiYWZzcHJhYWtJZCI6Mjc4NzE3Njh9LAogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMTEtMDhUMTA6MTU6MDAuMDAwKzAxMDAiLAogICAidWl0c2xhZ2RhdHVtIjoiMjAyMC0xMS0wOVQwNzo1MDozOS4wMDArMDEwMCIsCiAgICJyZXN1bHRhYXQiOiJQT1NJVElFRiIsCiAgICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAgImFmc3ByYWFrSWQiOjI1ODcxOTcyMTl9Cl1K" )!
    
    let signaturePKCS = Data(base64Encoded: "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" )!

    let signaturePPS =  Data(base64Encoded: "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" )!

    func testCMSSignature_padding_pkcs() {

         let openssl = OpenSSL()
        XCTAssertNotNil(openssl)
        XCTAssertEqual(true, openssl.validatePKCS7Signature(
                            signaturePKCS,
                        contentData: payload,
                        certificateData: rootCertificateData,
                        authorityKeyIdentifier: authorityKeyIdentifier,
                        requiredCommonNameContent: ".coronatester.n",
                        requiredCommonNameSuffix: ".nl"))
        XCTAssertEqual(false, openssl.validatePKCS7Signature(
                        signaturePKCS,
                    contentData: wrongPayload,
                    certificateData: rootCertificateData,
                    authorityKeyIdentifier: authorityKeyIdentifier,
                    requiredCommonNameContent: ".coronatester.n",
                    requiredCommonNameSuffix: ".nl"))
    }

    func testCMSSignature_padding_pss() {

        let openssl = OpenSSL()
        XCTAssertNotNil(openssl)

        XCTAssertEqual(true, openssl.validatePKCS7Signature(
                    signaturePPS,
                    contentData: payload,
                    certificateData: rootCertificateData,
                    authorityKeyIdentifier: authorityKeyIdentifier,
                    requiredCommonNameContent: ".coronatester.n",
                    requiredCommonNameSuffix: ".nl"))

        XCTAssertEqual(false, openssl.validatePKCS7Signature(
                    signaturePPS,
                    contentData: wrongPayload,
                    certificateData: rootCertificateData,
                    authorityKeyIdentifier: authorityKeyIdentifier,
                    requiredCommonNameContent: ".coronatester.n",
                    requiredCommonNameSuffix: ".nl"))

    }

    func testCMSSignature_test_pinning() {
        let openssl = OpenSSL()
       XCTAssertNotNil(openssl)

        XCTAssertEqual(false, openssl.validatePKCS7Signature(
                    signaturePKCS,
                    contentData: payload,
                    certificateData: rootCertificateData,
                    authorityKeyIdentifier: authorityKeyIdentifier,
                    requiredCommonNameContent: ".xx.n",
                    requiredCommonNameSuffix: ".nl"))

        XCTAssertEqual(false, openssl.validatePKCS7Signature(
                    signaturePKCS,
                    contentData: payload,
                    certificateData: rootCertificateData,
                    authorityKeyIdentifier: authorityKeyIdentifier,
                        requiredCommonNameContent: ".coronatester.n",
                    requiredCommonNameSuffix: ".xx"))

    }

    /// Test the hash
	func testSha256() {

		// Given
		let data = "SomeString".data(using: .utf8)!

		// When
		let sha = sut.sha256(data: data)

		// Then
		XCTAssertEqual(sha, "SHA256 digest: 80ed7fe2957fa688284716753d339d019d490d4589ac4999ec8827ef3f84be29")
	}
}
