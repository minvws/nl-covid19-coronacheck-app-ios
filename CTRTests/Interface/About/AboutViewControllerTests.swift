/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import ViewControllerPresentationSpy
@testable import CTR
import Nimble
import SnapshotTesting

class AboutViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: AboutViewController!
	private var coordinatorSpy: AboutViewModelCoordinatorSpy!
	private var userSettingsSpy: UserSettingsSpy!
	
	var window: UIWindow!

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		coordinatorSpy = AboutViewModelCoordinatorSpy()
		userSettingsSpy = UserSettingsSpy()
		let viewModel = AboutViewModel(
			coordinator: coordinatorSpy,
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.holder,
			userSettings: userSettingsSpy
		)

		sut = AboutViewController(viewModel: viewModel)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: Test

	func test_content() {

		// Given

		// When
		loadView()

		// Then
		expect(self.sut.title) == L.holderAboutTitle()
		expect(self.sut.sceneView.message) == L.holderAboutText()
		expect(self.sut.sceneView.listHeader) == L.holderAboutReadmore()
		expect(self.sut.sceneView.itemStackView.arrangedSubviews)
			.to(haveCount(5))
		expect(self.sut.sceneView.appVersion).toNot(beNil())

		sut.assertImage()
	}

	func test_alertDialog() {

		// Given
		let alertVerifier = AlertVerifier()
		loadView()

		// When
		(sut.sceneView.itemStackView.arrangedSubviews[3] as? SimpleDisclosureButton)?.primaryButtonTapped()

		// Then
		alertVerifier.verify(
			title: L.holderCleardataAlertTitle(),
			message: L.holderCleardataAlertSubtitle(),
			animated: true,
			actions: [
				.destructive(L.holderCleardataAlertRemove()),
				.cancel(L.generalCancel())
			]
		)
	}

	func test_resetData() throws {

		// Given
		let walletSpy = WalletManagerSpy()
		Services.use(walletSpy)
		let remoteConfigSpy = RemoteConfigManagingSpy(
			now: { now },
			userSettings: UserSettingsSpy(),
			reachability: ReachabilitySpy(),
			networkManager: NetworkSpy()
		)
		remoteConfigSpy.stubbedStoredConfiguration = .default
		Services.use(remoteConfigSpy)
		let cryptoLibUtilitySpy = CryptoLibUtilitySpy(
			now: { now },
			userSettings: UserSettingsSpy(),
			reachability: ReachabilitySpy(),
			fileStorage: FileStorage(),
			flavor: AppFlavor.flavor
		)
		Services.use(cryptoLibUtilitySpy)
		let onboardingSpy = OnboardingManagerSpy()
		Services.use(onboardingSpy)
		let forcedInfoSpy = ForcedInformationManagerSpy()
		Services.use(forcedInfoSpy)
		let alertVerifier = AlertVerifier()
		loadView()
		(sut.sceneView.itemStackView.arrangedSubviews[3] as? SimpleDisclosureButton)?.primaryButtonTapped()

		// When
		try alertVerifier.executeAction(forButton: L.holderCleardataAlertRemove())

		// Then
		expect(walletSpy.invokedRemoveExistingGreenCards) == true
		expect(walletSpy.invokedRemoveExistingEventGroups) == true
		expect(remoteConfigSpy.invokedReset) == true
		expect(cryptoLibUtilitySpy.invokedReset) == true
		expect(onboardingSpy.invokedReset) == true
		expect(forcedInfoSpy.invokedReset) == true
		expect(self.userSettingsSpy.invokedReset) == true
		expect(self.coordinatorSpy.invokedRestart) == true
	}
}
