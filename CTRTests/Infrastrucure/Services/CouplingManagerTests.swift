/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class CouplingManagerTests: XCTestCase {

	private var sut: CouplingManager!
	private var networkManagerSpy: NetworkSpy!
	private var cryptoManagerSpy: CryptoManagerSpy!

	override func setUp() {
		super.setUp()
		
		networkManagerSpy = NetworkSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		sut = CouplingManager(cryptoManager: cryptoManagerSpy, networkManager: networkManagerSpy)
	}
	
	func test_checkCouplingStatus() {
		
		// Given
		networkManagerSpy.stubbedCheckCouplingStatusCompletionResult = (.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		
		waitUntil { done in
			// When
			self.sut.checkCouplingStatus(dcc: "test", couplingCode: "test") { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
				done()
			}
		}
	}
	
	func test_convert_noCredentials() {
		
		// Given
		cryptoManagerSpy.stubbedReadEuCredentialsResult = nil
		
		// When
		let wrapper = sut.convert("test", couplingCode: "test")
		
		// Then
		expect(wrapper).to(beNil())
		
	}
	
	func test_convert() {
		
		// Given
		cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()
		
		// When
		let wrapper = sut.convert("test_convert", couplingCode: "test_couplingCode")
		
		// Then
		expect(wrapper?.providerIdentifier) == "DCC"
		expect(wrapper?.protocolVersion) == "3.0"
		expect(wrapper?.identity.firstName) == "Check"
		expect(wrapper?.identity.lastName) == "Corona"
		expect(wrapper?.events.first?.type) == "paperFlow"
		expect(wrapper?.events.first?.unique) == "test_convert"
		expect(wrapper?.events.first?.vaccination).to(beNil())
		expect(wrapper?.events.first?.dccEvent?.credential) == "test_convert"
		expect(wrapper?.events.first?.dccEvent?.couplingCode) == "test_couplingCode"
	}
}
