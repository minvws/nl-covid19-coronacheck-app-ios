/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length
// swiftlint:disable file_length

@testable import CTR
import XCTest
import Nimble

class ListRemoteEventsViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: ListRemoteEventsViewModel!
	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var greenCardLoader: GreenCardLoader!
	private var environmentSpies: EnvironmentSpies!
	private var identityCheckerSpy: IdentityCheckerSpy!
	
	override func setUp() {

		super.setUp()

		environmentSpies = setupEnvironmentSpies()
		identityCheckerSpy = IdentityCheckerSpy()
		identityCheckerSpy.stubbedCompareResult = true
		
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
			identityChecker: identityCheckerSpy,
			greenCardLoader: greenCardLoader
		)
	}
	
	// MARK: - Back button actions -

	func test_backButtonTapped_loadingState() {

		// Given
		setupSut()
		sut.viewState = .loading(
			content: Content(title: "test_backButtonTapped_loadingState")
		)

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
		expect(self.sut.alert).toNot(beNil())
	}

	func test_backButtonTapped_emptyState() {

		// Given
		setupSut()
		sut.viewState = .feedback(
			content: Content(title: "test_backButtonTapped_emptyState")
		)

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) == EventScreenResult.back(eventMode: .test)
	}

	func test_backButtonTapped_listState() {

		// Given
		setupSut()
		sut.viewState = .listEvents(
			content: Content(title: "test_backButtonTapped_listState"),
			rows: []
		)

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
		expect(self.sut.alert).toNot(beNil())
	}

	func test_warnBeforeGoBack() {

		// Given
		setupSut()
		
		// When
		sut.warnBeforeGoBack()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
		expect(self.sut.alert).toNot(beNil())
	}
	
	// MARK: - Other actions -

	func test_vaccinationrow_actionTapped() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)
		
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		rows.first?.action?()
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		
		guard case let .showEventDetails(title, _, _) = self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0 else {
			fail("wrong delegate callback")
			return
		}
		expect(title) == L.holderEventAboutTitle()
	}

	func test_somethingIsWrong_vaccination_tapped() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		content.secondaryAction?()
		
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) ==
			.moreInformation(
				title: L.holder_listRemoteEvents_somethingWrong_title(),
				body: L.holder_listRemoteEvents_somethingWrong_vaccination_body(),
				hideBodyForScreenCapture: false
			)
	}

	func test_somethingIsWrong_recovery_tapped() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventRecovery],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.secondaryAction?()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) ==
			.moreInformation(
				title: L.holder_listRemoteEvents_somethingWrong_title(),
				body: L.holder_listRemoteEvents_somethingWrong_recovery_body(),
				hideBodyForScreenCapture: false
			)
	}

	func test_somethingIsWrong_vaccinationAndPositiveTest_tapped() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccinationAndPositiveTest,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventPositiveTest],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.secondaryAction?()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) ==
			.moreInformation(
				title: L.holder_listRemoteEvents_somethingWrong_title(),
				body: L.holder_listRemoteEvents_somethingWrong_vaccinationAndPositiveTest_body(),
				hideBodyForScreenCapture: false
			)
	}

	func test_somethingIsWrong_negativeTest_tapped() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.secondaryAction?()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) ==
			.moreInformation(
				title: L.holder_listRemoteEvents_somethingWrong_title(),
				body: L.holder_listRemoteEvents_somethingWrong_test_body(),
				hideBodyForScreenCapture: false
			)
	}
	
	func test_somethingIsWrong_vaccinationAssessment_tapped() {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccinationassessment,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccinationAssessment],
			greenCardLoader: greenCardLoader
		)
		
		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		content.secondaryAction?()
		
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) ==
			.moreInformation(
				title: L.holder_listRemoteEvents_somethingWrong_title(),
				body: L.holder_listRemoteEvents_somethingWrong_vaccinationAssessment_body(),
				hideBodyForScreenCapture: false
			)
	}

	func test_somethingIsWrong_dccVaccination_notAvailable() {

		// Given
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			remoteEvents: [remotePaperFlowEvent],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// Then
		expect(content.secondaryAction).to(beNil())
		expect(content.secondaryActionTitle).to(beNil())
	}

	// MARK: - Event Rows -
	
	func test_oneEvent_oneRow() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [remoteVaccinationEvent(vaccinationDate: "2021-08-01")],
			greenCardLoader: greenCardLoader
		)

		// When
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// Then
		expect(rows).to(haveCount(1))
	}

	func test_twoDifferentEvents_twoRows() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [
				remoteVaccinationEvent(vaccinationDate: "2021-08-01"),
				remoteVaccinationEvent(vaccinationDate: "2021-08-03")
			],
			greenCardLoader: greenCardLoader
		)

		// When
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// Then
		expect(rows).to(haveCount(2))
	}

	func test_twoIdenticalEvents_noHPKCode_twoRows() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [
				remoteVaccinationEvent(vaccinationDate: "2021-08-01"),
				remoteVaccinationEvent(vaccinationDate: "2021-08-01")
			],
			greenCardLoader: greenCardLoader
		)

		// When
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// Then
		expect(rows).to(haveCount(2))
	}

	func test_twoIdenticalEvents_withHPKCode_oneRow() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [
				remoteVaccinationEvent(providerIdentifier: "CC", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "CC", vaccinationDate: "2021-08-02", hpkCode: "2924528")
			],
			greenCardLoader: greenCardLoader
		)

		// When
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// Then
		expect(rows).to(haveCount(1))
	}

	func test_fourIdenticalEvents_withHPKCode_oneRow() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [
				remoteVaccinationEvent(providerIdentifier: "CC", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "CC", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "CC", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "CC", vaccinationDate: "2021-08-02", hpkCode: "2924528")
			],
			greenCardLoader: greenCardLoader
		)

		// When
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// Then
		expect(rows).to(haveCount(1))
	}

	func test_twoSimilarEvents_noHPKCode_twoRows() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [
				remoteVaccinationEvent(providerIdentifier: "GGD", vaccinationDate: "2021-08-01"),
				remoteVaccinationEvent(providerIdentifier: "RVV", vaccinationDate: "2021-08-01")
			],
			greenCardLoader: greenCardLoader
		)

		// When
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// Then
		expect(rows).to(haveCount(2))
	}

	func test_twoSimilarEvents_withHPKCode_oneRow() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [
				remoteVaccinationEvent(providerIdentifier: "GGD", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "RVV", vaccinationDate: "2021-08-02", hpkCode: "2924528")
			],
			greenCardLoader: greenCardLoader
		)

		// When
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// Then
		expect(rows).to(haveCount(1))
	}

	func test_fourSimilarEvents_withHPKCode_twoRows() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [
				// Shot 1 in july
				remoteVaccinationEvent(providerIdentifier: "RVV", vaccinationDate: "2021-07-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "GGD", vaccinationDate: "2021-07-02", hpkCode: "2924528"),
				// Shot 2 in august
				remoteVaccinationEvent(providerIdentifier: "GGD", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "RVV", vaccinationDate: "2021-08-02", hpkCode: "2924528")
			],
			greenCardLoader: greenCardLoader
		)

		// When
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// Then
		expect(rows).to(haveCount(2))
	}

	func test_fourSimilarEvents_withDuplicates_withHPKCode_twoRows() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [
				// Shot 1 in july, duplicate at GGD
				remoteVaccinationEvent(providerIdentifier: "RVV", vaccinationDate: "2021-07-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "GGD", vaccinationDate: "2021-07-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "GGD", vaccinationDate: "2021-07-02", hpkCode: "2924528"),
				// Shot 2 in august, duplicate at RIVM
				remoteVaccinationEvent(providerIdentifier: "GGD", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "RVV", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "RVV", vaccinationDate: "2021-08-02", hpkCode: "2924528")
			],
			greenCardLoader: greenCardLoader
		)

		// When
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state")
			return
		}

		// Then
		expect(rows).to(haveCount(2))
	}
	
	// MARK: - Error States -

	func test_makeQR_invalidMode() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest],
			greenCardLoader: greenCardLoader
		)

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderVaccinationNolistTitle()
		expect(feedback.body) == L.holderVaccinationNolistMessage()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

	func test_makeQR_saveEventGroupError_eventModeVaccination() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = false

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		content.primaryAction?()
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards) == false
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.sut.alert).to(beNil())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 260 CC 056")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupError_eventModeRecovery() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventRecovery],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = false

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards) == false
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.sut.alert).to(beNil())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 360 CC 056")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupError_eventModeTest() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = false

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards) == false
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.sut.alert).to(beNil())
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 160 CC 056")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}
	
	func test_makeQR_saveEventGroupError_eventModeVaccinationAssessmet() throws {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccinationassessment,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccinationAssessment],
			greenCardLoader: greenCardLoader
		)
		
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = false
		
		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		content.primaryAction?()
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards) == false
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.sut.alert).to(beNil())
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 960 CC 056")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_invalidResponse() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = (.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response(domesticGreenCard: nil, euGreenCards: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beFalse())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 270 CC 003")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_requestTimeOut() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response(domesticGreenCard: nil, euGreenCards: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beFalse())

		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.generalErrorServerUnreachableErrorCode("i 270 000 004")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_serverBusy() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response(domesticGreenCard: nil, euGreenCards: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beFalse())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.generalNetworkwasbusyTitle()
		expect(feedback.body) == L.generalNetworkwasbusyErrorcode("i 270 000 429")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	func test_makeQR_saveEventGroupNoError_prepareIssueError_noInternet() throws {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)
		
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.failure(ServerError.error(statusCode: 429, response: nil, error: .noInternetConnection)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response(domesticGreenCard: nil, euGreenCards: nil)), ())
		
		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		content.primaryAction?()
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beFalse())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())
		
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
		expect(self.sut.alert?.cancelTitle).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okTitle).toEventually(equal( L.generalRetry()))
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_invalidSignature() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response(domesticGreenCard: nil, euGreenCards: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beFalse())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 270 CC 020")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_serverError() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99857), error: .serverError)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response(domesticGreenCard: nil, euGreenCards: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beFalse())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateServerMessage("i 270 CC 500 99857")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_invalidResponse() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.sut.alert).to(beNil())
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 280 CC 003")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_requestTimedOut() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.generalErrorServerUnreachableErrorCode("i 280 000 004")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}
	
	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_noInternet() throws {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)
		
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		content.primaryAction?()
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
		expect(self.sut.alert?.cancelTitle).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okTitle).toEventually(equal( L.generalRetry()))
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_serverBusy() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.generalNetworkwasbusyTitle()
		expect(feedback.body) == L.generalNetworkwasbusyErrorcode("i 280 000 429")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_invalidSignature() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .invalidSignature)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 280 CC 020")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}
	
	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_authenticationCancelled() throws {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)
		
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.failure(ServerError.error(statusCode: 429, response: nil, error: .authenticationCancelled)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		content.primaryAction?()
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 280 CC 010")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_serverError() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99857), error: .serverError)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateServerMessage("i 280 CC 500 99857")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_didNotEvaluate_eventModeVaccination() throws {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)
		
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.emptyResponse), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		content.primaryAction?()
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
		
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holderEventOriginmismatchTitle()
		expect(feedback.body) == L.holderEventOriginmismatchVaccinationBody("i 280 000 058")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_didNotEvaluate_eventModeTest() throws {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest],
			greenCardLoader: greenCardLoader
		)
		
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.emptyResponse), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		content.primaryAction?()
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holderEventOriginmismatchTitle()
		expect(feedback.body) == L.holderEventOriginmismatchTestBody("i 180 000 058")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveDomesticGreencardError() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = false
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalVaccination), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

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
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.sut.alert).to(beNil())
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 290 CC 055")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveGreencard_noOrigins() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.noOrigins), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreDomesticGreenCard).toEventually(beFalse())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beFalse())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beFalse())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveGreencardNoError() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
			environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalVaccination), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveGreencardNoError_multipleDCC() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.multipleDCC), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_makeQR_paperflow_vaccination() {

		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalVaccination), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			remoteEvents: [remotePaperFlowEvent],
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
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == false
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreDomesticGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}
	
	func test_makeQR_paperflow_recovery() {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalVaccination), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fake(dcc: EuCredentialAttributes.DigitalCovidCertificate.sampleWithRecovery())
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			remoteEvents: [remotePaperFlowEvent],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}
	
	func test_makeQR_paperflow_test() {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalVaccination), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fake(dcc: EuCredentialAttributes.DigitalCovidCertificate.sampleWithTest())
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			remoteEvents: [remotePaperFlowEvent],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_someEventsMightBeMissing() {

		// Given

		// When
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [],
			eventsMightBeMissing: true,
			greenCardLoader: greenCardLoader
		)

		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.holderErrorstateSomeresultTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.holderErrorstateSomeresultMessage()))
		expect(self.sut.alert?.cancelTitle).to(beNil())
		expect(self.sut.alert?.okTitle).toEventually(equal( L.generalOk()))
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
	}

	func test_greencardLoaderReturnsPreparingIssueError() throws {

		// Given
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.preparingIssue(.error(statusCode: nil, response: nil, error: .invalidSignature))), ())
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: environmentSpies.greenCardLoaderSpy
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 270 CC 020")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
	}

	func test_greencardLoaderReturnsFailedToParsePrepareIssue() throws {

		// Given
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToParsePrepareIssue), ())
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: environmentSpies.greenCardLoaderSpy
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 270 CC 053")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
	}

	func test_greencardLoaderReturnsFailedToGenerateCommitmentMessage() throws {

		// Given
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToGenerateCommitmentMessage), ())
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: environmentSpies.greenCardLoaderSpy
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}

		// When
		content.primaryAction?()

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 270 CC 054")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
	}
	
	func test_identityMismatched() {
		
		// Given
		identityCheckerSpy.stubbedCompareResult = false
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			identityChecker: identityCheckerSpy,
			greenCardLoader: environmentSpies.greenCardLoaderSpy
		)
		
		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		// When
		content.primaryAction?()

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.holderEventIdentityAlertTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.holderEventIdentityAlertMessage()))
		expect(self.sut.alert?.cancelTitle).toEventually(equal(L.holderEventIdentityAlertCancel()))
		expect(self.sut.alert?.okTitle).toEventually(equal( L.holderEventIdentityAlertOk()))
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
	}
	
	// MARK: - Open URL -

	func test_openUrl() throws {

		// Given
		setupSut()
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))

		// When
		sut.openUrl(url)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.0) == url
	}
	
	// MARK: - Success Paths Vaccination -

	func test_successVaccination_internationalQROnly() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.internationalOnly), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreDomesticGreenCard).toEventually(beFalse())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holder_listRemoteEvents_endStateInternationalQROnly_title()
		expect(feedback.body) == L.holder_listRemoteEvents_endStateInternationalQROnly_message()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

