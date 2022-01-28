/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import XCTest
import Nimble

class ListRemoteEventsViewModelV2Tests: XCTestCase {

	/// Subject under test
	private var sut: ListRemoteEventsViewModel!
	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var greenCardLoader: GreenCardLoader!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {

		super.setUp()

		environmentSpies = setupEnvironmentSpies()
		
		/// Not using a GreenCardLoader Spy here - this is okay because all its dependencies are already spies.
		/// Once GreenCardLoader has full code coverage, this can be replaced with a spy.
		greenCardLoader = GreenCardLoader(
			now: { now },
			networkManager: environmentSpies.networkManagerSpy,
			cryptoManager: environmentSpies.cryptoManagerSpy,
			walletManager: environmentSpies.walletManagerSpy,
			remoteConfigManager: environmentSpies.remoteConfigManagerSpy,
			userSettings: environmentSpies.userSettingsSpy
		)
 
		coordinatorSpy = EventCoordinatorDelegateSpy()
	}

	func setupSut() {
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [],
			identityChecker: IdentityChecker(),
			greenCardLoader: greenCardLoader
		)
	}

	func test_successNegativeTest_v2() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticlTestV2), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTestV2],
			greenCardLoader: greenCardLoader
		)
		
		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		content.primaryAction?()
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreDomesticGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beFalse())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}
	
	func test_pending_v2() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticlTestV2), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		// When
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventPendingV2],
			greenCardLoader: greenCardLoader
		)
		
		// Then
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holderTestresultsPendingTitle()
		expect(feedback.body) == L.holderTestresultsPendingText()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
}
