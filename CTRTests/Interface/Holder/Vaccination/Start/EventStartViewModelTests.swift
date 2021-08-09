/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import Nimble

class EventStartViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: EventStartViewModel!

	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var remoteConfigManagingSpy: RemoteConfigManagingSpy!
	private let remoteConfig = RemoteConfiguration(
		minVersion: "1.0",
		minVersionMessage: "test message",
		storeUrl: URL(string: "https://apple.com"),
		deactivated: nil,
		informationURL: nil,
		configTTL: 3600,
		recoveryWaitingPeriodDays: 11,
		requireUpdateBefore: nil,
		temporarilyDisabled: false,
		domesticValidityHours: 40,
		vaccinationEventValidity: 14600,
		recoveryEventValidity: 7300,
		testEventValidity: 40,
		isGGDEnabled: true,
		recoveryExpirationDays: 180,
		credentialRenewalDays: 5,
		domesticQRRefreshSeconds: 60,
		universalLinkPermittedDomains: nil
	)

	override func setUp() {

		super.setUp()

		coordinatorSpy = EventCoordinatorDelegateSpy()
		remoteConfigManagingSpy = RemoteConfigManagingSpy(networkManager: NetworkSpy())
		remoteConfigManagingSpy.stubbedGetConfigurationResult = remoteConfig
		sut = EventStartViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination,
			remoteConfigManager: remoteConfigManagingSpy
		)
	}

	func test_content_vaccinationMode() {

		// Given

		// When

		// Then
		expect(self.sut.title) == L.holderVaccinationStartTitle()
		expect(self.sut.message) == L.holderVaccinationStartMessage()
	}

	func test_content_recoveryMode() {

		// Given
		sut = EventStartViewModel(coordinator: coordinatorSpy, eventMode: .recovery)
		// When

		// Then
		expect(self.sut.title) == L.holderRecoveryStartTitle()
		expect(self.sut.message) == L.holderRecoveryStartMessage("\(remoteConfig.recoveryWaitingPeriodDays!)")
	}

	func test_backButtonTapped() {

		// Given

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .back(eventMode: .test)
	}

	func test_primaryButtonTapped_vaccinationMode() {

		// Given

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .continue(value: nil, eventMode: .vaccination)
	}

	func test_primaryButtonTapped_recoveryMode() {

		// Given
		sut = EventStartViewModel(coordinator: coordinatorSpy, eventMode: .recovery)

		// When
		sut.primaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedEventStartScreenDidFinishParameters?.0) == .continue(value: nil, eventMode: .recovery)
	}

	func test_openUrl() throws {

		// Given
		let url = try XCTUnwrap(URL(string: "https://coronacheck.nl"))

		// When
		sut.openUrl(url)

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.0) == url
	}
}
