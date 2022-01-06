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

class ListEventsViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: ListEventsViewModel!
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
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [],
			identityChecker: IdentityChecker(),
			greenCardLoader: greenCardLoader
		)
	}

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

	func test_vaccinationrow_actionTapped() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
				title: L.holderVaccinationWrongTitle(),
				body: L.holderVaccinationWrongBody(),
				hideBodyForScreenCapture: false
			)
	}

	func test_somethingIsWrong_recovery_tapped() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [fakeRemoteEventRecovery],
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
				title: L.holderVaccinationWrongTitle(),
				body: L.holderRecoveryWrongBody(),
				hideBodyForScreenCapture: false
			)
	}

	func test_somethingIsWrong_positiveTest_tapped() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .positiveTest,
			remoteEvents: [fakeRemoteEventPositiveTest],
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
				title: L.holderVaccinationWrongTitle(),
				body: L.holderTestresultsWrongBody(),
				hideBodyForScreenCapture: false
			)
	}

	func test_somethingIsWrong_negativeTest_tapped() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [fakeRemoteEventNegativeTest],
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
				title: L.holderVaccinationWrongTitle(),
				body: L.holderTestresultsWrongBody(),
				hideBodyForScreenCapture: false
			)
	}

	func test_somethingIsWrong_dccVaccination_notAvailable() {

		// Given
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()
		sut = ListEventsViewModel(
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

	func test_oneEvent_oneRow() {

		// Given
		sut = ListEventsViewModel(
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
		sut = ListEventsViewModel(
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
		sut = ListEventsViewModel(
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
		sut = ListEventsViewModel(
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
		sut = ListEventsViewModel(
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
		sut = ListEventsViewModel(
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
		sut = ListEventsViewModel(
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
		sut = ListEventsViewModel(
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
		sut = ListEventsViewModel(
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

	func test_makeQR_invalidMode() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventNegativeTest],
			greenCardLoader: greenCardLoader
		)

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderVaccinationNolistTitle()
		expect(feedback.subTitle) == L.holderVaccinationNolistMessage()
		expect(feedback.primaryActionTitle) == L.holderVaccinationNolistAction()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

	func test_makeQR_saveEventGroupError_eventModeVaccination() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(feedback.subTitle) == L.holderErrorstateClientMessage("i 260 CC 056")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupError_eventModeRecovery() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [fakeRemoteEventRecovery],
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
		expect(feedback.subTitle) == L.holderErrorstateClientMessage("i 360 CC 056")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupError_eventModeTest() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test,
			remoteEvents: [fakeRemoteEventNegativeTest],
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
		expect(feedback.subTitle) == L.holderErrorstateClientMessage("i 160 CC 056")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_invalidResponse() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(feedback.subTitle) == L.holderErrorstateClientMessage("i 270 CC 003")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_requestTimeOut() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(feedback.subTitle) == L.generalErrorServerUnreachableErrorCode("i 270 000 004")
		expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_serverBusy() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(feedback.subTitle) == L.generalNetworkwasbusyErrorcode("i 270 000 429")
		expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_invalidSignature() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(feedback.subTitle) == L.holderErrorstateClientMessage("i 270 CC 020")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_serverError() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(feedback.subTitle) == L.holderErrorstateServerMessage("i 270 CC 500 99857")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_invalidResponse() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(feedback.subTitle) == L.holderErrorstateClientMessage("i 280 CC 003")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_requestTimedOut() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.subTitle) == L.generalErrorServerUnreachableErrorCode("i 280 000 004")
		expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_serverBusy() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.generalNetworkwasbusyTitle()
		expect(feedback.subTitle) == L.generalNetworkwasbusyErrorcode("i 280 000 429")
		expect(feedback.primaryActionTitle) == L.generalNetworkwasbusyButton()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_invalidSignature() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.subTitle) == L.holderErrorstateClientMessage("i 280 CC 020")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_serverError() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.subTitle) == L.holderErrorstateServerMessage("i 280 CC 500 99857")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveDomesticGreencardError() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.sut.alert).to(beNil())
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.subTitle) == L.holderErrorstateClientMessage("i 290 CC 055")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveGreencard_noOrigins() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveGreencardNoError() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveGreencardNoError_multipleDCC() {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_makeQR_paperflow() {

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
		
		sut = ListEventsViewModel(
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_someEventsMightBeMissing() {

		// Given

		// When
		sut = ListEventsViewModel(
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
	}

	func test_greencardLoaderReturnsPreparingIssueError() throws {

		// Given
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.preparingIssue(.error(statusCode: nil, response: nil, error: .invalidSignature))), ())
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true

		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(feedback.subTitle) == L.holderErrorstateClientMessage("i 270 CC 020")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_greencardLoaderReturnsFailedToParsePrepareIssue() throws {

		// Given
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToParsePrepareIssue), ())
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true

		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(feedback.subTitle) == L.holderErrorstateClientMessage("i 270 CC 053")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_greencardLoaderReturnsFailedToGenerateCommitmentMessage() throws {

		// Given
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToGenerateCommitmentMessage), ())
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true

		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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
		expect(feedback.subTitle) == L.holderErrorstateClientMessage("i 270 CC 054")
		expect(feedback.primaryActionTitle) == L.holderErrorstateOverviewAction()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

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

	func test_successVaccination_internationalQROnly() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [fakeRemoteEventVaccination],
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

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderVaccinationInternationlQROnlyTitle()
		expect(feedback.subTitle) == L.holderVaccinationInternationlQROnlyMessage()
		expect(feedback.primaryActionTitle) == L.holderVaccinationNolistAction()
		expect(feedback.secondaryActionTitle) == L.holderVaccinationInternationlQROnlyAction()
	}

	func test_successPositiveTest_domesticVaccination_domesticRecovery() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .positiveTest,
			remoteEvents: [fakeRemoteEventPositiveTest],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalVaccinationAndRecovery), ())
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

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderPositiveTestRecoveryAndVaccinationTitle()
		expect(feedback.subTitle) == L.holderPositiveTestRecoveryAndVaccinationMessage()
		expect(feedback.primaryActionTitle) == L.holderPositiveTestRecoveryAndVaccinationAction()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

	func test_successPositiveTest_domesticRecovery() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .positiveTest,
			remoteEvents: [fakeRemoteEventPositiveTest],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedStoreDomesticGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.success(RemoteGreenCards.Response.domesticAndInternationalRecovery), ())
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

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderPositiveTestRecoveryOnlyTitle()
		expect(feedback.subTitle) == L.holderPositiveTestRecoveryOnlyMessage()
		expect(feedback.primaryActionTitle) == L.holderPositiveTestRecoveryOnlyAction()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

	func test_successPositiveTest_inapplicable() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .positiveTest,
			remoteEvents: [fakeRemoteEventPositiveTest],
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

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderPositiveTestInapplicableTitle()
		expect(feedback.subTitle) == L.holderPositiveTestInapplicableMessage()
		expect(feedback.primaryActionTitle) == L.holderPositiveTestInapplicableAction()
		expect(feedback.secondaryActionTitle).to(beNil())
	}

	func test_successPositiveTest_domesticVaccination() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .positiveTest,
			remoteEvents: [fakeRemoteEventPositiveTest],
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_successRecovery_expired() throws {

		// Given
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [fakeRemoteEventRecovery],
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

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderRecoveryTooOldTitle()
		expect(feedback.subTitle) == L.holderRecoveryTooOldMessage()
		expect(feedback.primaryActionTitle) == L.holderTestNolistAction()
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

		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [fakeRemoteEventRecovery],
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

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderRecoveryRecoveryAndVaccinationTitle()
		expect(feedback.subTitle) == L.holderRecoveryRecoveryAndVaccinationMessage()
		expect(feedback.primaryActionTitle) == L.holderRecoveryRecoveryAndVaccinationAction()
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

		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [fakeRemoteEventRecovery],
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

		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [fakeRemoteEventRecovery],
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

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderRecoveryVaccinationOnlyTitle()
		expect(feedback.subTitle) == L.holderRecoveryVaccinationOnlyMessage()
		expect(feedback.primaryActionTitle) == L.holderRecoveryVaccinationOnlyAction()
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

		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [fakeRemoteEventRecovery],
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

		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state")
			return
		}

		expect(feedback.title) == L.holderRecoveryTooOldTitle()
		expect(feedback.subTitle) == L.holderRecoveryTooOldMessage()
		expect(feedback.primaryActionTitle) == L.holderRecoveryNolistAction()
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

		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .recovery,
			remoteEvents: [fakeRemoteEventRecovery],
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .test)))
		expect(self.sut.alert).toEventually(beNil())
	}

	// MARK: Default values

	private var fakeRemoteEventVaccination: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
	}

	private var fakeRemoteEventRecovery: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeRecoveryResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
	}

	private var fakeRemoteEventPositiveTest: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakePositiveTestResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
	}

	private var fakeRemoteEventNegativeTest: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeNegativeTestResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
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
						assessment: nil
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
						assessment: nil
					)
				]
			),
			signedResponse: nil
		)
	}
}
