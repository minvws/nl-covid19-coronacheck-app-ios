/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import SnapshotTesting
import ViewControllerPresentationSpy

class ListRemoteEventsViewControllerTests: XCTestCase {
	
	// MARK: Subject under test
	private var sut: ListRemoteEventsViewController!
	private var viewModel: ListRemoteEventsViewModel!
	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var greenCardLoader: GreenCardLoader!
	private var environmentSpies: EnvironmentSpies!
	private var identityCheckerSpy: IdentityCheckerSpy!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		identityCheckerSpy = IdentityCheckerSpy()
		identityCheckerSpy.stubbedCompareResult = true
		
		greenCardLoader = GreenCardLoader(
			now: { now },
			networkManager: environmentSpies.networkManagerSpy,
			cryptoManager: environmentSpies.cryptoManagerSpy,
			walletManager: environmentSpies.walletManagerSpy,
			remoteConfigManager: environmentSpies.remoteConfigManagerSpy,
			userSettings: environmentSpies.userSettingsSpy
		)
		
		coordinatorSpy = EventCoordinatorDelegateSpy()
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func setupSut(eventMode: EventMode, remoteEvents: [RemoteEvent]) {
		
		viewModel = ListRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			eventMode: eventMode,
			remoteEvents: remoteEvents,
			identityChecker: identityCheckerSpy,
			greenCardLoader: greenCardLoader
		)
		sut = ListRemoteEventsViewController(viewModel: viewModel)
	}

	// MARK: - Tests

	func test_viewStateFeedback_empty_vaccatination() {
		
		// Given
		setupSut(eventMode: .vaccination, remoteEvents: [])
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holderVaccinationNolistTitle()
		expect(self.sut.sceneView.message) == L.holderVaccinationNolistMessage()
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_viewStateEvents_negativeTest() {
		
		// Given
		setupSut(eventMode: .test, remoteEvents: [FakeRemoteEvent.fakeRemoteEventNegativeTest])
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_listRemoteEvents_title()
		expect(self.sut.sceneView.message) == L.holder_listRemoteEvents_negativeTest_message()
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_viewStateLoading() {

		// Given
		setupSut(eventMode: .vaccination, remoteEvents: [])
		loadView()

		// When
		sut.viewModel.viewState = .loading(content: Content(title: "View state: loading"))

		// Then
		expect(self.sut.sceneView.title) == "View state: loading"
		expect(self.sut.sceneView.message) == ""

		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_viewStateLoading_backButtonTapped() {
		
		// Given
		setupSut(eventMode: .vaccination, remoteEvents: [])
		loadView()
		sut.viewModel.viewState = .loading(content: Content(title: "View state: loading"))
		let alertVerifier = AlertVerifier()
		
		// When
		sut.backButtonTapped()
		
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
		alertVerifier.verify(
			title: L.holderVaccinationAlertTitle(),
			message: L.holder_vaccination_alert_message(),
			animated: true,
			actions: [
				.default(L.holderVaccinationAlertContinue()),
				.destructive(L.holderVaccinationAlertStop())
			],
			presentingViewController: sut
		)
	}
	
	func test_viewStateFeedback_backButtonTapped() {
		
		// Given
		setupSut(eventMode: .vaccination, remoteEvents: [])
		loadView()
		
		// When
		sut.backButtonTapped()
		
		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
	}
}
