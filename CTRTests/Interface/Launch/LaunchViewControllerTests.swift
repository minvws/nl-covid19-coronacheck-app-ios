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

class LaunchViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: LaunchViewController!
	private var appCoordinatorSpy: AppCoordinatorSpy!
	private var versionSupplierSpy: AppVersionSupplierSpy!
	private var remoteConfigSpy: RemoteConfigManagingSpy!
	private var proofManagerSpy: ProofManagingSpy!
	private var jailBreakProtocolSpy: JailBreakProtocolSpy!
	private var userSettingsSpy: UserSettingsSpy!
	private var walletSpy: WalletManagerSpy!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		appCoordinatorSpy = AppCoordinatorSpy()
		versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0")
		remoteConfigSpy = RemoteConfigManagingSpy(networkManager: NetworkSpy())
		proofManagerSpy = ProofManagingSpy()
		jailBreakProtocolSpy = JailBreakProtocolSpy()
		userSettingsSpy = UserSettingsSpy()
		walletSpy = WalletManagerSpy(dataStoreManager: DataStoreManager(.inMemory))

		let viewModel = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy,
			walletManager: walletSpy
		)

		sut = LaunchViewController(viewModel: viewModel)
		window = UIWindow()
	}

	override func tearDown() {

		super.tearDown()
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
		expect(self.sut.sceneView.title) == L.holderLaunchTitle()
		expect(self.sut.sceneView.message) == L.holderLaunchText()
		expect(self.sut.sceneView.version).toNot(beNil(), description: "Version should not be nil")
		expect(self.sut.sceneView.version).toNot(beNil(), description: "AppIcon should not be nil")

		sut.assertImage()
	}

	func test_showJailBreakAlert() {

		// Given
		userSettingsSpy.stubbedJailbreakWarningShown = false
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true

		let viewModel = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy,
			userSettings: userSettingsSpy,
			walletManager: walletSpy
		)
		sut = LaunchViewController(viewModel: viewModel)

		let alertVerifier = AlertVerifier()

		// When
		loadView()

		// Then
		alertVerifier.verify(
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
}
