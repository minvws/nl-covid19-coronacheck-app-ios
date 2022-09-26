/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import CTR
import XCTest
import Nimble

class SecurityCheckerWorkerTests: XCTestCase {
	
	var sut = SecurityCheckerWorker()
	let testBundle = Bundle(for: SecurityCheckerWorkerTests.self)
	var environmentalSpies: EnvironmentSpies!
	
	override func setUp() {
		
		super.setUp()
		sut = SecurityCheckerWorker()
		environmentalSpies = setupEnvironmentSpies()
	}
	
	func test_checkSSL_noTrustCertificates_shouldSucceed() throws {
		
		// Given
		let realLeafCert = try getCertificate("holder-api.coronacheck.nl")
		let policy = SecPolicyCreateSSL(true, "holder-api.coronacheck.nl" as CFString)
		let chain = try constructChain()
		
		var optionalServerTrust: SecTrust?
		XCTAssert(noErr == SecTrustCreateWithCertificates([ realLeafCert ] + chain  as CFArray, policy, &optionalServerTrust))
		let serverTrust = try XCTUnwrap(optionalServerTrust)
		var result = false
		
		// When
		DispatchQueue.global().async {
			result = self.sut.checkSSL(
				serverTrust: serverTrust,
				policies: [policy],
				trustedCertificates: [],
				hostname: "test",
				trustedName: "test"
			)
		}
	
		// Then
		expect(result).toEventually(beTrue())
	}
	
	func test_checkSSL_wrongHostname_shouldFail() throws {
		
		// Given
		let realLeafCert = try getCertificate("holder-api.coronacheck.nl")
		let policy = SecPolicyCreateSSL(true, "holder-api.coronacheck.nl" as CFString)
		let chain = try constructChain()
		
		var optionalServerTrust: SecTrust?
		XCTAssert(noErr == SecTrustCreateWithCertificates([ realLeafCert ] + chain  as CFArray, policy, &optionalServerTrust))
		let serverTrust = try XCTUnwrap(optionalServerTrust)
		
		let trustedServerCertificate = try getCertificateData("holder-api.coronacheck.nl")
		var result = false
		
		// When
		DispatchQueue.global().async {
			result = self.sut.checkSSL(
				serverTrust: serverTrust,
				policies: [policy],
				trustedCertificates: [trustedServerCertificate],
				hostname: "coronacheck",
				trustedName: nil
			)
		}
		
		// Then
		expect(result).toEventually(beFalse())
	}
	
	func test_checkSSL_doesMatchTrustedHost_shouldSucceed() throws {
		
		// Given
		let realLeafCert = try getCertificate("holder-api.coronacheck.nl")
		let policy = SecPolicyCreateSSL(true, "holder-api.coronacheck.nl" as CFString)
		let chain = try constructChain()
		
		var optionalServerTrust: SecTrust?
		XCTAssert(noErr == SecTrustCreateWithCertificates([ realLeafCert ] + chain  as CFArray, policy, &optionalServerTrust))
		let serverTrust = try XCTUnwrap(optionalServerTrust)
		
		let trustedServerCertificate = try getCertificateData("holder-api.coronacheck.nl")
		var result = false
		
		// When
		DispatchQueue.global().async {
			result = self.sut.checkSSL(
				serverTrust: serverTrust,
				policies: [policy],
				trustedCertificates: [trustedServerCertificate],
				hostname: "holder-api.coronacheck.nl",
				trustedName: ".coronacheck.nl"
			)
		}
		
		// Then
		expect(result).toEventually(beTrue())
	}
	
	func test_checkSSL_doesNotMatchTrustedHost_shouldSucceed() throws {
		
		// Given
		let realLeafCert = try getCertificate("holder-api.coronacheck.nl")
		let policy = SecPolicyCreateSSL(true, "holder-api.coronacheck.nl" as CFString)
		let chain = try constructChain()
		
		var optionalServerTrust: SecTrust?
		XCTAssert(noErr == SecTrustCreateWithCertificates([ realLeafCert ] + chain  as CFArray, policy, &optionalServerTrust))
		let serverTrust = try XCTUnwrap(optionalServerTrust)
		
		let trustedServerCertificate = try getCertificateData("holder-api.coronacheck.nl")
		var result = false
		
		// When
		DispatchQueue.global().async {
			result = self.sut.checkSSL(
				serverTrust: serverTrust,
				policies: [policy],
				trustedCertificates: [trustedServerCertificate],
				hostname: "holder-api.coronacheck.nl",
				trustedName: ".google.com"
			)
		}
		
		// Then
		expect(result).toEventually(beFalse())
	}
	
	func test_checkSSL_shouldSucceed() throws {
		
		// Given
		let realLeafCert = try getCertificate("holder-api.coronacheck.nl")
		let policy = SecPolicyCreateSSL(true, "holder-api.coronacheck.nl" as CFString)
		let chain = try constructChain()
		
		var optionalServerTrust: SecTrust?
		XCTAssert(noErr == SecTrustCreateWithCertificates([ realLeafCert ] + chain  as CFArray, policy, &optionalServerTrust))
		let serverTrust = try XCTUnwrap(optionalServerTrust)
		
		let trustedServerCertificate = try getCertificateData("holder-api.coronacheck.nl")
		var result = false
		
		// When
		DispatchQueue.global().async {
			result = self.sut.checkSSL(
				serverTrust: serverTrust,
				policies: [policy],
				trustedCertificates: [trustedServerCertificate],
				hostname: "holder-api.coronacheck.nl",
				trustedName: nil
			)
		}
		// Then
		expect(result).toEventually(beTrue())
	}
	
	func test_checkSSL_expiredChain_shouldFail() throws {
		
		// Given
		let policy = SecPolicyCreateSSL(true, "holder-api.coronacheck.nl" as CFString)
		let chain = [try getCertificate("certRealLeaf")]
		
		var optionalServerTrust: SecTrust?
		XCTAssert(noErr == SecTrustCreateWithCertificates(chain as CFArray, policy, &optionalServerTrust))
		let serverTrust = try XCTUnwrap(optionalServerTrust)
		
		let trustedServerCertificate = try getCertificateData("certRealLeaf")
		var result = true
		
		// When
		DispatchQueue.global().async {
			result = self.sut.checkSSL(
			serverTrust: serverTrust,
			policies: [policy],
			trustedCertificates: [trustedServerCertificate],
			hostname: "holder-api.coronacheck.nl",
			trustedName: nil
		)
		
		// Then
		expect(result).toEventually(beFalse())
	}
	
	// MARK: helpers
	
	func constructChain() throws -> [SecCertificate?] {
		
		// getting the chain certificates:
		// openssl s_client -showcerts -servername holder-api.coronacheck.nl -connect holder-api.coronacheck.nl:443
		let realChain = [
			try getCertificate("Staat der Nederlanden EV Root CA"),
			try getCertificate("Staat der Nederlanden Domein Server CA 2020"),
			try getCertificate("KPN PKIoverheid Server CA 2020")
		]
		return realChain
	}
	
	func getCertificate(_ fileName: String, fileExtension: String = ".pem") throws -> SecCertificate? {
		
		let certificateData = try getCertificateData(fileName)
		let certificate = sut.certificateFromPEM(certificateAsPemData: certificateData)
		return certificate
	}
	
	func getCertificateData(_ fileName: String, fileExtension: String = ".pem") throws -> Data {
		
		let certificateUrl = try XCTUnwrap(testBundle.url(forResource: fileName, withExtension: fileExtension))
		return try Data(contentsOf: certificateUrl)
	}
}
