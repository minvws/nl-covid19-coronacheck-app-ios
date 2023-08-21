/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import Transport
@testable import Shared
@testable import Managers
import XCTest
import Nimble

class GreenCardLoaderTests: XCTestCase {
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (GreenCardLoader, NetworkSpy, CryptoManagerSpy, WalletManagerSpy) {
			
		let networkManagerSpy = NetworkSpy()
		let cryptoManagerSpy = CryptoManagerSpy()
		let walletManagerSpy = WalletManagerSpy()
		let secureUserSettingsSpy = SecureUserSettingsSpy()
		
		let sut = GreenCardLoader(
			networkManager: networkManagerSpy,
			cryptoManager: cryptoManagerSpy,
			walletManager: walletManagerSpy,
			secureUserSettings: secureUserSettingsSpy
		)
		
		trackForMemoryLeak(instance: networkManagerSpy, file: file, line: line)
		trackForMemoryLeak(instance: cryptoManagerSpy, file: file, line: line)
		trackForMemoryLeak(instance: walletManagerSpy, file: file, line: line)
		trackForMemoryLeak(instance: secureUserSettingsSpy, file: file, line: line)
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, networkManagerSpy, cryptoManagerSpy, walletManagerSpy)
	}
	
	func test_signTheEvents_withoutSecretKey() {
		
		// Arrange
		let (sut, networkManagerSpy, cryptoManagerSpy, _) = makeSUT()
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = nil
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: nil,
			completion: { result = $0 }
		)
		
		// Assert
		expect(result?.failureError) == GreenCardLoader.Error.failedToGenerateDomesticSecretKey
		expect(networkManagerSpy.invokedPrepareIssue) == false
	}
	
	func test_signTheEvents_prepareIssue_networkError() {
		
		// Arrange
		let (sut, networkManagerSpy, cryptoManagerSpy, walletManagerSpy) = makeSUT()
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		let serverError = ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.failure(serverError), ()))
		
		// Act
		waitUntil { done in
			sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(result?.failureError) == GreenCardLoader.Error.preparingIssue(serverError)
		expect(walletManagerSpy.invokedFetchSignedEvents) == false
	}
	
	func test_signTheEvents_prepareIssue_success_withoutPrepareIssueMessage() {
	
		// Arrange
		let (sut, networkManagerSpy, cryptoManagerSpy, walletManagerSpy) = makeSUT()
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "Wrong", stoken: "test")), ()))
		
		// Act
		waitUntil { done in
			sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(result?.failureError) == GreenCardLoader.Error.failedToParsePrepareIssue
		expect(walletManagerSpy.invokedFetchSignedEvents) == false
	}
	
	func test_signTheEvents_fetchGreenCards_failsWithoutSignedEvents() {
	
		// Arrange
		let (sut, networkManagerSpy, cryptoManagerSpy, walletManagerSpy) = makeSUT()
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = []
		
		// Act
		waitUntil { done in
			sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(walletManagerSpy.invokedFetchSignedEvents) == true
		expect(result?.failureError) == GreenCardLoader.Error.noSignedEvents
	}
	
	func test_signTheEvents_fetchGreenCards_failsWithoutCommitmentMessage() {
		
		// Arrange
		let (sut, networkManagerSpy, cryptoManagerSpy, walletManagerSpy) = makeSUT()
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = ""
		
		// Act
		waitUntil { done in
			sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(walletManagerSpy.invokedFetchSignedEvents) == true
		expect(result?.failureError) == GreenCardLoader.Error.failedToGenerateCommitmentMessage
	}
	
	func test_signTheEvents_fetchGreenCards_failsOnNetworkError() {
		
		// Arrange
		let (sut, networkManagerSpy, cryptoManagerSpy, walletManagerSpy) = makeSUT()
		let serverError: ServerError = .error(statusCode: nil, response: nil, error: .noInternetConnection)
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		networkManagerSpy.stubbedFetchGreencardsCompletionResult = (Result<RemoteGreenCards.Response, ServerError>.failure(serverError), ())
		
		// Act
		waitUntil { done in
			sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(walletManagerSpy.invokedFetchSignedEvents) == true
		expect(result?.failureError) == GreenCardLoader.Error.credentials(serverError)
	}
	
	func test_signTheEvents_storeGreenCards_withEmptyResponse() {
		
		// Arrange
		let (sut, networkManagerSpy, cryptoManagerSpy, walletManagerSpy) = makeSUT()
		let secretKey = "secretKey".data(using: .utf8)
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.emptyResponse), ())
		
		// Act
		waitUntil { done in
			sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { _ in done() }
			)
		}
		
		// Assert
		expect(walletManagerSpy.invokedFetchSignedEvents) == true
		expect(walletManagerSpy.invokedRemoveExistingGreenCards) == true
	}
	
	func test_signTheEvents_storeGreenCards_withOnlyInternationalGreenCard() {
		
		// Arrange
		let (sut, networkManagerSpy, cryptoManagerSpy, walletManagerSpy) = makeSUT()
		let secretKey = "secretKey".data(using: .utf8)
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.internationalVaccination), ())
		
		// Act
		waitUntil { done in
			sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { _ in done() }
			)
		}
		
		// Assert
		expect(walletManagerSpy.invokedFetchSignedEvents) == true
		expect(walletManagerSpy.invokedRemoveExistingGreenCards) == true
	}

	func test_signTheEvents_storeGreenCards_withInternational_success() throws {
		
		// Arrange
		let (sut, networkManagerSpy, cryptoManagerSpy, walletManagerSpy) = makeSUT()
		let secretKey = "secretKey".data(using: .utf8)
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		let response = RemoteGreenCards.Response.internationalVaccination
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(response), ())
		walletManagerSpy.stubbedStoreEuGreenCardResult = true
		
		// Act
		waitUntil { done in
			sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: .recovery,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(walletManagerSpy.invokedFetchSignedEvents) == true
		expect(walletManagerSpy.invokedStoreEuGreenCardCount) == 1
		expect(walletManagerSpy.invokedRemoveExistingGreenCards) == true
		
		let sentRequestParameters = try XCTUnwrap(networkManagerSpy.invokedFetchGreencardsParameters?.dictionary)
		expect(sentRequestParameters).to(haveCount(4))
		expect(sentRequestParameters["events"] as? [String]) == ["test"]
		expect(sentRequestParameters["issueCommitmentMessage"] as? String) == "d29ya3M="
		expect(sentRequestParameters["flows"] as? [String]) == ["positivetest"]
		expect(sentRequestParameters["stoken"] as? String) == "test"
		
		expect(result?.successValue) == response
	}

	func test_signTheEvents_storeGreenCards_withBlobExpireDates_success() {
		
		// Arrange
		let (sut, networkManagerSpy, cryptoManagerSpy, walletManagerSpy) = makeSUT()
		let secretKey = "secretKey".data(using: .utf8)
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		let response = RemoteGreenCards.Response(euGreenCards: nil, blobExpireDates: [RemoteGreenCards.BlobExpiry(identifier: "id", expirationDate: Date(), reason: "")], hints: nil)
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(response), ())
		walletManagerSpy.stubbedStoreEuGreenCardResult = true
		
		// Act
		waitUntil { done in
			sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(walletManagerSpy.invokedUpdateEventGroupIdentifierCount) == 1
		
		expect(result?.successValue) == response
	}
}
