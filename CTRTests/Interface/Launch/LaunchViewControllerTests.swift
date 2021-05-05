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

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()

		appCoordinatorSpy = AppCoordinatorSpy()
		versionSupplierSpy = AppVersionSupplierSpy(version: "1.0.0")
		remoteConfigSpy = RemoteConfigManagingSpy()
		proofManagerSpy = ProofManagingSpy()
		jailBreakProtocolSpy = JailBreakProtocolSpy()

		let viewModel = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy
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
		expect(self.sut.sceneView.title) == .holderLaunchTitle
		expect(self.sut.sceneView.message) == .holderLaunchText
		expect(self.sut.sceneView.version).toNot(beNil(), description: "Version should not be nil")
		expect(self.sut.sceneView.version).toNot(beNil(), description: "AppIcon should not be nil")

		sut.assertImage()
	}

	func test_showAlertDialog() {

		// Given
		jailBreakProtocolSpy.stubbedShouldWarnUserResult = true
		jailBreakProtocolSpy.stubbedIsJailBrokenResult = true

		let viewModel = LaunchViewModel(
			coordinator: appCoordinatorSpy,
			versionSupplier: versionSupplierSpy,
			flavor: AppFlavor.holder,
			remoteConfigManager: remoteConfigSpy,
			proofManager: proofManagerSpy,
			jailBreakDetector: jailBreakProtocolSpy
		)
		sut = LaunchViewController(viewModel: viewModel)

		let alertVerifier = AlertVerifier()

		// When
		loadView()

		// Then
		alertVerifier.verify(
			title: .jailbrokenTitle,
			message: .jailbrokenMessage,
			animated: true,
			actions: [
				.default(.ok)
			],
			presentingViewController: sut
		)

		sut.assertImage()
	}
}
