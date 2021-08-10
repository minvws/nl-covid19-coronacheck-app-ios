/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import XCTest
import Nimble

class OpenSSLChainTests: XCTestCase {

	var sut = OpenSSL()

	override func setUp() {

		super.setUp()
		sut = OpenSSL()
	}

	// swiftlint:disable:next function_body_length
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
						requiredCommonNameContent: "bananenhalen.nl"))

		// Now test against our build in (real) root - and fail.
		//
		XCTAssertEqual(false, openssl.validatePKCS7Signature(
						OpenSSLData.fakeSignature,
						contentData: OpenSSLData.fakePayload,
						certificateData: TrustConfiguration.rootISRGX1,
						authorityKeyIdentifier: authorityKeyIdentifier,
						requiredCommonNameContent: "bananenhalen.nl"))

		let fakeLeafCert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: OpenSSLData.fakeLeaf)
		XCTAssert(fakeLeafCert != nil)

		var fakeCertArray = [SecCertificate]()
		for certPem in fakeChain {
			let cert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: certPem)
			XCTAssert(cert != nil)
			fakeCertArray.append(cert!)
		}

		let realLeafCert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: OpenSSLData.realLeaf)
		XCTAssert(realLeafCert != nil)

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
			expect(lineEndingString).to(contain("\r\n"))
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
}