//	func test_successPositiveTest_domesticVaccination_domesticRecovery() throws {
//
//		// Given
//		sut = ListRemoteEventsViewModel(
//			coordinator: coordinatorSpy,
//			eventMode: .positiveTest,
//			remoteEvents: [FakeRemoteEvent.fakeRemoteEventPositiveTest],
//			greenCardLoader: greenCardLoader
//		)
//
//		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
//		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
//		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
//		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
//		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
//		(.success(RemoteGreenCards.Response.domesticAndInternationalVaccinationAndRecovery), ())
//		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
//		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
//		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
//		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
//
//		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
//			fail("wrong state")
//			return
//		}
//
//		// When
//		content.primaryAction?()
//
//		// Then
//		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
//		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
//		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
//		expect(self.environmentSpies.walletManagerSpy.invokedStoreDomesticGreenCard).toEventually(beTrue())
//		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
//		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
//		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
//
//		guard case let .feedback(content: feedback) = sut.viewState else {
//			fail("wrong state")
//			return
//		}
//
//		expect(feedback.title) == L.holderPositiveTestRecoveryAndVaccinationTitle()
//		expect(feedback.body) == L.holderPositiveTestRecoveryAndVaccinationMessage()
//		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
//		expect(feedback.secondaryActionTitle).to(beNil())
//	}
//
//	// MARK: - Success Paths Positive Tests -
//	
//	func test_successPositiveTest_domesticRecovery() throws {
//
//		// Given
//		sut = ListRemoteEventsViewModel(
//			coordinator: coordinatorSpy,
//			eventMode: .positiveTest,
//			remoteEvents: [FakeRemoteEvent.fakeRemoteEventPositiveTest],
//			greenCardLoader: greenCardLoader
//		)
//
//		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
//		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
//		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
//		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
//		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
//		(.success(RemoteGreenCards.Response.domesticAndInternationalRecovery), ())
//		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
//		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
//		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
//		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
//
//		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
//			fail("wrong state")
//			return
//		}
//
//		// When
//		content.primaryAction?()
//
//		// Then
//		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
//		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
//		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
//		expect(self.environmentSpies.walletManagerSpy.invokedStoreDomesticGreenCard).toEventually(beTrue())
//		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
//		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
//		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
//
//		guard case let .feedback(content: feedback) = sut.viewState else {
//			fail("wrong state")
//			return
//		}
//
//		expect(feedback.title) == L.holderPositiveTestRecoveryOnlyTitle()
//		expect(feedback.body) == L.holderPositiveTestRecoveryOnlyMessage()
//		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
//		expect(feedback.secondaryActionTitle).to(beNil())
//	}
//
//	func test_successPositiveTest_inapplicable() throws {
//
//		// Given
//		sut = ListRemoteEventsViewModel(
//			coordinator: coordinatorSpy,
//			eventMode: .positiveTest,
//			remoteEvents: [FakeRemoteEvent.fakeRemoteEventPositiveTest],
//			greenCardLoader: greenCardLoader
//		)
//
//		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
//		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
//		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
//		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
//		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
//		(.success(RemoteGreenCards.Response.domesticAndInternationalExpiredRecovery), ())
//		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
//		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
//		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
//		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
//
//		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
//			fail("wrong state")
//			return
//		}
//
//		// When
//		content.primaryAction?()
//
//		// Then
//		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
//		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
//		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
//		expect(self.environmentSpies.walletManagerSpy.invokedStoreDomesticGreenCard).toEventually(beTrue())
//		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
//		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
//		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
//
//		guard case let .feedback(content: feedback) = sut.viewState else {
//			fail("wrong state")
//			return
//		}
//
//		expect(feedback.title) == L.holderPositiveTestInapplicableTitle()
//		expect(feedback.body) == L.holderPositiveTestInapplicableMessage()
//		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
//		expect(feedback.secondaryActionTitle).to(beNil())
//	}
//
//	func test_successPositiveTest_domesticVaccination() throws {
//
//		// Given
//		sut = ListRemoteEventsViewModel(
//			coordinator: coordinatorSpy,
//			eventMode: .positiveTest,
//			remoteEvents: [FakeRemoteEvent.fakeRemoteEventPositiveTest],
//			greenCardLoader: greenCardLoader
//		)
//
//		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
//		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
//		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
//		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
//		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
//		(.success(RemoteGreenCards.Response.domesticAndInternationalVaccination), ())
//		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
//		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
//		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
//		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
//
//		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
//			fail("wrong state")
//			return
//		}
//
//		// When
//		content.primaryAction?()
//
//		// Then
//		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
//		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
//		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
//		expect(self.environmentSpies.walletManagerSpy.invokedStoreDomesticGreenCard).toEventually(beTrue())
//		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
//		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
//		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
//		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
//		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
//			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
//		expect(self.sut.alert).toEventually(beNil())
//	}

	// MARK: - Success Paths Recovery -
	
	func test_successRecovery_expired() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventRecovery],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalExpiredRecovery), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderEventOriginmismatchTitle()
		expect(feedback.body) == L.holderEventOriginmismatchRecoveryBody("i 380 000 058")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

	func test_successRecovery_domesticRecoveryAndVaccination() throws {

		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalVaccinationAndRecovery), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventRecovery],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderRecoveryRecoveryAndVaccinationTitle()
		expect(feedback.body) == L.holderRecoveryRecoveryAndVaccinationMessage()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

	func test_successRecovery_domesticRecoveryAndExistingVaccination() throws {

		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = true
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalVaccinationAndRecovery), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventRecovery],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_successRecovery_domesticVaccinationOnly() throws {

		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalExpiredRecoveryValidVaccination), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventRecovery],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderRecoveryVaccinationOnlyTitle()
		expect(feedback.body) == L.holderRecoveryVaccinationOnlyMessage()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

	func test_successRecovery_existingDomesticVaccinationOnly() throws {

		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = true
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalExpiredRecoveryValidVaccination), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventRecovery],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderEventOriginmismatchTitle()
		expect(feedback.body) == L.holderEventOriginmismatchRecoveryBody("i 380 000 058")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

	func test_successRecovery_recoveryOnly() throws {

		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalRecovery), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventRecovery],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}
	
	// MARK: - Success Paths Vaccination Assessment -
	
	func test_successVaccinationAssessment_domesticOnly() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticVaccinationAssessment), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccinationassessment,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccinationAssessment],
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
	
	func test_successVaccinationAssessment_bothVaccinationAssessmentAndNegativeTestOrigins() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticVaccinationAssessmentAndNegativeTest), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccinationassessment,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccinationAssessment],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}
	
	func test_successVaccinationAssessment_onlyNegativeTestOrigins() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalTest), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccinationassessment,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccinationAssessment],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).toEventually(beNil())
		expect(self.sut.alert).toEventually(beNil())
		
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holderEventOriginmismatchTitle()
		expect(feedback.body) == L.holderEventOriginmismatchVaccinationApprovalBody("i 980 000 058")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	func test_successVaccinationAssessment_noOrigins_existingNegativeTestEvent() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		let eventGroup = try XCTUnwrap(
			EventGroup.fakeEventGroup(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: EventMode.test,
				maxIssuedAt: now
			)
		)
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.noOrigins), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccinationassessment,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccinationAssessment],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).toEventually(beNil())
		expect(self.sut.alert).toEventually(beNil())
		
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holderEventOriginmismatchTitle()
		expect(feedback.body) == L.holderEventOriginmismatchVaccinationApprovalBody("i 980 000 058")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	func test_successVaccinationAssessment_noOrigins_noExistingNegativeTestEvent() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = []
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.noOrigins), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccinationassessment,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccinationAssessment],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}
	
	// MARK: - Success Paths Negative Test -
	
	func test_successNegativeTest() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalTest), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}
	
	func test_successNegativeTest_originalModeVaccinationAssessment() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalTest), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			originalMode: .vaccinationassessment,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.sut.alert).toEventually(beNil())
		
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holder_event_negativeTestEndstate_addVaccinationAssessment_title()
		expect(feedback.body) == L.holder_event_negativeTestEndstate_addVaccinationAssessment_body()
		expect(feedback.primaryActionTitle) == L.holder_event_negativeTestEndstate_addVaccinationAssessment_button_complete()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	func test_successNegativeTest_bothNegativeTestAndVaccinationAssessmentOrigins() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticVaccinationAssessmentAndNegativeTest), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_successNegativeTest_onlyVaccinationAssessmentOrigin() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticVaccinationAssessment), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest],
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
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
		expect(self.sut.alert).toEventually(beNil())
		
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holderEventOriginmismatchTitle()
		expect(feedback.body) == L.holderEventOriginmismatchTestBody("i 180 000 058")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	func test_successNegativeTest_noOrigins() throws {
		
		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.walletManagerSpy.stubbedHasDomesticGreenCardResult = false
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.noOrigins), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedGetStokenResult = "test"
		
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest],
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
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate).to(beNil())
		expect(self.sut.alert).toEventually(beNil())
		
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holderEventOriginmismatchTitle()
		expect(feedback.body) == L.holderEventOriginmismatchTestBody("i 180 000 058")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	// MARK: - Empty States -
	
	func test_emptyState_negativeTest() throws {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [],
			greenCardLoader: greenCardLoader
		)
		
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holderTestNolistTitle()
		expect(feedback.body) == L.holderTestNolistMessage()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	func test_emptyState_vaccinationAndPositiveTest() throws {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccinationAndPositiveTest,
			remoteEvents: [],
			greenCardLoader: greenCardLoader
		)
		
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holderPositiveTestNolistTitle()
		expect(feedback.body) == L.holderPositiveTestNolistMessage()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	func test_emptyState_paperflow() throws {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			remoteEvents: [],
			greenCardLoader: greenCardLoader
		)
		
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holderCheckdccExpiredTitle()
		expect(feedback.body) == L.holderCheckdccExpiredMessage()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	func test_emptyState_recovery() throws {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [],
			greenCardLoader: greenCardLoader
		)
		
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holderRecoveryNolistTitle()
		expect(feedback.body) == L.holderRecoveryNolistMessage()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	func test_emptyState_vaccinationAssessement() throws {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccinationassessment,
			remoteEvents: [],
			greenCardLoader: greenCardLoader
		)
		
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}
		
		expect(feedback.title) == L.holder_event_vaccination_assessment_nolist_title()
		expect(feedback.body) == L.holder_event_vaccination_assessment_nolist_message()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle).to(beNil())
	}
	
	// MARK: Helper

	private func remoteVaccinationEvent(providerIdentifier: String = "CC", vaccinationDate: String, hpkCode: String? = nil) -> RemoteEvent {

		let vaccinationEvent = EventFlow.VaccinationEvent(
			dateString: vaccinationDate,
			hpkCode: hpkCode,
			type: nil,
			manufacturer: nil,
			brand: nil,
			doseNumber: 1,
			totalDoses: 2,
			country: "NLD",
			completedByMedicalStatement: nil,
			completedByPersonalStatement: nil,
			completionReason: nil
		)
		return RemoteEvent(
			wrapper: EventFlow.EventResultWrapper(
				providerIdentifier: providerIdentifier,
				protocolVersion: "3.0",
				identity: EventFlow.Identity.fakeIdentity,
				status: .complete,
				result: nil,
				events: [
					EventFlow.Event(
						type: "vaccination",
						unique: "1234",
						isSpecimen: false,
						vaccination: vaccinationEvent,
						negativeTest: nil,
						positiveTest: nil,
						recovery: nil,
						dccEvent: nil,
						vaccinationAssessment: nil
					)
				]
			),
			signedResponse: SignedResponse.fakeResponse
		)
	}

	private var remotePaperFlowEvent: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper(
				providerIdentifier: EventFlow.paperproofIdentier,
				protocolVersion: "3.0",
				identity: EventFlow.Identity.fakeIdentity,
				status: .complete,
				result: nil,
				events: [
					EventFlow.Event(
						type: "paperFlow",
						unique: "1234",
						isSpecimen: false,
						vaccination: nil,
						negativeTest: nil,
						positiveTest: nil,
						recovery: nil,
						dccEvent: EventFlow.DccEvent(
							credential: CouplingManager.vaccinationDCC,
							couplingCode: "NDREB5"
						),
						vaccinationAssessment: nil
					)
				]
			),
			signedResponse: nil
		)
	}
}
