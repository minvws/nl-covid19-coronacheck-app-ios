/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import Managers
@testable import Models
@testable import Transport
@testable import Shared

class CouplingManagerTests: XCTestCase {
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (CouplingManager, NetworkSpy, CryptoManagerSpy) {
			
		let networkManagerSpy = NetworkSpy()
		let cryptoManagerSpy = CryptoManagerSpy()
		let sut = CouplingManager(cryptoManager: cryptoManagerSpy, networkManager: networkManagerSpy)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, networkManagerSpy, cryptoManagerSpy)
	}
	
	func test_checkCouplingStatus() {
		
		waitUntil { done in
			// Given
			let (sut, networkManagerSpy, _) = self.makeSUT()
			networkManagerSpy.stubbedCheckCouplingStatusCompletionResult = (.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
			// When
			sut.checkCouplingStatus(dcc: "test", couplingCode: "test") { result in
				
				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
				done()
			}
		}
	}
	
	func test_convert_noCredentials() {
		
		// Given
		let (sut, _, cryptoManagerSpy) = makeSUT()
		cryptoManagerSpy.stubbedReadEuCredentialsResult = nil
		
		// When
		let wrapper = sut.convert("test", couplingCode: "test")
		
		// Then
		expect(wrapper) == nil
		
	}
	
	func test_convert() {
		
		// Given
		let (sut, _, cryptoManagerSpy) = makeSUT()
		cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()
		
		// When
		let wrapper = sut.convert("test_convert", couplingCode: "test_couplingCode")
		
		// Then
		expect(wrapper?.providerIdentifier) == "DCC"
		expect(wrapper?.protocolVersion) == "3.0"
		expect(wrapper?.identity?.firstName) == "Check"
		expect(wrapper?.identity?.lastName) == "Corona"
		expect(wrapper?.events?.first?.type) == "paperFlow"
		expect(wrapper?.events?.first?.unique) == "test_convert"
		expect(wrapper?.events?.first?.vaccination) == nil
		expect(wrapper?.events?.first?.dccEvent?.credential) == "test_convert"
		expect(wrapper?.events?.first?.dccEvent?.couplingCode) == "test_couplingCode"
	}
}
