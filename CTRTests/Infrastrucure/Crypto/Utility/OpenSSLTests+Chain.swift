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
	let testBundle = Bundle(for: OpenSSLChainTests.self)

	override func setUp() {

		super.setUp()
		sut = OpenSSL()
	}

	func test_fake_chain() {

		guard let realRoot = try? Data(contentsOf: testBundle.url(forResource: "ca", withExtension: ".real")!) else { XCTFail("could not load"); return }
		guard let realChain01  = try? Data(contentsOf: testBundle.url(forResource: "1000", withExtension: ".real")!) else { XCTFail("could not load"); return }
		guard let realChain02  = try? Data(contentsOf: testBundle.url(forResource: "1001", withExtension: ".real")!) else { XCTFail("could not load"); return }
		guard let realLeaf = try? Data(contentsOf: testBundle.url(forResource: "1002", withExtension: ".real")!) else { XCTFail("could not load"); return }

		guard let fakeRoot = try? Data(contentsOf: testBundle.url(forResource: "ca", withExtension: ".fake")!) else { XCTFail("could not load"); return }
		guard let fakeChain01  = try? Data(contentsOf: testBundle.url(forResource: "1000", withExtension: ".fake")!) else { XCTFail("could not load"); return }
		guard let fakeChain02  = try? Data(contentsOf: testBundle.url(forResource: "1001", withExtension: ".fake")!) else { XCTFail("could not load"); return }
		guard let fakeLeaf = try? Data(contentsOf: testBundle.url(forResource: "1002", withExtension: ".fake")!) else { XCTFail("could not load"); return }

		guard let realCrossSigned = try? Data(contentsOf: testBundle.url(forResource: "realCrossSigned", withExtension: ".pem")!) else { XCTFail("could not load"); return }

		let fakeChain = [ fakeChain02, fakeChain01 ]
		let realChain = [
			realCrossSigned, // Let's Encrypt has two roots; an older one by a third party and their own.
			realChain01,
			realChain02
		]

		let fakeLeafCert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: fakeLeaf)
		XCTAssert(fakeLeafCert != nil)

		var fakeCertArray = [SecCertificate]()
		for certPem in fakeChain {
			let cert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: certPem)
			XCTAssert(cert != nil)
			fakeCertArray.append(cert!)
		}

		let realLeafCert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: realLeaf)
		XCTAssert(fakeLeafCert != nil)

		var realCertArray = [SecCertificate]()
		for certPem in realChain {
			let cert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: certPem)
			XCTAssert(cert != nil)
			realCertArray.append(cert!)
		}

		// Create a 'wrorst case' kitchen sink chain with as much in it as we can think off.
		//
		let realRootCert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: realRoot)
		let fakeRootCert = SecurityCheckerWorker().certificateFromPEM(certificateAsPemData: fakeRoot)
		let allChainCerts = realCertArray + fakeCertArray + [ realRootCert, fakeRootCert]

		// This should fail - as the root is not build in. It may however
		// succeed if the user has somehow the fake root into the system trust
		// chain -and- set it to 'trusted' (or was fooled/hacked into that).
		//
		if true {
			let policy = SecPolicyCreateSSL(true, "api-ct.bananenhalen.nl" as CFString)
			var optionalRealTrust: SecTrust?

			// the first certifcate is the one to check - the rest is to aid validation.
			//
			XCTAssert(noErr == SecTrustCreateWithCertificates([ realLeafCert ] + realCertArray as CFArray,
															  policy,
															  &optionalRealTrust))
			XCTAssertNotNil(optionalRealTrust)
			let realServerTrust = optionalRealTrust!

			// This should success - as we rely on the build in well known root.
			//
			XCTAssertTrue(SecurityCheckerWorker().checkATS(
							serverTrust: realServerTrust,
							policies: [policy],
							trustedCertificates: [])
			)

			// This should succeed - as we explictly rely on the root.
			//
			XCTAssertTrue(SecurityCheckerWorker().checkATS(
							serverTrust: realServerTrust,
							policies: [policy],
							trustedCertificates: [ realRoot ])
			)

			// This should fail - as we are giving it the wrong root.
			//
			XCTAssertFalse(SecurityCheckerWorker().checkATS(
							serverTrust: realServerTrust,
							policies: [policy],
							trustedCertificates: [fakeRoot])
			)

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
			XCTAssertTrue(SecurityCheckerWorker().checkATS(
							serverTrust: fakeServerTrust,
							policies: [policy],
							trustedCertificates: [fakeRoot ])
			)

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
			XCTAssertFalse(SecurityCheckerWorker().checkATS(
							serverTrust: fakeServerTrust,
							policies: [policy],
							trustedCertificates: [])
			)

			// This should fail - as we are giving it the wrong root to trust.
			//
			XCTAssertFalse(SecurityCheckerWorker().checkATS(
							serverTrust: fakeServerTrust,
							policies: [policy],
							trustedCertificates: [ realRoot ])
			)

			// This should succeed - as we are giving it the right root to trust.
			//
			XCTAssertTrue(SecurityCheckerWorker().checkATS(
							serverTrust: fakeServerTrust,
							policies: [policy],
							trustedCertificates: [ fakeRoot ])
			)

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
			XCTAssertFalse(SecurityCheckerWorker().checkATS(
							serverTrust: fakeServerTrust,
							policies: [policy],
							trustedCertificates: [])
			)

			// This should fail - as we are giving it the wrong cert..
			//
			XCTAssertFalse(SecurityCheckerWorker().checkATS(
							serverTrust: fakeServerTrust,
							policies: [policy],
							trustedCertificates: [ realRoot ])
			)

		}
	}
}
