/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckTest
import CoronaCheckUI
@testable import CTR
import ViewControllerPresentationSpy

class LaunchViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: LaunchViewController!
	private var appCoordinatorSpy: AppCoordinatorSpy!
	private var environmentSpies: EnvironmentSpies!
	private var alertVerifier: AlertVerifier?
	
	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		alertVerifier = AlertVerifier()
		appCoordinatorSpy = AppCoordinatorSpy()

		let viewModel = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			flavor: AppFlavor.holder
		)

		sut = LaunchViewController(viewModel: viewModel)
		window = UIWindow()
	}
	
	override func tearDown() {
		super.tearDown()
		alertVerifier = nil
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: Test

	/// Test all the content
	func test_content() {

		// Given

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.message) == L.holderLaunchText()

		sut.assertImage()
	}

	func test_showJailBreakAlert() {

		// Given
		environmentSpies.userSettingsSpy.stubbedJailbreakWarningShown = false
		environmentSpies.userSettingsSpy.stubbedDeviceAuthenticationWarningShown = false
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = true
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = true

		let viewModel = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			flavor: AppFlavor.holder
		)
		sut = LaunchViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		alertVerifier?.verify(
			title: L.jailbrokenTitle(),
			message: L.jailbrokenMessage(),
			animated: true,
			actions: [
				.default(L.generalOk())
			],
			presentingViewController: sut
		)

		sut.assertImage()
	}

	func test_showJailBreakAlertAction() throws {

		// Given
		environmentSpies.userSettingsSpy.stubbedJailbreakWarningShown = false
		environmentSpies.userSettingsSpy.stubbedDeviceAuthenticationWarningShown = false
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = true
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = true

		let viewModel = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			flavor: AppFlavor.holder
		)
		sut = LaunchViewController(viewModel: viewModel)

		loadView()

		// When
		try alertVerifier?.executeAction(forButton: L.generalOk())

		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedJailbreakWarningShownSetter) == true
	}

	func test_showDeviceAuthenticationAlert() {

		// Given
		environmentSpies.userSettingsSpy.stubbedJailbreakWarningShown = false
		environmentSpies.userSettingsSpy.stubbedDeviceAuthenticationWarningShown = false
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = false
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = false

		let viewModel = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			flavor: AppFlavor.holder
		)
		sut = LaunchViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		alertVerifier?.verify(
			title: L.holderDeviceAuthenticationWarningTitle(),
			message: L.holderDeviceAuthenticationWarningMessage(),
			animated: true,
			actions: [
				.default(L.generalOk())
			],
			presentingViewController: sut
		)

		sut.assertImage()
	}

	func test_showDeviceAuthenticationAction() throws {

		// Given
		environmentSpies.userSettingsSpy.stubbedJailbreakWarningShown = false
		environmentSpies.userSettingsSpy.stubbedDeviceAuthenticationWarningShown = false
		environmentSpies.jailBreakDetectorSpy.stubbedIsJailBrokenResult = false
		environmentSpies.deviceAuthenticationDetectorSpy.stubbedHasAuthenticationPolicyResult = false

		let viewModel = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			flavor: AppFlavor.holder
		)
		sut = LaunchViewController(viewModel: viewModel)

		loadView()

		// When
		try alertVerifier?.executeAction(forButton: L.generalOk())

		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedDeviceAuthenticationWarningShownSetter) == true
	}
}
