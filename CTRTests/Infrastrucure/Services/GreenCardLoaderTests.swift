/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR
import XCTest
import Nimble

class GreenCardLoaderTests: XCTestCase {

	private var environmentSpies: EnvironmentSpies!
	private var sut: GreenCardLoader!
	
	override func setUp() {
		super.setUp()

		environmentSpies = setupEnvironmentSpies()
		
		sut = GreenCardLoader(
			networkManager: environmentSpies.networkManagerSpy,
			cryptoManager: environmentSpies.cryptoManagerSpy,
			walletManager: environmentSpies.walletManagerSpy,
			remoteConfigManager: environmentSpies.remoteConfigManagerSpy,
			userSettings: environmentSpies.userSettingsSpy,
			secureUserSettings: environmentSpies.secureUserSettingsSpy
		)
	}
	
	func test_signTheEvents_withoutSecretKey() {
		
		// Arrange
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = nil
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: nil,
			completion: { result = $0 }
		)
		
		// Assert
		expect(result?.failureError) == GreenCardLoader.Error.failedToGenerateDomesticSecretKey
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue) == false
	}
	
	func test_signTheEvents_prepareIssue_networkError() {
		
		// Arrange
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		let serverError = ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.failure(serverError), ()))
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: nil,
			completion: { result = $0 }
		)
		
		// Assert
		expect(result?.failureError) == GreenCardLoader.Error.preparingIssue(serverError)
		expect(self.environmentSpies.walletManagerSpy.invokedFetchSignedEvents) == false
	}
	
	func test_signTheEvents_prepareIssue_success_withoutPrepareIssueMessage() {
		// Arrange
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "Wrong", stoken: "test")), ()))
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: nil,
			completion: { result = $0 }
		)
		
		// Assert
		expect(result?.failureError) == GreenCardLoader.Error.failedToParsePrepareIssue
		expect(self.environmentSpies.walletManagerSpy.invokedFetchSignedEvents) == false
	}
	
	func test_signTheEvents_fetchGreenCards_failsWithoutSignedEvents() {
		// Arrange
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = []
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: nil,
			completion: { result = $0 }
		)
		
		// Assert
		expect(self.environmentSpies.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(result?.failureError) == GreenCardLoader.Error.noSignedEvents
	}
	
	func test_signTheEvents_fetchGreenCards_failsWithoutCommitmentMessage() {
		// Arrange
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = ""
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: nil,
			completion: { result = $0 }
		)
		
		// Assert
		expect(self.environmentSpies.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(result?.failureError) == GreenCardLoader.Error.failedToGenerateCommitmentMessage
	}
	
	func test_signTheEvents_fetchGreenCards_failsOnNetworkError() {
		// Arrange
		let serverError: ServerError = .error(statusCode: nil, response: nil, error: .noInternetConnection)
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = .some(Data())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (Result<RemoteGreenCards.Response, ServerError>.failure(serverError), ())
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: nil,
			completion: { result = $0 }
		)
		
		// Assert
		expect(self.environmentSpies.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(result?.failureError) == GreenCardLoader.Error.credentials(serverError)
	}
	
	func test_signTheEvents_storeGreenCards_withEmptyResponse_clearsHolderSecretKey() {
		// Arrange
		let secretKey = "secretKey".data(using: .utf8)
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.emptyResponse), ())
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: nil,
			completion: { _ in }
		)
		
		// Assert
		expect(self.environmentSpies.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.environmentSpies.secureUserSettingsSpy.invokedHolderSecretKeyList.last) == nil
	}
	
	func test_signTheEvents_storeGreenCards_withOnlyInternationalGreenCard_clearsHolderSecretKey() {
		// Arrange
		let secretKey = "secretKey".data(using: .utf8)
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.internationalVaccination), ())
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: nil,
			completion: { _ in }
		)
		
		// Assert
		expect(self.environmentSpies.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.environmentSpies.secureUserSettingsSpy.invokedHolderSecretKeyList.last) == nil
	}
	
	func test_signTheEvents_storeGreenCards_withDomestic_failToSave() {
		// Arrange
		let secretKey = "secretKey".data(using: .utf8)
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.domesticRecovery), ())
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = false
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: nil,
			completion: { result = $0 }
		)
		
		// Assert
		expect(self.environmentSpies.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(self.environmentSpies.walletManagerSpy.invokedStoreDomesticGreenCardCount) == 1
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCardCount) == 0
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.environmentSpies.secureUserSettingsSpy.invokedHolderSecretKeyList.last) != nil
		
		expect(result?.failureError) == .failedToSaveGreenCards
	}
	func test_signTheEvents_storeGreenCards_withDomestic_success() throws {
		// Arrange
		let secretKey = "secretKey".data(using: .utf8)
		var result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>?
		let response = RemoteGreenCards.Response.domesticRecovery
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(response), ())
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: .vaccination,
			completion: { result = $0 }
		)
		
		// Assert
		expect(self.environmentSpies.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(self.environmentSpies.walletManagerSpy.invokedStoreDomesticGreenCardCount) == 1
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCardCount) == 0
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.environmentSpies.secureUserSettingsSpy.invokedHolderSecretKeyList.last) != nil
		
		let sentRequestParameters = try XCTUnwrap(self.environmentSpies.networkManagerSpy.invokedFetchGreencardsParameters?.dictionary)
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
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(response), ())
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: .recovery,
			completion: { result = $0 }
		)
		
		// Assert
		expect(self.environmentSpies.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(self.environmentSpies.walletManagerSpy.invokedStoreDomesticGreenCardCount) == 0
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCardCount) == 1
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.environmentSpies.secureUserSettingsSpy.invokedHolderSecretKeyList.last) == nil
		
		let sentRequestParameters = try XCTUnwrap(self.environmentSpies.networkManagerSpy.invokedFetchGreencardsParameters?.dictionary)
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
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(response), ())
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: .test(.ggd),
			completion: { result = $0 }
		)
		
		// Assert
		expect(self.environmentSpies.walletManagerSpy.invokedFetchSignedEvents) == true
		expect(self.environmentSpies.walletManagerSpy.invokedStoreDomesticGreenCardCount) == 1
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCardCount) == 1
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.environmentSpies.secureUserSettingsSpy.invokedHolderSecretKeyList.last) != nil
		
		let sentRequestParameters = try XCTUnwrap(self.environmentSpies.networkManagerSpy.invokedFetchGreencardsParameters?.dictionary)
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
		let response = RemoteGreenCards.Response(domesticGreenCard: .fakeVaccinationAssessmentGreenCardExpiresIn14Days, euGreenCards: nil, blobExpireDates: [RemoteGreenCards.BlobExpiry(identifier: "id", expirationDate: Date())], hints: nil)
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = secretKey
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = .some((Result<PrepareIssueEnvelope, ServerError>.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ()))
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "works"
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(response), ())
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		
		// Act
		sut.signTheEventsIntoGreenCardsAndCredentials(
			eventMode: nil,
			completion: { result = $0 }
		)
		
		// Assert
		expect(self.environmentSpies.walletManagerSpy.invokedUpdateEventGroupCount) == 1
		
		expect(result?.successValue) == response
	}
}
