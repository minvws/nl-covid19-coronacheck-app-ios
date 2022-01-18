/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR

class PaperProofCheckModelTests: XCTestCase {

	var sut: PaperProofCheckViewModel!
	var coordinatorDelegateSpy: PaperProofCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorDelegateSpy = PaperProofCoordinatorDelegateSpy()
	}

	func test_success_accepted_wrongDCC() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.success(DccCoupling.CouplingResponse(status: .accepted)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.sut.alert).to(beNil())
		expect(self.coordinatorDelegateSpy.invokedDisplayError).toEventually(beTrue())
		if let content = coordinatorDelegateSpy.invokedDisplayErrorParameters?.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.holderErrorstateClientMessage("i 510 000 052")
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}

	func test_success_accepted_correctDCC() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.success(DccCoupling.CouplingResponse(status: .accepted)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = EventFlow.EventResultWrapper(
			providerIdentifier: "CC",
			protocolVersion: "3.0",
			identity: nil,
			status: .complete,
			result: nil
		)

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == true
		expect(self.sut.alert).to(beNil())
	}

	func test_success_blocked() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.success(DccCoupling.CouplingResponse(status: .blocked)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.sut.alert).to(beNil())

		if case let .feedback(content: content) = sut.viewState {
			expect(content.title) == L.holderCheckdccBlockedTitle()
			expect(content.body) == L.holderCheckdccBlockedMessage()
		} else {
			fail("Invalid state")
		}
	}

	func test_success_expired() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.success(DccCoupling.CouplingResponse(status: .expired)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.sut.alert).to(beNil())

		if case let .feedback(content: content) = sut.viewState {
			expect(content.title) == L.holderCheckdccExpiredTitle()
			expect(content.body) == L.holderCheckdccExpiredMessage()
		} else {
			fail("Invalid state")
		}
	}

	func test_success_rejected() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.success(DccCoupling.CouplingResponse(status: .rejected)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.sut.alert).to(beNil())

		if case let .feedback(content: content) = sut.viewState {
			expect(content.title) == L.holderCheckdccRejectedTitle()
			expect(content.body) == L.holderCheckdccRejectedMessage()
		} else {
			fail("Invalid state")
		}
	}

	func test_failure_serverBusy() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError).toEventually(beTrue())
		if let content = coordinatorDelegateSpy.invokedDisplayErrorParameters?.0 {
			expect(content.title) == L.generalNetworkwasbusyTitle()
			expect(content.body) == L.generalNetworkwasbusyErrorcode("i 510 000 429")
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryActionTitle).to(beNil())
		} else {
			fail("Invalid state")
		}
	}

	func test_failure_noInternet() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.sut.alert).toNot(beNil())
		expect(self.sut.alert?.title) == L.generalErrorNointernetTitle()
		expect(self.sut.alert?.subTitle) == L.generalErrorNointernetText()
	}

	func test_failure_requestTimeOut() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeScannedEvent) == false
		expect(self.coordinatorDelegateSpy.invokedDisplayError).toEventually(beTrue())
		if let content = coordinatorDelegateSpy.invokedDisplayErrorParameters?.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.generalErrorServerUnreachableErrorCode("i 510 000 004")
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}

	func test_failure_responseCached() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: 304, response: nil, error: .responseCached)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError).toEventually(beTrue())
		if let content = coordinatorDelegateSpy.invokedDisplayErrorParameters?.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.holderErrorstateServerMessage("i 510 000 304")
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}

	func test_failure_resourceNotFound() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: 404, response: ServerResponse(status: "error", code: 99707), error: .resourceNotFound)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError).toEventually(beTrue())
		if let content = coordinatorDelegateSpy.invokedDisplayErrorParameters?.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.holderErrorstateServerMessage("i 510 000 404 99707")
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}

	func test_failure_serverError() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: 500, response: ServerResponse(status: "error", code: 99707), error: .serverError)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError).toEventually(beTrue())
		if let content = coordinatorDelegateSpy.invokedDisplayErrorParameters?.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.holderErrorstateServerMessage("i 510 000 500 99707")
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}

	func test_failure_invalidResponse() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: nil, response: nil, error: .invalidResponse)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError).toEventually(beTrue())
		if let content = coordinatorDelegateSpy.invokedDisplayErrorParameters?.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.holderErrorstateClientMessage("i 510 000 003")
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}

	func test_failure_invalidRequest() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: nil, response: nil, error: .invalidRequest)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError).toEventually(beTrue())
		if let content = coordinatorDelegateSpy.invokedDisplayErrorParameters?.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.holderErrorstateClientMessage("i 510 000 002")
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}

	func test_failure_invalidSignature() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: nil, response: nil, error: .invalidSignature)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError).toEventually(beTrue())
		if let content = coordinatorDelegateSpy.invokedDisplayErrorParameters?.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.holderErrorstateClientMessage("i 510 000 020")
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}

	func test_failure_cannotDeserialize() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: nil, response: nil, error: .cannotDeserialize)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError).toEventually(beTrue())
		if let content = coordinatorDelegateSpy.invokedDisplayErrorParameters?.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.holderErrorstateClientMessage("i 510 000 030")
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}

	func test_failure_cannotSerialize() {

		// Given
		environmentSpies.couplingManagerSpy.stubbedCheckCouplingStatusOnCompletionResult =
			(.failure(.error(statusCode: nil, response: nil, error: .cannotSerialize)), ())
		environmentSpies.couplingManagerSpy.stubbedConvertResult = nil

		// When
		sut = PaperProofCheckViewModel(
			coordinator: coordinatorDelegateSpy,
			scannedDcc: "test",
			couplingCode: "test"
		)

		// Then
		expect(self.coordinatorDelegateSpy.invokedDisplayError).toEventually(beTrue())
		if let content = coordinatorDelegateSpy.invokedDisplayErrorParameters?.0 {

			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.holderErrorstateClientMessage("i 510 000 031")
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
	}
}

class CouplingManagerSpy: CouplingManaging {

	var invokedConvert = false
	var invokedConvertCount = 0
	var invokedConvertParameters: (dcc: String, couplingCode: String)?
	var invokedConvertParametersList = [(dcc: String, couplingCode: String)]()
	var stubbedConvertResult: EventFlow.EventResultWrapper!

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
	var stubbedCheckCouplingStatusOnCompletionResult: (Result<DccCoupling.CouplingResponse, ServerError>, Void)?

	func checkCouplingStatus(
		dcc: String,
		couplingCode: String,
		onCompletion: @escaping (Result<DccCoupling.CouplingResponse, ServerError>) -> Void) {
		invokedCheckCouplingStatus = true
		invokedCheckCouplingStatusCount += 1
		invokedCheckCouplingStatusParameters = (dcc, couplingCode)
		invokedCheckCouplingStatusParametersList.append((dcc, couplingCode))
		if let result = stubbedCheckCouplingStatusOnCompletionResult {
			onCompletion(result.0)
		}
	}
}
