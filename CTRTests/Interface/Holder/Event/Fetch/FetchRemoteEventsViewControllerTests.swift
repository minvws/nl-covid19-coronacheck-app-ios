/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import SnapshotTesting
import ViewControllerPresentationSpy
import Shared

class FetchRemoteEventsViewControllerTests: XCTestCase {
	
	// MARK: Subject under test
	private var sut: FetchRemoteEventsViewController!
	private var viewModel: FetchRemoteEventsViewModel!
	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var environmentSpies: EnvironmentSpies!
	
	var window = UIWindow()
	
	// MARK: Test lifecycle
	override func setUp() {
		
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = EventCoordinatorDelegateSpy()
		window = UIWindow()
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func setupSut(eventMode: EventMode, authenticationMode: AuthenticationMode) {
		
		viewModel = FetchRemoteEventsViewModel(
			coordinator: coordinatorSpy,
			token: "test",
			authenticationMode: authenticationMode,
			eventMode: eventMode
		)
		sut = FetchRemoteEventsViewController(viewModel: viewModel)
	}

	// MARK: - Tests

	func test_loadingState() {

		// Given
		setupSut(eventMode: .vaccination, authenticationMode: .manyAuthenticationExchange)
		viewModel.viewState = .loading(content: Content(title: L.holder_fetchRemoteEvents_title()))
		
		// When
		loadView()

		// Then
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_backActionWarning_vaccination() {
		
		// Given
		setupSut(eventMode: .vaccination, authenticationMode: .manyAuthenticationExchange)
		viewModel.viewState = .loading(content: Content(title: L.holder_fetchRemoteEvents_title()))
		let alertVerifier = AlertVerifier()
		loadView()
		
		// When
		sut.backButtonTapped()
		
		// Then
		alertVerifier.verify(
			title: L.holderVaccinationAlertTitle(),
			message: L.holder_vaccination_alert_message(),
			animated: true,
			actions: [
				.default(L.holderVaccinationAlertContinue()),
				.cancel(L.holderVaccinationAlertStop())
			]
		)
	}
	
	func test_backActionWarning_test() {
		
		// Given
		setupSut(eventMode: .test(.ggd), authenticationMode: .manyAuthenticationExchange)
		viewModel.viewState = .loading(content: Content(title: L.holder_fetchRemoteEvents_title()))
		let alertVerifier = AlertVerifier()
		loadView()
		
		// When
		sut.backButtonTapped()
		
		// Then
		alertVerifier.verify(
			title: L.holderVaccinationAlertTitle(),
			message: L.holder_test_alert_message(),
			animated: true,
			actions: [
				.default(L.holderVaccinationAlertContinue()),
				.cancel(L.holderVaccinationAlertStop())
			]
		)
	}
	
	func test_backActionWarning_paperflow() {
		
		// Given
		setupSut(eventMode: .paperflow, authenticationMode: .manyAuthenticationExchange)
		viewModel.viewState = .loading(content: Content(title: L.holder_fetchRemoteEvents_title()))
		let alertVerifier = AlertVerifier()
		loadView()
		
		// When
		sut.backButtonTapped()
		
		// Then
		alertVerifier.verify(
			title: L.holderVaccinationAlertTitle(),
			message: L.holder_dcc_alert_message(),
			animated: true,
			actions: [
				.default(L.holderVaccinationAlertContinue()),
				.cancel(L.holderVaccinationAlertStop())
			]
		)
	}
	
	func test_backActionWarning_recovery() {
		
		// Given
		setupSut(eventMode: .recovery, authenticationMode: .manyAuthenticationExchange)
		viewModel.viewState = .loading(content: Content(title: L.holder_fetchRemoteEvents_title()))
		let alertVerifier = AlertVerifier()
		loadView()
		
		// When
		sut.backButtonTapped()
		
		// Then
		alertVerifier.verify(
			title: L.holderVaccinationAlertTitle(),
			message: L.holder_recovery_alert_message(),
			animated: true,
			actions: [
				.default(L.holderVaccinationAlertContinue()),
				.cancel(L.holderVaccinationAlertStop())
			]
		)
	}
	
	func test_backActionWarning_vaccinationassessment() {
		
		// Given
		setupSut(eventMode: .vaccinationassessment, authenticationMode: .manyAuthenticationExchange)
		viewModel.viewState = .loading(content: Content(title: L.holder_fetchRemoteEvents_title()))
		let alertVerifier = AlertVerifier()
		loadView()
		
		// When
		sut.backButtonTapped()
		
		// Then
		alertVerifier.verify(
			title: L.holderVaccinationAlertTitle(),
			message: L.holder_event_vaccination_assessment_alert_message(),
			animated: true,
			actions: [
				.default(L.holderVaccinationAlertContinue()),
				.cancel(L.holderVaccinationAlertStop())
			]
		)
	}
}
