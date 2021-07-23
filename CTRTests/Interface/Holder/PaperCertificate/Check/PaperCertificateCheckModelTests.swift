/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class PaperCertificateCheckModelTests: XCTestCase {

	var sut: PaperCertificateCheckViewModel!
	var coordinatorDelegateSpy: PaperCertificateCoordinatorDelegateSpy!
	var networkSpy: NetworkSpy!
	var cryptoSpy: CryptoManagerSpy!
	var couplingManagerSpy: CouplingManagerSpy!

	override func setUp() {
		super.setUp()

		coordinatorDelegateSpy = PaperCertificateCoordinatorDelegateSpy()
		networkSpy = NetworkSpy(configuration: .test)
		cryptoSpy = CryptoManagerSpy()
		couplingManagerSpy = CouplingManagerSpy(cryptoManager: cryptoSpy, networkManager: networkSpy)
	}

	func test_success_accepted_wrongDCC() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.success(DccCoupling.CouplingResponse(status: .accepted)), ())
		couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperCertificateCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test",
			couplingManager: couplingManagerSpy
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.sut.alert).toNot(beNil())
	}

	func test_success_accepted_correctDCC() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.success(DccCoupling.CouplingResponse(status: .accepted)), ())
		couplingManagerSpy.stubbedConvertResult = EventFlow.EventResultWrapper(
			providerIdentifier: "CC",
			protocolVersion: "3.0",
			identity: nil,
			status: .complete,
			result: nil
		)

		// When
		sut = PaperCertificateCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test",
			couplingManager: couplingManagerSpy
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == true
		expect(self.sut.alert).to(beNil())
	}

	func test_success_blocked() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.success(DccCoupling.CouplingResponse(status: .blocked)), ())
		couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperCertificateCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test",
			couplingManager: couplingManagerSpy
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.sut.alert).to(beNil())

		if case let .feedback(content: content) = sut.viewState {
			expect(content.title) == L.holderCheckdccBlockedTitle()
			expect(content.subTitle) == L.holderCheckdccBlockedMessage()
		} else {
			fail("Invalid state")
		}
	}

	func test_success_expired() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.success(DccCoupling.CouplingResponse(status: .expired)), ())
		couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperCertificateCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test",
			couplingManager: couplingManagerSpy
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.sut.alert).to(beNil())

		if case let .feedback(content: content) = sut.viewState {
			expect(content.title) == L.holderCheckdccExpiredTitle()
			expect(content.subTitle) == L.holderCheckdccExpiredMessage()
		} else {
			fail("Invalid state")
		}
	}

	func test_success_rejected() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.success(DccCoupling.CouplingResponse(status: .rejected)), ())
		couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperCertificateCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test",
			couplingManager: couplingManagerSpy
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.sut.alert).to(beNil())

		if case let .feedback(content: content) = sut.viewState {
			expect(content.title) == L.holderCheckdccRejectedTitle()
			expect(content.subTitle) == L.holderCheckdccRejectedMessage()
		} else {
			fail("Invalid state")
		}
	}

	func test_failure_serverBusy() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.failure(.serverBusy), ())
		couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperCertificateCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test",
			couplingManager: couplingManagerSpy
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.generalNetworkwasbusyTitle()
	}

	func test_failure_noInternet() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.failure(.noInternetConnection), ())
		couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperCertificateCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test",
			couplingManager: couplingManagerSpy
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.generalErrorNointernetTitle()
	}

	func test_failure_other() {

		// Given
		couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult = (.failure(.invalidResponse), ())
		couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperCertificateCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test",
			couplingManager: couplingManagerSpy
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.generalErrorTitle()
	}
}

class CouplingManagerSpy: CouplingManaging {

	required init(cryptoManager: CryptoManaging, networkManager: NetworkManaging) {}

	var invokedConvert = false
	var invokedConvertCount = 0
	var invokedConvertParameters: (dcc: String, couplingCode: String)?
	var invokedConvertParametersList = [(dcc: String, couplingCode: String)]()
	var stubbedConvertResult: EventFlow.EventResultWrapper?

	func convert(_ dcc: String, couplingCode: String) -> EventFlow.EventResultWrapper? {
		invokedConvert = true
		invokedConvertCount += 1
		invokedConvertParameters = (dcc, couplingCode)
		invokedConvertParametersList.append((dcc, couplingCode))
		return stubbedConvertResult
	}

	var invokedCheckCouplingStatus = false
	var invokedCheckCouplingStatusCount = 0
	var invokedCheckCouplingStatusParameters: (dcc: String, couplingCode: String)?
	var invokedCheckCouplingStatusParametersList = [(dcc: String, couplingCode: String)]()
	var stubbedCheckCouplingStatusOnCompletionResult: (Result<DccCoupling.CouplingResponse, NetworkError>, Void)?

	func checkCouplingStatus(
		dcc: String,
		couplingCode: String,
		onCompletion: @escaping (Result<DccCoupling.CouplingResponse, NetworkError>) -> Void) {
		invokedCheckCouplingStatus = true
		invokedCheckCouplingStatusCount += 1
		invokedCheckCouplingStatusParameters = (dcc, couplingCode)
		invokedCheckCouplingStatusParametersList.append((dcc, couplingCode))
		if let result = stubbedCheckCouplingStatusOnCompletionResult {
			onCompletion(result.0)
		}
	}
}
