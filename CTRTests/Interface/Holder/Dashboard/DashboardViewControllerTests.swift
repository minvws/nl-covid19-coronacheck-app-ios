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

class DashboardViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: HolderDashboardViewController!

	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!

	var cryptoManagerSpy: CryptoManagerSpy!

	var proofManagerSpy: ProofManagingSpy!

	var configSpy: ConfigurationGeneralSpy!

	var viewModel: HolderDashboardViewModel!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		proofManagerSpy = ProofManagingSpy()
		configSpy = ConfigurationGeneralSpy()

		viewModel = HolderDashboardViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			maxValidity: 48,
			qrCodeValidityRegion: .netherlands
		)
		sut = HolderDashboardViewController(viewModel: viewModel!)
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	/// Test all the default content
	func testContent() {

		// Given

		// When
		loadView()

		// Then
		expect(self.sut.title)
			.to(equal(.holderDashboardTitle), description: "Title should match")
		expect(self.sut.sceneView.message)
			.to(equal(.holderDashboardIntro), description: "Message should match")
		expect(self.sut.sceneView.expiredQRView.title)
			.to(equal(.holderDashboardQRExpired), description: "QR Expired title should match")
		expect(self.sut.sceneView.qrCardView.isHidden) == true
		expect(self.sut.sceneView.expiredQRView.isHidden) == true

		sut.assertImage(containedInNavigationController: true)
	}

	/// Test tapping on the create qr card
	func testCardTappedCreate() {

		// Given
		loadView()

		// When
		sut.sceneView.createCard.primaryButtonTapped()

		// Then
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateToAboutMakingAQR) == true
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateToAppointment) == false
	}

	/// Helper method to setup valid credential
	func setupValidCredential() {

		let sampleTime = Date().timeIntervalSince1970 - 20
		cryptoManagerSpy.crypoAttributes = CryptoAttributes(
			birthDay: nil,
			birthMonth: nil,
			firstNameInitial: nil,
			lastNameInitial: nil,
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired",
			specimen: "0",
			paperProof: "0"
		)
		let qrMessage = Data("testValidityCredentialValid".utf8)
		cryptoManagerSpy.qrMessage = qrMessage
		viewModel.proofValidator = ProofValidator(maxValidity: 1)
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValid() {

		// Given
		setupValidCredential()
		loadView()

		// When
		sut.checkValidity()

		// Then
		expect(self.sut.sceneView.qrCardView.isHidden) == false
		expect(self.sut.sceneView.qrCardView.message)
			.toNot(beNil())
		expect(self.sut.sceneView.qrCardView.title)
			.toNot(beNil())
		expect(self.sut.sceneView.qrCardView.time)
			.toNot(beNil())
		expect(self.sut.sceneView.qrCardView.identity)
			.toNot(beNil())
		expect(self.sut.sceneView.expiredQRView.isHidden) == true
	}

	/// Test the validity of the credential with expired credential
	func testValidityCredentialExpired() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 3608
		cryptoManagerSpy.crypoAttributes = CryptoAttributes(
			birthDay: nil,
			birthMonth: nil,
			firstNameInitial: nil,
			lastNameInitial: nil,
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired",
			specimen: "0",
			paperProof: "0"
		)
		viewModel.proofValidator = ProofValidator(maxValidity: 1)
		loadView()

		// When
		sut.checkValidity()

		// Then
		expect(self.sut.sceneView.qrCardView.isHidden) == true
		expect(self.sut.sceneView.expiredQRView.isHidden) == false

		sut.assertImage()
	}

	/// Test the validity of the credential without credential
	func testValidityNoCredential() {

		// Given
		cryptoManagerSpy.crypoAttributes = nil
		loadView()

		// When
		sut.checkValidity()

		// Then
		expect(self.sut.sceneView.qrCardView.isHidden) == true
		expect(self.sut.sceneView.expiredQRView.isHidden) == true

		sut.assertImage()
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValidTapQR() {

		// Given
		setupValidCredential()
		loadView()
		sut.checkValidity()

		// When
		sut.sceneView.qrCardView.primaryButtonTapped()

		// Then
		expect(self.sut.sceneView.qrCardView.isHidden) == false
		expect(self.sut.sceneView.expiredQRView.isHidden) == true
		expect(self.holderCoordinatorDelegateSpy.invokedNavigateToShowQR) == true
	}

	/// Test the validity of the credential with valid credential
	func testValidityCredentialValidWithScreenCapture() {

		// Given
		setupValidCredential()
		loadView()
		sut.checkValidity()

		// When
		viewModel.hideForCapture = true

		// Then
		expect(self.sut.sceneView.qrCardView.isHidden) == true
		expect(self.sut.sceneView.expiredQRView.isHidden) == true
	}

	func testCloseExpiredRQ() {

		// Given
		let sampleTime = Date().timeIntervalSince1970 - 3608
		cryptoManagerSpy.crypoAttributes = CryptoAttributes(
			birthDay: nil,
			birthMonth: nil,
			firstNameInitial: nil,
			lastNameInitial: nil,
			sampleTime: "\(sampleTime)",
			testType: "testValidityCredentialExpired",
			specimen: "0",
			paperProof: "0"
		)
		viewModel.proofValidator = ProofValidator(maxValidity: 1)
		loadView()
		sut.checkValidity()

		// When
		sut?.sceneView.expiredQRView.closeButtonTapped()

		// Then
		expect(self.cryptoManagerSpy.removeCredentialCalled) == true
		expect(self.cryptoManagerSpy.crypoAttributes)
			.to(beNil())
	}

	func test_showNotificationBanner() {

		// Given
		loadView()
		let notificationContent = NotificationBannerContent(
			title: "Banner title",
			message: nil,
			icon: nil
		)

		// When
		sut.showNotificationBanner(notificationContent)

		// Then
		expect(self.sut.bannerView)
			.toNot(beNil(), description: "Banner view should be shown")
	}
}
