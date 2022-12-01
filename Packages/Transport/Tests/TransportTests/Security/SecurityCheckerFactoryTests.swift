/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import Transport

class SecurityCheckerFactoryTests: XCTestCase {
	
	override func setUp() {
		
		super.setUp()
	}

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
}
