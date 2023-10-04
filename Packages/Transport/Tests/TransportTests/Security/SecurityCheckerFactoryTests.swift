/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import Transport

class SecurityCheckerFactoryTests: XCTestCase {
	
	func test_securityCheckerNone_checkSSL() {
		
		// Given
		var credential: URLCredential?
		var dispostion: URLSession.AuthChallengeDisposition?
		let securityChecker = SecurityCheckerFactory.getSecurityChecker(.none, challenge: nil, dataTLSCertificates: []) { dis, cred in
			credential = cred
			dispostion = dis
		}
		
		// When
		securityChecker.checkSSL()
		
		// Then
		expect(credential) == nil
		expect(dispostion).toEventually(equal(.performDefaultHandling))
	}
	
	func test_getSecurityChecker_none() {
		
		// Given
		
		// When
		let sut = SecurityCheckerFactory.getSecurityChecker(.none, challenge: nil, dataTLSCertificates: []) { _, _ in }
		
		// Then
		expect(sut).to(beAKindOf(SecurityCheckerNone.self))
	}
	
	func test_getSecurityChecker_data() throws {
		
		// Given
		let sut = SecurityCheckerFactory.getSecurityChecker(.data, challenge: nil, dataTLSCertificates: [Data(), Data()]) { _, _ in }
		
		// When
		let casted = try XCTUnwrap(sut as? SecurityChecker)
		
		// Then
		expect(casted.trustedName) == ".coronacheck.nl"
		expect(casted.trustedCertificates).to(haveCount(2))
	}
	
	func test_getSecurityChecker_provider_withoutCertificates() throws {
		
		// Given
		let providerSpy = CertificateProviderSpy()
		providerSpy.stubbedGetTLSCertificatesResult = []
		
		let sut = SecurityCheckerFactory.getSecurityChecker(.provider(providerSpy), challenge: nil, dataTLSCertificates: []) { _, _ in }
		
		// When
		let casted = try XCTUnwrap(sut as? SecurityChecker)
		
		// Then
		expect(casted.trustedName) == nil
		expect(casted.trustedCertificates).to(beEmpty())
	}
	
	func test_getSecurityChecker_provider_withCertificates() throws {
		
		// Given
		let providerSpy = CertificateProviderSpy()
		providerSpy.stubbedGetTLSCertificatesResult = [Data(), Data(), Data()]
		
		let sut = SecurityCheckerFactory.getSecurityChecker(.provider(providerSpy), challenge: nil, dataTLSCertificates: []) { _, _ in }
		
		// When
		let casted = try XCTUnwrap(sut as? SecurityChecker)
		
		// Then
		expect(casted.trustedName) == nil
		expect(casted.trustedCertificates).to(haveCount(3))
	}
}
