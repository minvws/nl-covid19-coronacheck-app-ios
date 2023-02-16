/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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

	private var sut: GreenCardLoader!
	
	var networkManagerSpy: NetworkSpy!
	var cryptoManagerSpy: CryptoManagerSpy!
	var walletManagerSpy: WalletManagerSpy!
	var secureUserSettingsSpy: SecureUserSettingsSpy!
	
	override func setUp() {
		super.setUp()
		
		networkManagerSpy = NetworkSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		walletManagerSpy = WalletManagerSpy()
		secureUserSettingsSpy = SecureUserSettingsSpy()
		
		sut = GreenCardLoader(
			networkManager: networkManagerSpy,
			cryptoManager: cryptoManagerSpy,
			walletManager: walletManagerSpy,
			secureUserSettings: secureUserSettingsSpy
		)
	}
	
	func test_signTheEvents_withoutSecretKey() {
		
		// Arrange
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = nil
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: nil,
			completion: { result = $0 }
		)
		
		// Assert
		expect(result?.failureError) == GreenCardLoader.Error.failedToGenerateDomesticSecretKey
		expect(self.networkManagerSpy.invokedPrepareIssue) == false
	}
	
	func test_signTheEvents_prepareIssue_networkError() {
		
		// Arrange
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		let serverError = ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.failure(serverError), ()))
		
		// Act
		waitUntil { done in
			self.sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(result?.failureError) == GreenCardLoader.Error.preparingIssue(serverError)
		expect(self.walletManagerSpy.invokedFetchSignedEvents) == false
	}
	
	func test_signTheEvents_prepareIssue_success_withoutPrepareIssueMessage() {
		// Arrange
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "Wrong", stoken: "test")), ()))
		
		// Act
		waitUntil { done in
			self.sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(result?.failureError) == GreenCardLoader.Error.failedToParsePrepareIssue
		expect(self.walletManagerSpy.invokedFetchSignedEvents) == false
	}
	
	func test_signTheEvents_fetchGreenCards_failsWithoutSignedEvents() {
		// Arrange
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = []
		
		// Act
		waitUntil { done in
			self.sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(self.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(result?.failureError) == GreenCardLoader.Error.noSignedEvents
	}
	
	func test_signTheEvents_fetchGreenCards_failsWithoutCommitmentMessage() {
		// Arrange
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = ""
		
		// Act
		waitUntil { done in
			self.sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(self.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(result?.failureError) == GreenCardLoader.Error.failedToGenerateCommitmentMessage
	}
	
	func test_signTheEvents_fetchGreenCards_failsOnNetworkError() {
		// Arrange
		let serverError: ServerError = .error(statusCode: nil, response: nil, error: .noInternetConnection)
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		networkManagerSpy.stubbedFetchGreencardsCompletionResult = (Result<RemoteGreenCards.Response, ServerError>.failure(serverError), ())
		
		// Act
		waitUntil { done in
			self.sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(self.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(result?.failureError) == GreenCardLoader.Error.credentials(serverError)
	}
	
	func test_signTheEvents_storeGreenCards_withEmptyResponse_clearsHolderSecretKey() {
		// Arrange
		let secretKey = "secretKey".data(using: .utf8)
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.emptyResponse), ())
		
		// Act
		waitUntil { done in
			self.sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { _ in done() }
			)
		}
		
		// Assert
		expect(self.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(self.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.secureUserSettingsSpy.invokedHolderSecretKeyList.last) == nil
	}
	
	func test_signTheEvents_storeGreenCards_withOnlyInternationalGreenCard_clearsHolderSecretKey() {
		// Arrange
		let secretKey = "secretKey".data(using: .utf8)
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.internationalVaccination), ())
		
		// Act
		waitUntil { done in
			self.sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { _ in done() }
			)
		}
		
		// Assert
		expect(self.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(self.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.secureUserSettingsSpy.invokedHolderSecretKeyList.last) == nil
	}
	
	func test_signTheEvents_storeGreenCards_withDomestic_failToSave() {
		// Arrange
		let secretKey = "secretKey".data(using: .utf8)
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.domesticRecovery), ())
		walletManagerSpy.stubbedStoreDomesticGreenCardResult = false
		
		// Act
		waitUntil { done in
			self.sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(self.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(self.walletManagerSpy.invokedStoreDomesticGreenCardCount) == 1
		expect(self.walletManagerSpy.invokedStoreEuGreenCardCount) == 0
		expect(self.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.secureUserSettingsSpy.invokedHolderSecretKeyList.last) != nil
		
		expect(result?.failureError) == .failedToSaveGreenCards
	}
	func test_signTheEvents_storeGreenCards_withDomestic_success() throws {
		// Arrange
		let secretKey = "secretKey".data(using: .utf8)
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		let response = RemoteGreenCards.Response.domesticRecovery
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(response), ())
		walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		
		// Act
		waitUntil { done in
			self.sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: .vaccination,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(self.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(self.walletManagerSpy.invokedStoreDomesticGreenCardCount) == 1
		expect(self.walletManagerSpy.invokedStoreEuGreenCardCount) == 0
		expect(self.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.secureUserSettingsSpy.invokedHolderSecretKeyList.last) != nil
		
		let sentRequestParameters = try XCTUnwrap(self.networkManagerSpy.invokedFetchGreencardsParameters?.dictionary)
		expect(sentRequestParameters).to(haveCount(4))
		expect(sentRequestParameters["events"] as? [String]) == ["test"]
		expect(sentRequestParameters["issueCommitmentMessage"] as? String) == "d29ya3M="
		expect(sentRequestParameters["flows"] as? [String]) == ["vaccination"]
		expect(sentRequestParameters["stoken"] as? String) == "test"
		
		expect(result?.successValue) == response
	}

	func test_signTheEvents_storeGreenCards_withInternational_success() throws {
		// Arrange
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
			self.sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: .recovery,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(self.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(self.walletManagerSpy.invokedStoreDomesticGreenCardCount) == 0
		expect(self.walletManagerSpy.invokedStoreEuGreenCardCount) == 1
		expect(self.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.secureUserSettingsSpy.invokedHolderSecretKeyList.last) == nil
		
		let sentRequestParameters = try XCTUnwrap(self.networkManagerSpy.invokedFetchGreencardsParameters?.dictionary)
		expect(sentRequestParameters).to(haveCount(4))
		expect(sentRequestParameters["events"] as? [String]) == ["test"]
		expect(sentRequestParameters["issueCommitmentMessage"] as? String) == "d29ya3M="
		expect(sentRequestParameters["flows"] as? [String]) == ["positivetest"]
		expect(sentRequestParameters["stoken"] as? String) == "test"
		
		expect(result?.successValue) == response
	}

	func test_signTheEvents_storeGreenCards_withDomesticAndInternational_success() throws {
		// Arrange
		let secretKey = "secretKey".data(using: .utf8)
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		let response = RemoteGreenCards.Response.domesticAndInternationalVaccination
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(response), ())
		walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		walletManagerSpy.stubbedStoreEuGreenCardResult = true
		
		// Act
		waitUntil { done in
			self.sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: .test(.ggd),
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(self.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(self.walletManagerSpy.invokedStoreDomesticGreenCardCount) == 1
		expect(self.walletManagerSpy.invokedStoreEuGreenCardCount) == 1
		expect(self.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.secureUserSettingsSpy.invokedHolderSecretKeyList.last) != nil
		
		let sentRequestParameters = try XCTUnwrap(self.networkManagerSpy.invokedFetchGreencardsParameters?.dictionary)
		expect(sentRequestParameters).to(haveCount(4))
		expect(sentRequestParameters["events"] as? [String]) == ["test"]
		expect(sentRequestParameters["issueCommitmentMessage"] as? String) == "d29ya3M="
		expect(sentRequestParameters["flows"] as? [String]) == ["negativetest"]
		expect(sentRequestParameters["stoken"] as? String) == "test"
		
		expect(result?.successValue) == response
	}

	func test_signTheEvents_storeGreenCards_withBlobExpireDates_success() {
		// Arrange
		let secretKey = "secretKey".data(using: .utf8)
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		let response = RemoteGreenCards.Response(domesticGreenCard: .fakeVaccinationAssessmentGreenCardExpiresIn14Days, euGreenCards: nil, blobExpireDates: [RemoteGreenCards.BlobExpiry(identifier: "id", expirationDate: Date(), reason: "")], hints: nil)
		cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(response), ())
		walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		walletManagerSpy.stubbedStoreEuGreenCardResult = true
		
		// Act
		waitUntil { done in
			self.sut.signTheEventsIntoGreenCardsAndCredentials(
				eventMode: nil,
				completion: { result = $0; done() }
			)
		}
		
		// Assert
		expect(self.walletManagerSpy.invokedUpdateEventGroupIdentifierCount) == 1
		
		expect(result?.successValue) == response
	}
}
