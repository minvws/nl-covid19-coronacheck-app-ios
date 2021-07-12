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

	override func setUp() {

		super.setUp()
		sut = OpenSSL()
	}

	let rootCertificateData = Data(base64Encoded: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURsVENDQW4yZ0F3SUJBZ0lVZmg1bXBLc25XdXJyVkZsK09mRkVHdHJFWHJBd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1dqRXJNQ2tHQTFVRUF3d2lVM1JoWVhRZ1pHVnlJRTVsWkdWeWJHRnVaR1Z1SUZKdmIzUWdRMEVnTFNCSApNekVlTUJ3R0ExVUVDZ3dWVTNSaFlYUWdaR1Z5SUU1bFpHVnliR0Z1WkdWdU1Rc3dDUVlEVlFRR0V3Sk9UREFlCkZ3MHlNVEEyTWprd09EUTJORGxhRncweU1UQTNNamt3T0RRMk5EbGFNRm94S3pBcEJnTlZCQU1NSWxOMFlXRjAKSUdSbGNpQk9aV1JsY214aGJtUmxiaUJTYjI5MElFTkJJQzBnUnpNeEhqQWNCZ05WQkFvTUZWTjBZV0YwSUdSbApjaUJPWldSbGNteGhibVJsYmpFTE1Ba0dBMVVFQmhNQ1Rrd3dnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCCkR3QXdnZ0VLQW9JQkFRQzlRWlJiRVNhb3h1NVJmVVFLSzlyOEtSNnJsUDhYNS9vZUtxSDVsa2UwdDRXVWcvNlAKYmFQcjMxS0Z3QWs1Wm5xd2NMWGI4d0lrcHpLelFWdmVybTVHMDUrRkE5V2RKRENBd3h5Z3hLTDZ4Z2o5ZTlmNwoyUHdZTVJtdU5IalhSaEwxK2ZNZk4wU0dkSVhJWFZHYVl1NWdwd3RaNnQ5aGRzaTdyY1hwbUlpRmg4WlZQU3FYCkZoNUx5UDdJYld1MWJTZU9iWlhZUjRLR0ZRZWthaWxDZUVjMWg1L1VQeFFZUWZzTlhQRW1wTFRGOU9JK0dwZXkKbGdaSVZONm15bm91Lzhhb3lVeVUzQlA3c2Flak93MVpZVCtuTDhUWEFUdlMrL3NCR3Z0bHAzeEY1RWM2TkhyaAp1aWQ0SnBxYzFEMWxOMDE3eDVUQWxGVzE2blZ0L1c5bld4VUxBZ01CQUFHalV6QlJNQjBHQTFVZERnUVdCQlN6CjAxRVhUOHIwbFdNZGIzVlI0MWFhdElwZVdEQWZCZ05WSFNNRUdEQVdnQlN6MDFFWFQ4cjBsV01kYjNWUjQxYWEKdElwZVdEQVBCZ05WSFJNQkFmOEVCVEFEQVFIL01BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQzUxZzFuRVN6TgpkcVpyNmJPMm1PRm5oUERMempaaVRHMSsra0V1cEFlUHhubCsvanEyQ3hhaHZkWXhtYUd0ZEZkMVhEdm9TTFFrCmRKMk1qMVhzM2tnOUdBWk9JK3U5ZExtS0JpYWtTMTJrV1BybGlubzMxRS85c2tNdWRiZnhPRWxLK0tQcWNSR1gKaDIxV28yd0hBMkZrOVV4ckJkcUR0ZWNRMTZ5TG5WdS9CTVU0Q1o2bUNkRzcycHlBRHp6b2dLMHNQeE9qdll3agpwMzVHNDZaYWxhTHh0R0RyYWozU0R1bjFWc0NWTWdsTnNSSzlZWUtuZDNrMkdYSEVSZ1BsbnhqTVk3N3d5amlmCjNzUmYyOWpMYmV2TGl4TURaMnlCM01mWDMwemVjNUdoR2RaQUE1YTJsOElSemdXaXl1bTNWMTNlSXV6UFhXT2wKbE1UYWpoSkF4Q0JnCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K" )!

	let authorityKeyIdentifier = Data([0x04, 0x14, /* keyID starts here: */ 0xF2, 0x88, 0x35, 0x9B, 0xD9, 0x4D, 0xF4, 0xF5, 0x92, 0x29, 0x7D, 0x59, 0xFE, 0x15, 0xF2, 0xAB, 0xF4, 0xD2, 0x56, 0xFB ])

	let payload = Data(base64Encoded: "WwogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMDYtMTdUMTA6MDA6MDAuMDAwKzAyMDAiLAogICJ1aXRzbGFnZGF0dW0iOiIyMDIwLTA2LTE3VDEwOjEwOjAwLjAwMCswMjAwIiwKICAicmVzdWx0YWF0IjoiTkVHQVRJRUYiLAogICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAiYWZzcHJhYWtJZCI6Mjc4NzE3Njh9LAogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMTEtMDhUMTA6MTU6MDAuMDAwKzAxMDAiLAogICAidWl0c2xhZ2RhdHVtIjoiMjAyMC0xMS0wOVQwNzo1MDozOS4wMDArMDEwMCIsCiAgICJyZXN1bHRhYXQiOiJQT1NJVElFRiIsCiAgICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAgImFmc3ByYWFrSWQiOjI1ODcxOTcyMTl9Cl0K" )!

	let wrongPayload = Data(base64Encoded: "WwogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMDYtMTdUMTA6MDA6MDAuMDAwKzAyMDAiLAogICJ1aXRzbGFnZGF0dW0iOiIyMDIwLTA2LTE3VDEwOjEwOjAwLjAwMCswMjAwIiwKICAicmVzdWx0YWF0IjoiTkVHQVRJRUYiLAogICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAiYWZzcHJhYWtJZCI6Mjc4NzE3Njh9LAogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMTEtMDhUMTA6MTU6MDAuMDAwKzAxMDAiLAogICAidWl0c2xhZ2RhdHVtIjoiMjAyMC0xMS0wOVQwNzo1MDozOS4wMDArMDEwMCIsCiAgICJyZXN1bHRhYXQiOiJQT1NJVElFRiIsCiAgICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAgImFmc3ByYWFrSWQiOjI1ODcxOTcyMTl9Cl1K" )!

	let signaturePKCS = Data(base64Encoded: "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" )!

	let signaturePPS = Data(base64Encoded: "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")!

	// MARK: - Signature

	func testCMSSignature_padding_pkcs_validPayload() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: payload,
			certificateData: rootCertificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.n",
			requiredCommonNameSuffix: ".nl")

		// Then
		expect(validation) == true
	}

	func testCMSSignature_padding_pkcs_wrongPayload() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: wrongPayload,
			certificateData: rootCertificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.n",
			requiredCommonNameSuffix: ".nl")

		// Then
		expect(validation) == false
	}

	func testCMSSignature_padding_pss_validPayload() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePPS,
			contentData: payload,
			certificateData: rootCertificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.n",
			requiredCommonNameSuffix: ".nl")

		// Then
		expect(validation) == true
	}

	func testCMSSignature_padding_pss_wrongPayload() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let validation = sut.validatePKCS7Signature(
			wrongPayload,
			contentData: payload,
			certificateData: rootCertificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.n",
			requiredCommonNameSuffix: ".nl")

		// Then
		expect(validation) == false
	}

	func testCMSSignature_test_pinning_wrongCommonName() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: payload,
			certificateData: rootCertificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".xx.n",
			requiredCommonNameSuffix: ".nl")

		// Then
		expect(validation) == false
	}

	func testCMSSignature_test_pinning_wrongSuffix() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: payload,
			certificateData: rootCertificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.n",
			requiredCommonNameSuffix: ".xx"
		)

		// Then
		expect(validation) == false
	}

	func testCMSSignature_test_pinning_emptySuffix() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: payload,
			certificateData: rootCertificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.n",
			requiredCommonNameSuffix: ""
		)

		// Then
		expect(validation) == false
	}

	func testCMSSignature_test_pinning_emptyCommonName() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: payload,
			certificateData: rootCertificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: "",
			requiredCommonNameSuffix: ".xx"
		)

		// Then
		expect(validation) == false
	}

	func testCMSSignature_test_pinning_all_empty() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let validation = sut.validatePKCS7Signature(
			signaturePKCS,
			contentData: payload,
			certificateData: rootCertificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: "",
			requiredCommonNameSuffix: ""
		)

		// Then
		expect(validation) == true
	}

	func testCMSSignature_verydeep() {

		let rootCertificateData = Data(base64Encoded: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMrekNDQWVPZ0F3SUJBZ0lVYzBPUEpXenZ2cEg3ZlZHQVVTeWg1R0o3eGhNd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0RURUxNQWtHQTFVRUF3d0NRMEV3SGhjTk1qRXdOakk1TVRreE5qVTBXaGNOTWpFd056STVNVGt4TmpVMApXakFOTVFzd0NRWURWUVFEREFKRFFUQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCCkFQVktxLzRNbStKRXdOdExCUVpGU0dxaWdEZmwzeXJIRUpuZHY3UTNWYlZzdGNXL1A2OWxOdE9SdkxvS005eDYKWWxNUXIzWVgyWHdXek81cFVFMHdYLzVBV3dVam85a1Q2T0NaRzdXMXNDV2hJZDl1dWs5YkdvbUpEeFExdFl5bApqalgrUEpIV2l3U3ZOY043dWV4NGxOZlFhN01jVnN6d3c0UGpUZ0FEY2pUV3RPSGlNZytaWVQ3Z3E0NzBraUlXCnptQ1NDcDJRWWVIY2tEdjlMNks2OG0zTklGTFR0ckxOYmttZmowSTFwbG1ZT0VxNEpLOWR4RllWZXdYbXRpUVYKREJCRzJ5Ti9EK2dXN1VFbnZXTDljNGJ6VGlXQW9rcVFsem1QQ3EyUTdhR1JsL05keFJKNmhUTEVpUjVna1hwYQp0dWhuNWFaZlliK3VaZFlIRGNVNzBNTUNBd0VBQWFOVE1GRXdIUVlEVlIwT0JCWUVGQkRwMElzTWZtYnVYWm9mCklMRzUvU3hMeUlPYU1COEdBMVVkSXdRWU1CYUFGQkRwMElzTWZtYnVYWm9mSUxHNS9TeEx5SU9hTUE4R0ExVWQKRXdFQi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFNWXRzWU1zUjVtQ2l2Q01zbnBOWjMrbQo5cDJqU1R0OHhqdXlaZSttOEhxUHo4Y3JJZHpIOEhpZ0RwRnoyR2NEaEMvQjBpZ2dwemt1Tm5MRmo1bm9iUk85ClVjMk81aHFpWlgwdlhoalNZblVHcWMzQUw2MjRSeHgwaitBdGtBNlBWVUU4RktkQ2YyTTRlWUYwNUpNb3ZtbTkKY1VsWGU5L3BUVEJUTm4yYmZqQ3Q3enFkTmR4YjVzU3doT1FNZlVBZVNBdG5oLzRKS3ZSZENIRkE2UXVqSGV0agpPTTdoalM4bjN5SG9IakxwUHJuRExTVUtkZHhuQ1hJRG9vS0lwNmJRQnJOL0JXaHhDU3VaNlRDR0dMeVQvVCs0CnNVYjFjVmJOVEx0OGQrRHJkcVRBekRXQmdOQnIrODZUeS9jZEZRM0c3YWN0ZDliSWZ6ekJhcHdpaWhaRGlQbz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo==" )!
		let authorityKeyIdentifier = Data([    0x04, 0x14, 0x8F, 0xF8, 0xFC, 0x3E, 0xA0, 0x42, 0x3D, 0x45, 0x2D, 0x17, 0x07, 0xA1, 0xC4, 0xEB, 0x54, 0xE5, 0xFD, 0x5B, 0x32, 0x76])
		let payload = Data(base64Encoded: "WwogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMDYtMTdUMTA6MDA6MDAuMDAwKzAyMDAiLAogICJ1aXRzbGFnZGF0dW0iOiIyMDIwLTA2LTE3VDEwOjEwOjAwLjAwMCswMjAwIiwKICAicmVzdWx0YWF0IjoiTkVHQVRJRUYiLAogICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAiYWZzcHJhYWtJZCI6Mjc4NzE3Njh9LAogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMTEtMDhUMTA6MTU6MDAuMDAwKzAxMDAiLAogICAidWl0c2xhZ2RhdHVtIjoiMjAyMC0xMS0wOVQwNzo1MDozOS4wMDArMDEwMCIsCiAgICJyZXN1bHRhYXQiOiJQT1NJVElFRiIsCiAgICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAgImFmc3ByYWFrSWQiOjI1ODcxOTcyMTl9Cl0K" )!

		let signature = Data(base64Encoded: "MIImfgYJKoZIhvcNAQcCoIImbzCCJmsCAQExDTALBglghkgBZQMEAgEwCwYJKoZIhvcNAQcBoIIj4zCCAvswggHjoAMCAQICFHNDjyVs776R+31RgFEsoeRie8YTMA0GCSqGSIb3DQEBCwUAMA0xCzAJBgNVBAMMAkNBMB4XDTIxMDYyOTE5MTY1NFoXDTIxMDcyOTE5MTY1NFowDTELMAkGA1UEAwwCQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD1Sqv+DJviRMDbSwUGRUhqooA35d8qxxCZ3b+0N1W1bLXFvz+vZTbTkby6CjPcemJTEK92F9l8FszuaVBNMF/+QFsFI6PZE+jgmRu1tbAloSHfbrpPWxqJiQ8UNbWMpY41/jyR1osErzXDe7nseJTX0GuzHFbM8MOD404AA3I01rTh4jIPmWE+4KuO9JIiFs5gkgqdkGHh3JA7/S+iuvJtzSBS07ayzW5Jn49CNaZZmDhKuCSvXcRWFXsF5rYkFQwQRtsjfw/oFu1BJ71i/XOG804lgKJKkJc5jwqtkO2hkZfzXcUSeoUyxIkeYJF6WrboZ+WmX2G/rmXWBw3FO9DDAgMBAAGjUzBRMB0GA1UdDgQWBBQQ6dCLDH5m7l2aHyCxuf0sS8iDmjAfBgNVHSMEGDAWgBQQ6dCLDH5m7l2aHyCxuf0sS8iDmjAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQDGLbGDLEeZgorwjLJ6TWd/pvado0k7fMY7smXvpvB6j8/HKyHcx/B4oA6Rc9hnA4QvwdIoIKc5LjZyxY+Z6G0TvVHNjuYaomV9L14Y0mJ1BqnNwC+tuEccdI/gLZAOj1VBPBSnQn9jOHmBdOSTKL5pvXFJV3vf6U0wUzZ9m34wre86nTXcW+bEsITkDH1AHkgLZ4f+CSr0XQhxQOkLox3rYzjO4Y0vJ98h6B4y6T65wy0lCnXcZwlyA6KCiKem0AazfwVocQkrmekwhhi8k/0/uLFG9XFWzUy7fHfg63akwMw1gYDQa/vOk8v3HRUNxu2nLXfWyH88wWqcIooWQ4j6MIIDQjCCAiqgAwIBAgICA+gwDQYJKoZIhvcNAQELBQAwDTELMAkGA1UEAwwCQ0EwHhcNMjEwNjI5MTkxNjU0WhcNMjEwNzI5MTkxNjU0WjARMQ8wDQYDVQQDDAYxIGRlZXAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDqJB37ET9+yxH6jDEIqfk+vVYvelbz1P79fvy8nYbMGCN9l7o5Juqw5xboo4ndPxmOVZGMj64nDxwUYyJ60msKjW0HhdqZhMh537GYqL8UiBHoHI5nckuj9VZmb8pKjytrV4g8bV83nhWuEQDMLpiTOZH2twN9Si8Hc+nDlrL+bkJ44GYZyVMpmZxaKYOtlgCCcg8xglcwHVEuAdop5txkekCr4IDgl0Yb2LquEgCRKRGZOkJdsG+nmuG+Iq8c0m6Xzl9CD1ayR55pZGVwaaJ8T4+FWdusDfwB6319U59uOsx8ysKonr7vU0xmipRFOJ/WwWO94SVc8en+oj98pakXAgMBAAGjgacwgaQwRwYJYIZIAYb4QgENBDoWOEZvciB0ZXN0aW5nIG9ubHkgYW5kIG5vIHRoaXMgaXMgbm90IHRoZSByZWFsIHRoaW5nLiBEdWguMAsGA1UdDwQEAwIBBjAdBgNVHQ4EFgQURzhdDLNVjCurfT5zspoaHMa6XLMwHwYDVR0jBBgwFoAUEOnQiwx+Zu5dmh8gsbn9LEvIg5owDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEALUpi2ApFabx4oFBmPIi0ZmbQJJIsSUtWCpqLuLn/obOaGv2giuXrN2NZGtMA6IjfC5hDEwLuyqHzeuR2hbtIOZj4mZ1kHt2pF2UPNzeo+HlM8KmWmn/8TLFhEOkYqeb8tIdCvhYsL0xvwYXMMhPgCOy44aNNFe1NhNgmdQRQ8CmHDnUMIp/nAtSq/U2IVpiDDMueVugWITeA3kno+ON6H3XeKiJe+ws0zUa/4MANmI2FnpZsjXZTITJgr0W30PMCwAx3fvrHTnRI1QGBPhAMjvkC9l6CQHjtK9jFCbnTsNPrTD5jvRSIw0uzzRbLEdB8aAo+VsxBCAF9qUI3LajtmjCCA0YwggIuoAMCAQICAgPoMA0GCSqGSIb3DQEBCwUAMBExDzANBgNVBAMMBjEgZGVlcDAeFw0yMTA2MjkxOTE2NTRaFw0yMTA3MjkxOTE2NTRaMBExDzANBgNVBAMMBjIgZGVlcDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMDW9cZU47/JVo/80mO5Qx7NEhxP+TOoQHlwsccXD0kGaZ335MBzCSbvYxFT3xdUVZVLPudIBNm3cjomVy6/4CC+1WxlW47oUuGccMre6k9gyTW/SaHJzi35L4IfgpoeIL79yx6WLwJXrWgdA7GKqsfcOH6l0drDwP9ZYhnYHbOVQSntC70l5/HV3BTp7NO1t8XTRBbZYDicdJY57YjVApiBCaoIHQvUA1M4wR3HHUyps7c8m+ExgpRJCHtkbIOXg7tc1R+CswoH5NxdIWWFIxqfEnRy4O006CV8oamEYtZmGvC7ONjRgtuYrjR09+xQVtTAAV92qo8Pz//ZRPglZRUCAwEAAaOBpzCBpDBHBglghkgBhvhCAQ0EOhY4Rm9yIHRlc3Rpbmcgb25seSBhbmQgbm8gdGhpcyBpcyBub3QgdGhlIHJlYWwgdGhpbmcuIER1aC4wCwYDVR0PBAQDAgEGMB0GA1UdDgQWBBR28F0+709h9+ANelBzodiXwkyQ8DAfBgNVHSMEGDAWgBRHOF0Ms1WMK6t9PnOymhocxrpcszAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBbbTQ/Ki+uXQWMCGC9+tYK+3GWDy/2X/6uKArjV16lXKS9+bJsPQtyEjDtB43MsAheLy9sRCqjSXotPid4sBGoFQ1ZjZOoYMQ4gEkfo1NgMMPFkBbeYHrOH6bjl+82Q1A0mBni9V4GH5owpliuu/WtlkEMNAuB4AdtneW9U3Sq3zbYpf/rF5q+QCiPHwlhkMcXPuw1kaksVKc8uBMG6HYlOFqdZg32AcNwI8rzFvlF357RGdImXgDD+LXCHAFqHjrUJ4mgMrS1lMQffBxTAbp7ujdVmJqFlA0Xjsb2HGZwfAW/utX1QllI+Jo6B0Fz8AKknBqetXuHIVQX8qGz2w7hMIIDRjCCAi6gAwIBAgICA+gwDQYJKoZIhvcNAQELBQAwETEPMA0GA1UEAwwGMiBkZWVwMB4XDTIxMDYyOTE5MTY1NFoXDTIxMDcyOTE5MTY1NFowETEPMA0GA1UEAwwGMyBkZWVwMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArUDH98szCqhKSmU5J9g7/LaXC6ZS6QZuJtnf7Fh5ywJnaFt3LnZWqb87gcdHRZKtGsOuYPxZfhBhoOTjshYLPaTNxOCJQPUjRSxpc6Gbi80oSX/dKCIq9pHOKR59kqLV7n+kA5MjVp7haxSwDgeYsSkJzQQL8PaIR2dSE0gIGz7/NrRYP97XfCCtOADxkxdS9r9EfLy8dqbxVn162oslH6gjrcC1o8eMNpfbu23W57cfkgN0M81rawDBkuvfqc+uFa4fiAwmATNn2F4HMJwLpMlbPg9vkyL8P06tq9XkPx5xiI5UC+7zOitRYGEt2wKipyiWQcM2Xmenj4L7G4jY9QIDAQABo4GnMIGkMEcGCWCGSAGG+EIBDQQ6FjhGb3IgdGVzdGluZyBvbmx5IGFuZCBubyB0aGlzIGlzIG5vdCB0aGUgcmVhbCB0aGluZy4gRHVoLjALBgNVHQ8EBAMCAQYwHQYDVR0OBBYEFJS4Flve15Ld+wDmDUN26mWQ3fQIMB8GA1UdIwQYMBaAFHbwXT7vT2H34A16UHOh2JfCTJDwMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAIgBWeG8IF+4w+CQ7PWFsRVoF/snQHjlRqMxxVnvgX5JrwF42O6/Sh8mI6C2rnGpofEjaI2Dx9BAgLbPzqqTp4Ps8yo6aZjFcWyVZKqSG5dEyWSyLY+rd7SgnjGcvcKtNjTyYziGeZI1FeVrjaehW1b4mtAlpXvTI6+BySYlVcxnqkQbJjMV/AWZ+2eLApacBZb4E9kGSinVW9BadZMCtxJEuzSZFtl2RccxsXkAgp8fVnZt1EffqGT0k7XztOXVufsyt6l35GrPliCZG/PlsVi5mnSKPOtuo1CrleLlMtH1jdHnOHeDk9vcFsW3Q6kbMuJs1g+MkkdLZptNjZVOlPowggNGMIICLqADAgECAgID6DANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAYzIGRlZXAwHhcNMjEwNjI5MTkxNjU0WhcNMjEwNzI5MTkxNjU0WjARMQ8wDQYDVQQDDAY0IGRlZXAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDL9L8+NQ5rzt2bVeIiuO+mm6xLqbaY8WtLDjzX2Hgsj+NP+m0auwbe4ddomtJo2korbUYrCcFh5X7NBAAhwzOZq9W+ROTPoiV2Vp52zlYPIZBes5wHFmaXAzQD3UtRTweujw3rfE2OL4snUPuGeO67yNPI+CwodF+8ZV55Q0JR9Zw2p8/RS6sMXY36jPR+6Bmn6mKzA7MCUqtTI/0yRMdiEL3UJ9O6XTnVIIuVzQ0qIaGLaNPqm2at2Fi+lcJjkXhgUhN+Or3Wi7vkYrOWb10JlB2q4HooKsOgMtl1D4dSBMpodlEMIksNOCUPqTO2RP9jiDqiRGz/GWYrDhuzmtSbAgMBAAGjgacwgaQwRwYJYIZIAYb4QgENBDoWOEZvciB0ZXN0aW5nIG9ubHkgYW5kIG5vIHRoaXMgaXMgbm90IHRoZSByZWFsIHRoaW5nLiBEdWguMAsGA1UdDwQEAwIBBjAdBgNVHQ4EFgQUJgIIbAeFH5vHeaL6OQhiRO9D7vcwHwYDVR0jBBgwFoAUlLgWW97Xkt37AOYNQ3bqZZDd9AgwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAOpOk44tunOCFxzKwaqoNejKYQPPP9D7PXV98WzCcmrd93jXF8M2S1pe3JE6VdFzeLoLp+vukol0IfNKBCjOgvcYafWSQkXOH4YgspsNUaHR/MP3k5MFTy6bUUVPfjN/vkgl6i08nE+18dYnh2eJfrgfdCd1Di/EJHVItzMnJaCHyAE45KAMPlSUZ9xQvPvEUxLF61fSLn7qF8kbXozbktqBzUL5OQJAUDumr9MOU/9pbJsNPgVqgXyazSXQwTAWqQBYcUd8gtgQuBf1epaITZzSV/NQsx924JR+ZUnxmlcZNnaO6PeKfftM/sGQoqI8reDAPYW8A00icW/6WIi9oeTCCA0YwggIuoAMCAQICAgPoMA0GCSqGSIb3DQEBCwUAMBExDzANBgNVBAMMBjQgZGVlcDAeFw0yMTA2MjkxOTE2NTRaFw0yMTA3MjkxOTE2NTRaMBExDzANBgNVBAMMBjUgZGVlcDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANfWQDV5KK+8O5K76/xaEQLbfNoxN9/AG5hHxJ3bVIL2g1h2gG7YazsPcHb3Gkz/MEHS28l9DMWUZv/C6PlrtaSuwlaFoTETYYsCpJ9m1ePpyBaTj2C6zcUivSAowL4P2cdpCbLxVEz2KTOEpwocA9Jlt2Yxo0vYzMAg4GvfBQE7EdB2P5OPs1wgVYKnAfZQev+I7LI1u3AAbkXhzLfS4JvpoQ6OberbhXrDdXJ9MgkA3eys22dz2KCC6P/nnn8La9edwm/QUkcy5UZwOo/9sRHBVKYf3jCqCPYL41yk6Y22yK+4w6Ep4d75oFreRf9zImnJG0NTwfpCBNPdsi/eHF0CAwEAAaOBpzCBpDBHBglghkgBhvhCAQ0EOhY4Rm9yIHRlc3Rpbmcgb25seSBhbmQgbm8gdGhpcyBpcyBub3QgdGhlIHJlYWwgdGhpbmcuIER1aC4wCwYDVR0PBAQDAgEGMB0GA1UdDgQWBBTDJqf+1ytO+GWQNMqT5DdSYNt5JjAfBgNVHSMEGDAWgBQmAghsB4Ufm8d5ovo5CGJE70Pu9zAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQDKxc87x3dTRV19wW9lFuJq71HL48eawR68qhCluhIB+zw9vfQi5XiHb/x/5NYReEXLFULnGX4oT654RrtOQ7lZhUu3qVgqm7qs+arkMUO+jZ0t2GCfhChynPI6BpPcJknRJ1mve4wFqvbacn8OshbV9OWgSfxtQijS/24hi9Z14jdTwvhXQvy3YyJ3IuMqGbItkgedLtPwajnKRwMxX2cM/Jg9pu8WXyo5YLzehrxpowy4DRdCurlOxcUQ4BQB05F3m7P0VaV9CLQVGJaRcMqVfTjszSHmcs9lKDCzknNuxw7gHB85FuRMqizf9PRil/XnpCT8LqexgkbUzsQddfevMIIDRjCCAi6gAwIBAgICA+gwDQYJKoZIhvcNAQELBQAwETEPMA0GA1UEAwwGNSBkZWVwMB4XDTIxMDYyOTE5MTY1NFoXDTIxMDcyOTE5MTY1NFowETEPMA0GA1UEAwwGNiBkZWVwMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuZHAGd1X9JBw4lq+Jnihw0+emYMmD81+Kutm/fasSNtVzl5blb7ubBs1+RZ7JroyJu09VnyUIURZ49FG8TyubYuP9zAsArfsc/QFnzFZC7H2gC9NzyJ88zKCYfoS3tIG0lFoqCjBqRT8v2lPYARLmNOMlHf1ievreCl58p84Pecd7j+VypJg+UeLJ7SXU+njXdw1D3j2Wce8GxMXcMVn9aLtKjs9UfvggQpisY9H+F0RG3C3tcBV7MKw/hvGO4hmc5hriLj9V22DdZnSCjdZQ7DkO9OGBan4ung6l80B10AdTYr9Jc9LIfY3ObNJj4lFul5H5saFtczmrQ/PXfQx2QIDAQABo4GnMIGkMEcGCWCGSAGG+EIBDQQ6FjhGb3IgdGVzdGluZyBvbmx5IGFuZCBubyB0aGlzIGlzIG5vdCB0aGUgcmVhbCB0aGluZy4gRHVoLjALBgNVHQ8EBAMCAQYwHQYDVR0OBBYEFKckbhSTZXx9XZIXYwLYu3kot7gPMB8GA1UdIwQYMBaAFMMmp/7XK074ZZA0ypPkN1Jg23kmMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBABUJEsG71fQU0vf0dilbNaDMlIYaDIDSguaxskyeuoaSU7igvtWHJNAZk2UZc4sdfZv3rUxdSt2bYdkQEl2+DeiKqvbedPY3lx4hBUbQD4z64DI077vcCy3SNrsiTt2XqLet/Pr0tmuAPXU3FzzUNuI3KSZcbmIhm9M3yjI36Y0wqJbq4CvOdUoB6tpBSEUY6LON1zny9lj/Bwy8HZclv9RqqR8a/WpmbktfdOHzSJ0ViwvjSfQhBbwD19OtklsxdbLIs6LbCgeyzDS+ptvOUKie6bbgcBtWwX7DkxlQi5g/6aKmMs+AI0BCSxRh4qFUXRhHw6xCeMNIU3qyank0obMwggNGMIICLqADAgECAgID6DANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAY2IGRlZXAwHhcNMjEwNjI5MTkxNjU0WhcNMjEwNzI5MTkxNjU0WjARMQ8wDQYDVQQDDAY3IGRlZXAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC7i9yzdO7JVvb8LF/z9eeeWq0LY7t+qcgXYTvNF4zTa/Mv86ziBqTjcakJwotPowr2TUr324YdDcGDNaTCA/oS7NtfcBzGaI5fi/tq2srIBmHz3Y4GLTkXqDNPV/DvUlMvKFLWFmZPJIURz2CILERRHme9zvvbywXbJeR7IU+cBQsZI4hNU8JohNxQYapJMqmuNmo/x+03IuP5sNumJk/y5kUHEFE2unjmf77tWu412v6Wh3AyqUDMkWqiKdNTGzp7IBQGyXTeN66gO0pI/G1CIM7KW7hUFumjFI5tic2PVUf/fvBKkUFNt4iUzOQilC+E/IJTKHVBQywQjEzooUG9AgMBAAGjgacwgaQwRwYJYIZIAYb4QgENBDoWOEZvciB0ZXN0aW5nIG9ubHkgYW5kIG5vIHRoaXMgaXMgbm90IHRoZSByZWFsIHRoaW5nLiBEdWguMAsGA1UdDwQEAwIBBjAdBgNVHQ4EFgQU7yo7Ia74Cvoe0X22S1iQZyk0mJMwHwYDVR0jBBgwFoAUpyRuFJNlfH1dkhdjAti7eSi3uA8wDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEANRCoapX2nnXpCxf/KXVuehhDsHkH4F8Q9JYKR8Ijm/5WSDE/m99PHJS4ldJtpJwyWvo/ZT220QtARGD9PPArZp1uOfnLfKkak5tQNJ3/M1g/gH1CVTPdvV2RY2QS5T8+plvpD+jw8IbGk4OmnmPPWqVIO1YGSFsxDl8tILhqlQxd3HSJyXfOPT01pmY9Yfdmwxtv06TeCPh7U4HDbVAmhIf8KgWbr89ZhdHnTQI3kj6iA2ahcZhpI7dt52HcyU6ZDgz6JXn6R8YIiHstjVWfQ5CKauKp9/tH5Jtc6DM3zpxJThFrCh5s72Yg+0dLa0IbbjJLyY+GVg+TJtyir+MCdDCCA0YwggIuoAMCAQICAgPoMA0GCSqGSIb3DQEBCwUAMBExDzANBgNVBAMMBjcgZGVlcDAeFw0yMTA2MjkxOTE2NTVaFw0yMTA3MjkxOTE2NTVaMBExDzANBgNVBAMMBjggZGVlcDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANO2dxXAvs6mDajhLkoW+r5964VOo6lkpezjRz1sVF/VRYVUJ26SmA++pKbkRNodH4vGBwhXKtRF5GXtxO6KUbCJV4mJk0bbLmDolP55TbpKshcUD4z47dBLTcsRroQI88t8vacFkuU2mRsx5HYoiSA3kMB+QOfmQSGXlSxfWDxTvDkMa0LY2/zydhyfTMZ67ci0D9sC8J0H37xe/mBeu9k/k19tD6FPFDG8kwKSAbjkBFbu/rBmueXZYEMAJGseNw3o9nLgGTGrugeFzeXM/6BtF/MXoaNLxdT27+Xbzg1O9f4F/Bdo55Vz4UPfoPYoLQtJsTGYbG+Nr38zp1WMJtUCAwEAAaOBpzCBpDBHBglghkgBhvhCAQ0EOhY4Rm9yIHRlc3Rpbmcgb25seSBhbmQgbm8gdGhpcyBpcyBub3QgdGhlIHJlYWwgdGhpbmcuIER1aC4wCwYDVR0PBAQDAgEGMB0GA1UdDgQWBBTjpjXS2cSpJLQPyiviY7Pl2f7DSTAfBgNVHSMEGDAWgBTvKjshrvgK+h7RfbZLWJBnKTSYkzAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQC1ubYE3wePjiAo2YkHR3DfPFoISR5sktcjQS7bGDsXvyejhqerS56SrXQobG4H2xFhYGD9Ph3gD7Zb93Xi77sUd0J7GxoaoXoC+vATGSUBbgdD+eTrt3Q9W6QpwQQ3jXeREIY6uJPR+GA/bgH+QGR30wVsIHf/J3R5RfAA45oi9ZKnO4+pLJcYR8MBDeUyhiR8RyKQ/Lbj/0D8SUGof/Lsq5sunO+SryniJ2edWVH69ffvtdImaF4qWFAuZLMk6YynFgwEIaxyXwh0S272758XHSpjjpp2XfyFsweq1ZxxApmDQtT936dRlji14rKU7gUxqdGmVwIhmSB56jG7Fjc8MIIDRjCCAi6gAwIBAgICA+gwDQYJKoZIhvcNAQELBQAwETEPMA0GA1UEAwwGOCBkZWVwMB4XDTIxMDYyOTE5MTY1NVoXDTIxMDcyOTE5MTY1NVowETEPMA0GA1UEAwwGOSBkZWVwMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2yb6Tvt7h1pclqmbRrWJBgxWxPrA3JVxndH/zN8aZqIdr8kNLDt7Ws4NnQZSI2Bo3TgzK2HcjKyfKjagA5+rppMmV5T1mXWJM1Otgw54uMo/H1wib8+lLPUBw0eMl9Z+8rC8afJ3w5nnChFlxxAf3uQxJc7Oz8vMo9FSFBuw7yi+gG2fHeMfhnZ8S7+v1UrYszehjV5DRWJCTJkL3TSI8CoQJhIYEL67wp5lceazi//goZHsFdvXvax7kuzZJsAkttQ+PDCdcWDIpcoayrlH4U/Na2m6bMAs7nKVzg53VIMzHCf7/3BcEME0woFu+r7jeslLehrAVju1raF8mF/cEwIDAQABo4GnMIGkMEcGCWCGSAGG+EIBDQQ6FjhGb3IgdGVzdGluZyBvbmx5IGFuZCBubyB0aGlzIGlzIG5vdCB0aGUgcmVhbCB0aGluZy4gRHVoLjALBgNVHQ8EBAMCAQYwHQYDVR0OBBYEFI/4/D6gQj1FLRcHocTrVOX9WzJ2MB8GA1UdIwQYMBaAFOOmNdLZxKkktA/KK+Jjs+XZ/sNJMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAMUKYGBBjoDsAgB2a3QNj6fIHUdaYMMtjsbc5irXvhNoE2qnjq2BpBqPQJ2XB4/T01EXbrEHT0FwBj4pFV2l7f7A+x+d/+e1cP51Qis76sLCICHO3ut4crMPYHZchbfec8Ly72ieUBnUeaQufkZqr7BH5RVNjS7TX6MsyyQJZ42MleRT+FV72mId2hWiHjHxILMn27rs7IbV1hU0nOs5EB2aPaP9uY7HeKalwX+QZDKjTrIWxARAu2Z9tWNOEaXr7DtDgS3KPGOkrgnRsSfwhKIBfvHaXRBvV78fP1BFDq5G8tTjhBEaMz76AufbMTparhP4769Il3YOve4sQ75phgQwggNKMIICMqADAgECAgsA3q2+796tvu/A3jANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAY5IGRlZXAwHhcNMjEwNjI5MTkxNjU1WhcNMjEwNzI5MTkxNjU1WjAPMQ0wCwYDVQQDDARsZWFmMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAm6032rjy2qu48w5k9f4vAccuUrJx8h7+qArRudHjQ2xpLSPJ13ZdISfxXBz24qyjiSRadIybTWITNkAnGxf7Nbqbg+nPBuBriKsGKPu+WQRXepCuXXSG8BU45lo1u7eLfHSz6cazkTM4kjKUGvBjNFRnzyferb+uXB9/9yzusId2EaaCbpfWBFl0nHVcyB5FbSVDroYy9yYfpRrY4XzgLgFDGUiD5uHQVkBOhtxrKQk+3f14aV0v754BDtRrPIJ/XV4aDP7uXTD/s/EYIrafNHIVLCP/ZHdJvgp9AAbnGIgcO4/bSDWiObeO++2/aCPMAw5sx5C0RViZdouEG24K0QIDAQABo4GkMIGhMEcGCWCGSAGG+EIBDQQ6FjhGb3IgdGVzdGluZyBvbmx5IGFuZCBubyB0aGlzIGlzIG5vdCB0aGUgcmVhbCB0aGluZy4gRHVoLjALBgNVHQ8EBAMCBeAwHQYDVR0OBBYEFJ79VZVdEnU38EUb0kKc01c7NfscMB8GA1UdIwQYMBaAFI/4/D6gQj1FLRcHocTrVOX9WzJ2MAkGA1UdEwQCMAAwDQYJKoZIhvcNAQELBQADggEBAH5kOuOuSm5haQqaZIk8psV4MIbYRTLeaskhpB+rI55vAW3SMiHL7L4WsRH8eO2yLgniYC566l1OKQ5SbiSYGVT72TDNyKJuF45g47krBr7UIwCRf8GyAvmO2S/g1gTf9pAKHo44dQIcxjHQNO5ll1j8PLCsCXYJ+VGM1cQXVJfmxMVZ/PYgmskwwhKEo9YMf01QFqUL6/9IaG2RVjh6unC4suWCdxGgPOsOK62gk0d0ni3JPosQ0oVZOeugcnl/agFrq8urVPeon+dFX+E0+EzSNlHFism6G2DCDMnBuCz24SEtZ8a1cjHt0IaKFWeYngTTiYC8Q3yyTA9B7FNg7xYxggJhMIICXQIBATAgMBExDzANBgNVBAMMBjkgZGVlcAILAN6tvu/erb7vwN4wCwYJYIZIAWUDBAIBoIHkMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIxMDYyOTE5MTcxM1owLwYJKoZIhvcNAQkEMSIEII3qIngl0AG+hRtZnqHqM+YCKd64tyzB5USxq4OsmlFNMHkGCSqGSIb3DQEJDzFsMGowCwYJYIZIAWUDBAEqMAsGCWCGSAFlAwQBFjALBglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMD4GCSqGSIb3DQEBCjAxoA0wCwYJYIZIAWUDBAIBoRowGAYJKoZIhvcNAQEIMAsGCWCGSAFlAwQCAaIEAgIA3gSCAQAzrjQkSpVmtCEcRkLjC13etMrVaxQF6jf6vf2AqlvEfJLJnZgGhF2X1fQ+UfdwnowCTBzH+UTo4wTdjKAvR1Q3v8qbVeyh8bTPbfJ/7bspNyYDRmyQQuktUOivnz+wBYDgDarHfQ4E/ZukfHhoAnHDAWU7cQW6EWo76PtvVFZihuyol6emrG9A/Iy+NniLkbvX5UX56pBabBqeABFLbPSpz7HxSo3Czmg3gvUi6XpRE6Ywd/qi6S9DCgTWrx91bJ0dULjAB/xDLia8H0K7TpHjFTerhjFop+e3fKZEotQgtaEEptSKvbhOLk7y9OjI0WHnqGI0QaWLsUTxoVOjYdqc" )!

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let validation = sut.validatePKCS7Signature(
			signature,
			contentData: payload,
			certificateData: rootCertificateData,
			authorityKeyIdentifier: authorityKeyIdentifier,
			requiredCommonNameContent: "leaf",
			requiredCommonNameSuffix: "f"
		)

		// Then
		expect(validation) == true
	}

	func test_cms_fake_chain() {

		let fakeChain = [ OpenSSLData.fakeChain02, OpenSSLData.fakeChain01 ]
		let realChain = [
			OpenSSLData.realCrossSigned, // Let's Encrypt has two roots; an older one by a third party and their own.
			OpenSSLData.realChain01,
			OpenSSLData.realChain02
		]

		let openssl = OpenSSL()
		XCTAssertNotNil(openssl)
		XCTAssertNotNil(SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: TrustConfiguration.rootISRGX1))

		// the auth identifier just above the leaf that signed.
		// fake and real are identical
		//
		let authorityKeyIdentifier = Data(
			[0x04, 0x14, 0x14, 0x2E, 0xB3, 0x17, 0xB7, 0x58, 0x56, 0xCB, 0xAE, 0x50, 0x09, 0x40, 0xE6, 0x1F, 0xAF, 0x9D, 0x8B, 0x14, 0xC2, 0xC6]
		)

		// this is a test against the fully fake root and should succeed.
		//
		XCTAssertEqual(true, openssl.validatePKCS7Signature(
						OpenSSLData.fakeSignature,
						contentData: OpenSSLData.fakePayload,
						certificateData: OpenSSLData.fakeRoot,
						authorityKeyIdentifier: authorityKeyIdentifier,
						requiredCommonNameContent: "bananen",
						requiredCommonNameSuffix: "nl"))

		// Now test against our build in (real) root - and fail.
		//
		XCTAssertEqual(false, openssl.validatePKCS7Signature(
						OpenSSLData.fakeSignature,
						contentData: OpenSSLData.fakePayload,
						certificateData: TrustConfiguration.rootISRGX1,
						authorityKeyIdentifier: authorityKeyIdentifier,
						requiredCommonNameContent: "bananen",
						requiredCommonNameSuffix: "nl"))

		let fakeLeafCert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: OpenSSLData.fakeLeaf)
		XCTAssert(fakeLeafCert != nil)

		var fakeCertArray = [SecCertificate]()
		for certPem in fakeChain {
			let cert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: certPem)
			XCTAssert(cert != nil)
			fakeCertArray.append(cert!)
		}

		let realLeafCert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: OpenSSLData.realLeaf)
		XCTAssert(fakeLeafCert != nil)

		var realCertArray = [SecCertificate]()
		for certPem in realChain {
			let cert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: certPem)
			XCTAssert(cert != nil)
			realCertArray.append(cert!)
		}

		// Create a 'worst case' kitchen sink chain with as much in it as we can think off.
		//
		let realRootCert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: OpenSSLData.realRoot)
		let fakeRootCert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: OpenSSLData.fakeRoot)
		let allChainCerts = realCertArray + fakeCertArray + [ realRootCert, fakeRootCert]

		// This should fail - as the root is not build in. It may however
		// succeed if the user has somehow the fake root into the system trust
		// chain -and- set it to 'trusted' (or was fooled/hacked into that).
		//
		if true {
			let policy = SecPolicyCreateSSL(true, "api-ct.bananenhalen.nl" as CFString)
			var optionalRealTrust: SecTrust?

			// the first certificate is the one to check - the rest is to aid validation.
			//
			XCTAssert(noErr == SecTrustCreateWithCertificates([ realLeafCert ] + realCertArray as CFArray,
															  policy,
															  &optionalRealTrust))
			XCTAssertNotNil(optionalRealTrust)
			let realServerTrust = optionalRealTrust!

			// This should success - as we rely on the build in well known root.
			//
			XCTAssertTrue(SecurityCheckerWorker().checkATS(serverTrust: realServerTrust,
														   policies: [policy],
														   trustedCertificates: []))

			// This should succeed - as we explicitly rely on the root.
			//
			XCTAssertTrue(SecurityCheckerWorker().checkATS(serverTrust: realServerTrust,
														   policies: [policy],
														   trustedCertificates: [ OpenSSLData.realRoot ]))

			// This should fail - as we are giving it the wrong root.
			//
			XCTAssertFalse(SecurityCheckerWorker().checkATS(serverTrust: realServerTrust,
															policies: [policy],
															trustedCertificates: [OpenSSLData.fakeRoot]))

			let realRootString = String(decoding: OpenSSLData.realRoot, as: UTF8.self)
			let lineEndingString = realRootString.replacingOccurrences(of: "\n", with: "\r\n")
			let realRootLineEnding = lineEndingString.data(using: .ascii)!
			expect(lineEndingString).to(contain("\r\n")) == true
			XCTAssertTrue(SecurityCheckerWorker().checkATS(serverTrust: realServerTrust,
														   policies: [policy],
														   trustedCertificates: [realRootLineEnding]))
		}

		if true {
			let policy = SecPolicyCreateSSL(true, "api-ct.bananenhalen.nl" as CFString)
			var optionalFakeTrust: SecTrust?
			XCTAssert(noErr == SecTrustCreateWithCertificates([ fakeLeafCert ] + fakeCertArray as CFArray,
															  policy,
															  &optionalFakeTrust))
			XCTAssertNotNil(optionalFakeTrust)
			let fakeServerTrust = optionalFakeTrust!

			// This should succeed - as we have the fake root as part of our trust
			//
			XCTAssertTrue(SecurityCheckerWorker().checkATS(serverTrust: fakeServerTrust,
														   policies: [policy],
														   trustedCertificates: [OpenSSLData.fakeRoot ]))

		}
		if true {
			let policy = SecPolicyCreateSSL(true, "api-ct.bananenhalen.nl" as CFString)
			var optionalFakeTrust: SecTrust?
			XCTAssert(noErr == SecTrustCreateWithCertificates([fakeLeafCert ] + fakeCertArray as CFArray,
															  policy,
															  &optionalFakeTrust))
			XCTAssertNotNil(optionalFakeTrust)
			let fakeServerTrust = optionalFakeTrust!

			// This should fail - as the root is not build in. It may however
			// succeed if the user has somehow the fake root into the system trust
			// chain -and- set it to 'trusted' (or was fooled/hacked into that).
			//
			// In theory this requires:
			// 1) creating the DER version of the fake CA.
			//     openssl x509 -in ca.pem -out fake.crt -outform DER
			// 2) Loading this into the emulator via Safari
			// 3) Hitting install in Settings->General->Profiles
			// 4) Enabling it as trusted in Settings->About->Certificate Trust settings.
			// but we've not gotten this to work reliably yet (just once).
			//
			XCTAssertFalse(SecurityCheckerWorker().checkATS(serverTrust: fakeServerTrust,
															policies: [policy],
															trustedCertificates: []))

			// This should fail - as we are giving it the wrong root to trust.
			//
			XCTAssertFalse(SecurityCheckerWorker().checkATS(serverTrust: fakeServerTrust,
															policies: [policy],
															trustedCertificates: [ OpenSSLData.realRoot ]))

			// This should succeed - as we are giving it the right root to trust.
			//
			XCTAssertTrue(SecurityCheckerWorker().checkATS(serverTrust: fakeServerTrust,
														   policies: [policy],
														   trustedCertificates: [ OpenSSLData.fakeRoot ]))
		}

		// Try again - but now with anything we can think of cert wise.
		//
		if true {
			let policy = SecPolicyCreateSSL(true, "api-ct.bananenhalen.nl" as CFString)
			var optionalFakeTrust: SecTrust?
			XCTAssert(noErr == SecTrustCreateWithCertificates([ fakeLeafCert ] + allChainCerts as CFArray,
															  policy,
															  &optionalFakeTrust))
			XCTAssertNotNil(optionalFakeTrust)
			let fakeServerTrust = optionalFakeTrust!

			// This should fail - as the root is not build in. It may however
			// succeed if the user has somehow the fake root into the system trust
			// chain -and- set it to 'trusted' (or was fooled/hacked into that).
			//
			XCTAssertFalse(SecurityCheckerWorker().checkATS(serverTrust: fakeServerTrust,
															policies: [policy],
															trustedCertificates: []))

			// This should fail - as we are giving it the wrong cert..
			//
			XCTAssertFalse(SecurityCheckerWorker().checkATS(serverTrust: fakeServerTrust,
															policies: [policy],
															trustedCertificates: [ OpenSSLData.realRoot ]))
		}
	}

	// MARK: - Subject Alternative Name

	func test_subjectAlternativeName_deprecated() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let san = sut.getSubjectAlternativeName(OpenSSLData.realLeaf) as String?

		// Then
		expect(san) == "api-ct.bananenhalen.nl"
	}

	func test_subjectAlternativeNames_realLeaf() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let sans = sut.getSubjectAlternativeDNSNames(OpenSSLData.realLeaf) as? [String]

		// Then
		expect(sans).to(haveCount(1))
		expect(sans?.first) == "api-ct.bananenhalen.nl"
	}

	func test_subjectAlternativeNames_fakeLeaf() {

		// Given
		expect(self.sut).toNot(beNil())

		// When
		let sans = sut.getSubjectAlternativeDNSNames(OpenSSLData.certWithStuff) as? [String]

		// Then
		expect(sans).to(haveCount(2))
		// check that we skip the IP, otherName and email entry.
		expect(sans).to(contain("test1"))
		expect(sans).to(contain("test2"))
		expect(sans).toNot(contain("1.2.3.4"))

		// OpenSSL seems to keep the order the same.
		expect(sans?.first) == "test1"
		expect(sans?.last) == "test2"

		expect(self.sut.validateSubjectAlternativeDNSName("test1", forCertificateData: OpenSSLData.certWithStuff)) == true
		expect(self.sut.validateSubjectAlternativeDNSName("test2", forCertificateData: OpenSSLData.certWithStuff)) == true
		// check that we do not see the non DNS entries. IP address is a bit of an edge case. Perhaps
		// we should allow that to match.
		expect(self.sut.validateSubjectAlternativeDNSName("fo@bar", forCertificateData: OpenSSLData.certWithStuff)) == false
	}
}
