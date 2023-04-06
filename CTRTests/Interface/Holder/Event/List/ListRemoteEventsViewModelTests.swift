/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length
// swiftlint:disable file_length

@testable import CTR
@testable import Transport
@testable import Shared
import XCTest
import Nimble
import TestingShared
import Persistence
import ReusableViews
@testable import Models
@testable import Managers
@testable import Resources

class ListRemoteEventsViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: ListRemoteEventsViewModel!
	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var greenCardLoader: GreenCardLoader!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {

		super.setUp()

		environmentSpies = setupEnvironmentSpies()
		environmentSpies.identityCheckerSpy.stubbedCompareResult = true
		environmentSpies.cryptoManagerSpy.stubbedGenerateSecretKeyResult = Data()
		environmentSpies.contactInformationSpy.stubbedPhoneNumberLink = "<a href=\"tel:TEST\">TEST</a>"
		
		// Not using a GreenCardLoader Spy here - this is okay because all its dependencies are already spies.
		// Once GreenCardLoader has full code coverage, this can be replaced with a spy.
		greenCardLoader = GreenCardLoader(
			networkManager: environmentSpies.networkManagerSpy,
			cryptoManager: environmentSpies.cryptoManagerSpy,
			walletManager: environmentSpies.walletManagerSpy,
			secureUserSettings: environmentSpies.secureUserSettingsSpy
		)
 
		coordinatorSpy = EventCoordinatorDelegateSpy()
	}

	func setupSut() {
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [],
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
		expect(self.sut.alert) != nil
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
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) == EventScreenResult.back(eventMode: .test(.ggd))
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
		expect(self.sut.alert) != nil
	}

	func test_warnBeforeGoBack() {

		// Given
		setupSut()

		// When
		sut.warnBeforeGoBack()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
		expect(self.sut.alert) != nil
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
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
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
			eventMode: .test(.ggd),
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
			return
		}

		// Then
		expect(content.secondaryAction) == nil
		expect(content.secondaryActionTitle) == nil
	}

	func test_somethingIsWrong_foreignDccVaccination() {

		// Given
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.foreignFakeVaccination()
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			remoteEvents: [remotePaperFlowEvent],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When

		// Then
		expect(content.secondaryAction) == nil
		expect(content.secondaryActionTitle) == nil
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
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
			return
		}

		// Then
		expect(rows).to(haveCount(2))
	}

	func test_sixSimilarEvents_withHPKCode_twoRows() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [
				// Shot 1 in july, duplicate at GGD
				remoteVaccinationEvent(providerIdentifier: "RVV", vaccinationDate: "2021-07-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "GGD", vaccinationDate: "2021-07-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "ZZZ", vaccinationDate: "2021-07-02", hpkCode: "2924528"),
				// Shot 2 in august, duplicate at RIVM
				remoteVaccinationEvent(providerIdentifier: "GGD", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "RVV", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "ZZZ", vaccinationDate: "2021-08-02", hpkCode: "2924528")
			],
			greenCardLoader: greenCardLoader
		)

		// When
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// Then
		expect(rows).to(haveCount(2))
	}

	func test_sixSimilarEvents_withDuplicates_withHPKCode_twoRows() {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [
				// Shot 1 in july, duplicate at GGD
				remoteVaccinationEvent(providerIdentifier: "RVV", vaccinationDate: "2021-07-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "GGD", vaccinationDate: "2021-07-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "ZZZ", vaccinationDate: "2021-07-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "ZZZ", vaccinationDate: "2021-07-02", hpkCode: "2924528"),
				// Shot 2 in august, duplicate at RIVM
				remoteVaccinationEvent(providerIdentifier: "GGD", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "RVV", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "ZZZ", vaccinationDate: "2021-08-02", hpkCode: "2924528"),
				remoteVaccinationEvent(providerIdentifier: "ZZZ", vaccinationDate: "2021-08-02", hpkCode: "2924528")
			],
			greenCardLoader: greenCardLoader
		)

		// When
		guard case let .listEvents(content: _, rows: rows) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
			return
		}

		expect(feedback.title) == L.holderVaccinationNolistTitle()
		expect(feedback.body) == L.holderVaccinationNolistMessage()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == nil
	}

	func test_makeQR_saveEventGroupError_eventModeVaccination() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = nil

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards) == false
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.sut.alert) == nil

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 260 000 056")
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

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = nil

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards) == false
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.sut.alert) == nil

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 360 000 056")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupError_eventModeCommercialTest() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test(.commercial),
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = nil

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards) == false
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.sut.alert) == nil
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 160 000 056")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupError_eventModeGGDTest() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test(.ggd),
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = nil

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards) == false
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.sut.alert) == nil
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 460 000 056")
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

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = nil

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards) == false
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.sut.alert) == nil
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 960 000 056")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_storingNewEvent_isDraft() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedRemoveExistingEventGroupsTypeResult = 0
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = (.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response(euGreenCards: nil, blobExpireDates: nil, hints: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		expect(self.environmentSpies.walletManagerSpy.invokedStoreEventGroupParameters?.isDraft) == true

		// should not be any drafts left
	}

	func test_makeQR_saveEventGroupNoError_overwritingExistingNewEvent_isNotDraft() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedRemoveExistingEventGroupsTypeResult = 1
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = (.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response(euGreenCards: nil, blobExpireDates: nil, hints: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		expect(self.environmentSpies.walletManagerSpy.invokedStoreEventGroupParameters?.isDraft) == false
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_invalidResponse() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult = (.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response(euGreenCards: nil, blobExpireDates: nil, hints: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 270 000 003")
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

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response(euGreenCards: nil, blobExpireDates: nil, hints: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
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

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response(euGreenCards: nil, blobExpireDates: nil, hints: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.generalNetworkwasbusyTitle()
		expect(feedback.body) == L.generalNetworkwasbusyErrorcode("i 270 000 429")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_noInternet() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
		(.failure(ServerError.error(statusCode: 429, response: nil, error: .noInternetConnection)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response(euGreenCards: nil, blobExpireDates: nil, hints: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
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
		expect(self.sut.alert?.cancelAction?.title).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okAction.title).toEventually(equal( L.generalRetry()))
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == nil
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_invalidSignature() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response(euGreenCards: nil, blobExpireDates: nil, hints: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 270 000 020")
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

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99857), error: .serverError)), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response(euGreenCards: nil, blobExpireDates: nil, hints: nil)), ())

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
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
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateServerMessage("i 270 000 500 99857")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_prepareIssueError_invalidEnveloppe() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "Wrong", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
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
		expect(self.sut.alert) == nil
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 270 000 053")
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

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
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
		expect(self.sut.alert) == nil
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 280 000 003")
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

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.failure(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == nil
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
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

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.failure(ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == nil
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
		expect(self.sut.alert?.cancelAction?.title).toEventually(equal(L.generalClose()))
		expect(self.sut.alert?.okAction.title).toEventually(equal( L.generalRetry()))
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == nil
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveDraftEventGroups) == false
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_serverBusy() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .serverBusy)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == nil
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.generalNetworkwasbusyTitle()
		expect(feedback.body) == L.generalNetworkwasbusyErrorcode("i 280 000 429")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_invalidSignature() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.failure(ServerError.error(statusCode: 429, response: nil, error: .invalidSignature)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == nil
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 280 000 020")
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

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
		(.failure(ServerError.error(statusCode: 429, response: nil, error: .authenticationCancelled)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == nil
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 280 000 010")
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

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.failure(ServerError.error(statusCode: 500, response: ServerResponse(status: "error", code: 99857), error: .serverError)), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == nil
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())

		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateServerMessage("i 280 000 500 99857")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_noSignedEvents() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = []
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beFalse())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == nil
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveDraftEventGroups).toEventually(beTrue())

		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.generalErrorTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.holderFetcheventsErrorNoresultsNetworkerrorMessage("vaccinatie")))
		expect(self.sut.alert?.cancelAction?.title).toEventually(equal(L.holderVaccinationErrorClose()))
		expect(self.sut.alert?.okAction.title).toEventually(equal( L.holderVaccinationErrorAgain()))
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsError_failedToGenerateCommitmentMessage() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response.domesticAndInternationalVaccination), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = nil

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beFalse())
		expect(self.environmentSpies.networkManagerSpy.invokedPrepareIssue).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beFalse())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == nil
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.sut.alert) == nil
		let params = try XCTUnwrap(coordinatorSpy.invokedListEventsScreenDidFinishParameters)
		guard case let EventScreenResult.error(content: feedback, backAction: _) = params.0 else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		expect(feedback.title) == L.holderErrorstateTitle()
		expect(feedback.body) == L.holderErrorstateClientMessage("i 270 000 054")
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
	}
	
	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveGreencardNoError() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
			environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response.domesticAndInternationalVaccination), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .vaccination)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveGreencardNoError_receivedHints() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
			environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response.domesticAndInternationalVaccinationWithHint), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.showHints(NonemptyArray(["some_test_hint_key"])!, eventMode: EventMode.vaccination)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_makeQR_saveEventGroupNoError_fetchGreencardsNoError_saveGreencardNoError_multipleDCC() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.multipleDCC), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .vaccination)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_makeQR_paperflow_vaccination() throws {

		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response.domesticAndInternationalVaccination), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			remoteEvents: [remotePaperFlowEvent],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .paperflow)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_makeQR_paperflow_recovery() throws {

		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response.domesticAndInternationalVaccination), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fake(dcc: EuCredentialAttributes.DigitalCovidCertificate.sampleWithRecovery())

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			remoteEvents: [remotePaperFlowEvent],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .paperflow)))
		expect(self.sut.alert).toEventually(beNil())
	}

	func test_makeQR_paperflow_test() throws {

		// Given
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult =
			(.success(RemoteGreenCards.Response.domesticAndInternationalVaccination), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fake(dcc: EuCredentialAttributes.DigitalCovidCertificate.sampleWithTest())

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			remoteEvents: [remotePaperFlowEvent],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .paperflow)))
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
		expect(self.sut.alert?.cancelAction?.title) == nil
		expect(self.sut.alert?.okAction.title).toEventually(equal( L.generalOk()))
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == nil
	}

	func test_identityMismatched() {

		// Given
		environmentSpies.identityCheckerSpy.stubbedCompareResult = false
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: environmentSpies.greenCardLoaderSpy
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.sut.alert).toEventuallyNot(beNil())
		expect(self.sut.alert?.title).toEventually(equal(L.holderEventIdentityAlertTitle()))
		expect(self.sut.alert?.subTitle).toEventually(equal(L.holderEventIdentityAlertMessage()))
		expect(self.sut.alert?.cancelAction?.title).toEventually(equal(L.holderEventIdentityAlertCancel()))
		expect(self.sut.alert?.okAction.title).toEventually(equal( L.holderEventIdentityAlertOk()))
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == nil
	}

	func test_duplicateDCC() throws {

		// Given
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()
		let eventGroup = try XCTUnwrap(createEventGroup(wrapper: EventFlow.EventResultWrapper.fakeNegativeTestResultWrapper))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			remoteEvents: [remotePaperFlowEvent],
			greenCardLoader: greenCardLoader
		)
		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		expect(feedback.title) == L.holder_listRemoteEvents_endStateDuplicate_title()
		expect(feedback.body) == L.holder_listRemoteEvents_endStateDuplicate_message()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == nil
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

	// MARK: - Success Path -

	func test_successVaccination_internationalQROnly_zeroDisclosePolicies() throws {

		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		environmentSpies.featureFlagManagerSpy.stubbedAreZeroDisclosurePoliciesEnabledResult = true
		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.internationalVaccination), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// When
		content.primaryAction?()

		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroupsType) == true
		expect(self.environmentSpies.networkManagerSpy.invokedFetchGreencards).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedStoreEuGreenCard).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedLastSuccessfulCompletionOfAddCertificateFlowDate) == now
		expect(self.environmentSpies.secureUserSettingsSpy.invokedHolderSecretKeySetter) == true
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0)
			.toEventually(equal(EventScreenResult.continue(eventMode: .vaccination)))
		expect(self.sut.alert).toEventually(beNil())
	}

	// MARK: - Blocked State -

	// 1. - Add a single DCC that is blocked: show blocked end-state

	func test_singleDCC_whichIsBlocked_showsAnEndState() throws {

		// Arrange

		let fakeEventGroup: EventGroup = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)!

		// Save context to order to generate predictable unique identifier:
		let context = environmentSpies.dataStoreManager.managedObjectContext()
		environmentSpies.dataStoreManager.save(context)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = fakeEventGroup
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [fakeEventGroup]
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.internationalBlockedVaccination(blockedIdentifier: fakeEventGroup.uniqueIdentifier)), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventPaperProof],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// Act
		content.primaryAction?()

		// Assert
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())

		let feedback: Content? = eventuallyUnwrap(eval: { () -> Content? in
			if case let ListRemoteEventsViewController.State.feedback(content: feedback) = self.sut.viewState {
				return feedback
			}
			return nil
		})

		expect(feedback?.title) == L.holder_listRemoteEvents_endStateNoValidCertificate_title()
		expect(feedback?.body) == L.holder_listRemoteEvents_endStateNoValidCertificate_body(
			"<a href=\"tel:TEST\">TEST</a>", "i 580 000 0514")
		expect(self.environmentSpies.contactInformationSpy.invokedPhoneNumberLinkGetter) == true
		expect(feedback?.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback?.secondaryActionTitle) == nil
		expect(self.environmentSpies.userSettingsSpy.invokedHasShownBlockedEventsAlertSetterCount) == 0
	}

	// 2. - Have a DCC in database (which is server-side blocked), send a vaccination: persist to DB, no end-state

	func test_singleDCC_whichIsBlockedRemotely_tryToAddVaccination_insertsBlockedEvent() throws {

		// Arrange

		let fakeExistingEventGroup: EventGroup = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)!
		let fakeIncomingEventGroup: EventGroup = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)!

		// Save context to order to generate predictable unique identifier:
		let context = environmentSpies.dataStoreManager.managedObjectContext()
		environmentSpies.dataStoreManager.save(context)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = fakeIncomingEventGroup
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [fakeExistingEventGroup, fakeIncomingEventGroup]
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.internationalBlockedExistingVaccinationWhilstAddingVaccination(blockedIdentifierForExistingVaccination: fakeExistingEventGroup.uniqueIdentifier)), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventVaccination],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// Act
		content.primaryAction?()

		// Assert

		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beTrue())
		expect(self.environmentSpies.walletManagerSpy.invokedCreateAndPersistRemovedEventBlockItem).toEventually(beTrue())
		expect(self.environmentSpies.userSettingsSpy.invokedHasShownBlockedEventsAlert) == false // invoked with `false`
		expect(self.environmentSpies.userSettingsSpy.invokedHasShownBlockedEventsAlertSetterCount) == 1 // once
	}

	// 3. - Have a DCC in database (which is server-side blocked), send a DCC vaccination which is blocked: persist to DB and show blocked end-state

	func test_singleDCC_whichIsBlockedRemotely_tryToAddBlockedVaccination_insertsBlockedEventAndShowsEndState() throws {

		// Arrange

		let fakeExistingEventGroup: EventGroup = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)!
		let fakeIncomingEventGroup: EventGroup = try EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture)!

		// Save context to order to generate predictable unique identifier:
		let context = environmentSpies.dataStoreManager.managedObjectContext()
		environmentSpies.dataStoreManager.save(context)

		environmentSpies.walletManagerSpy.stubbedStoreEventGroupResult = fakeIncomingEventGroup
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [fakeExistingEventGroup, fakeIncomingEventGroup]
		environmentSpies.walletManagerSpy.stubbedStoreEuGreenCardResult = true
		environmentSpies.walletManagerSpy.stubbedFetchSignedEventsResult = ["test"]
		environmentSpies.networkManagerSpy.stubbedFetchGreencardsCompletionResult = (.success(RemoteGreenCards.Response.internationalBlockedExistingVaccinationWhilstAddingVaccination(blockedIdentifierForExistingVaccination: fakeExistingEventGroup.uniqueIdentifier, blockedIdentifierForNewVaccination: fakeIncomingEventGroup.uniqueIdentifier)), ())
		environmentSpies.networkManagerSpy.stubbedPrepareIssueCompletionResult =
			(.success(PrepareIssueEnvelope(prepareIssueMessage: "VGVzdA==", stoken: "test")), ())
		environmentSpies.cryptoManagerSpy.stubbedGenerateCommitmentMessageResult = "test"
		environmentSpies.cryptoManagerSpy.stubbedReadEuCredentialsResult = EuCredentialAttributes.fakeVaccination()

		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .paperflow,
			remoteEvents: [FakeRemoteEvent.fakeRemoteEventPaperProof],
			greenCardLoader: greenCardLoader
		)

		guard case let .listEvents(content: content, rows: _) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}

		// Act
		content.primaryAction?()

		// Assert

		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish).toEventually(beFalse())
		expect(self.environmentSpies.walletManagerSpy.invokedCreateAndPersistRemovedEventBlockItem).toEventually(beTrue())

		let feedback: Content? = eventuallyUnwrap(eval: { () -> Content? in
			if case let ListRemoteEventsViewController.State.feedback(content: feedback) = self.sut.viewState {
				return feedback
			}
			return nil
		})
		expect(feedback?.title) == L.holder_listRemoteEvents_endStateNoValidCertificate_title()
		expect(feedback?.body) == L.holder_listRemoteEvents_endStateNoValidCertificate_body(
			"<a href=\"tel:TEST\">TEST</a>", "i 580 000 0514")
		expect(self.environmentSpies.contactInformationSpy.invokedPhoneNumberLinkGetter) == true
		expect(feedback?.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback?.secondaryActionTitle) == nil
		expect(self.environmentSpies.userSettingsSpy.invokedHasShownBlockedEventsAlert) == false // invoked with `false`
		expect(self.environmentSpies.userSettingsSpy.invokedHasShownBlockedEventsAlertSetterCount) == 1 // once
	}
	
	// MARK: - Empty States -
	
	func test_emptyState_negativeTest() throws {
		
		// Given
		sut = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: .test(.ggd),
			remoteEvents: [],
			greenCardLoader: greenCardLoader
		)
		
		guard case let .feedback(content: feedback) = sut.viewState else {
			fail("wrong state: \(sut.viewState)")
			return
		}
		
		expect(feedback.title) == L.holderTestNolistTitle()
		expect(feedback.body) == L.holderTestNolistMessage()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == nil
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
			fail("wrong state: \(sut.viewState)")
			return
		}
		
		expect(feedback.title) == L.holderVaccinationNolistTitle()
		expect(feedback.body) == L.holderVaccinationNolistMessage()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == nil
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
			fail("wrong state: \(sut.viewState)")
			return
		}
		
		expect(feedback.title) == L.holderCheckdccExpiredTitle()
		expect(feedback.body) == L.holderCheckdccExpiredMessage()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == nil
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
			fail("wrong state: \(sut.viewState)")
			return
		}
		
		expect(feedback.title) == L.holderRecoveryNolistTitle()
		expect(feedback.body) == L.holderRecoveryNolistMessage()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == nil
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
			fail("wrong state: \(sut.viewState)")
			return
		}
		
		expect(feedback.title) == L.holder_event_vaccination_assessment_nolist_title()
		expect(feedback.body) == L.holder_event_vaccination_assessment_nolist_message()
		expect(feedback.primaryActionTitle) == L.general_toMyOverview()
		expect(feedback.secondaryActionTitle) == nil
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
	
	private func createEventGroup(wrapper: EventFlow.EventResultWrapper) -> EventGroup? {

		var eventGroup: EventGroup?
		if let payloadData = try? JSONEncoder().encode(wrapper) {
		   let base64String = payloadData.base64EncodedString()
			let signedResponse = SignedResponse(payload: base64String, signature: "does not matter for this test")
			let context = environmentSpies.dataStoreManager.managedObjectContext()
			context.performAndWait {
				if let wallet = WalletModel.createTestWallet(managedContext: context),
				   let jsonData = try? JSONEncoder().encode(signedResponse) {
					eventGroup = EventGroup(
						type: EventMode.recovery,
						providerIdentifier: "DCC-1234",
						expiryDate: nil,
						jsonData: jsonData,
						wallet: wallet,
						isDraft: false,
						managedContext: context
					)
				}
			}
		}
		return eventGroup
	}
}
