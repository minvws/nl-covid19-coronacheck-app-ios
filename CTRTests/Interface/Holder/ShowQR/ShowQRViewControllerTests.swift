/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class ShowQRViewControllerTests: XCTestCase {

	// MARK: Subject under test
	var sut: ShowQRViewController!

	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	var cryptoManagerSpy: CryptoManagerSpy!
	var dataStoreManager: DataStoreManaging!
	var viewModel: ShowQRViewModel!
	var remoteConfigManagerSpy: RemoteConfigManagingSpy!
	var window = UIWindow()

	// MARK: Test lifecycle

	override func setUpWithError() throws {

		try super.setUpWithError()
		dataStoreManager = DataStoreManager(.inMemory)
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()

		remoteConfigManagerSpy = RemoteConfigManagingSpy(
			now: { now },
			userSettings: UserSettingsSpy(),
			reachability: ReachabilitySpy(),
			networkManager: NetworkSpy()
		)
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		remoteConfigManagerSpy.stubbedAppendReloadObserverResult = UUID()
		remoteConfigManagerSpy.stubbedAppendUpdateObserverResult = UUID()
 
		Services.use(cryptoManagerSpy)
		Services.use(remoteConfigManagerSpy)

		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)

		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			thirdPartyTicketAppName: nil
		)
		sut = ShowQRViewController(viewModel: viewModel)
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

	// MARK: - Tests

	/// Test all the default content
	func test_content_domesticGreenCard() {

		// Given

		// When
		loadView()

		// Then
		expect(self.sut.title) == L.holderShowqrDomesticTitle()
		expect(self.sut.sceneView.returnToThirdPartyAppButton.isHidden) == true
		expect(self.sut.sceneView.nextButton.isHidden) == true
		expect(self.sut.sceneView.previousButton.isHidden) == true
		expect(self.sut.sceneView.pageControl.isHidden) == true
	}

	/// Test all the default content
	func test_content_domesticGreenCard_withThirdPartyApp() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)

		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			thirdPartyTicketAppName: "RollerDiscoParties"
		)
		sut = ShowQRViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.title) == L.holderShowqrDomesticTitle()
		expect(self.sut.sceneView.returnToThirdPartyAppButton.isHidden) == false
		expect(self.sut.sceneView.nextButton.isHidden) == true
		expect(self.sut.sceneView.previousButton.isHidden) == true
		expect(self.sut.sceneView.pageControl.isHidden) == true
	}

	func test_content_euGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			thirdPartyTicketAppName: nil
		)
		sut = ShowQRViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.sceneView.nextButton.isHidden) == true
		expect(self.sut.sceneView.previousButton.isHidden) == true
		expect(self.sut.sceneView.pageControl.isHidden) == true
	}

	/// Test all the default content
	func test_content_euGreenCard_withThirdPartyApp() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)

		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard],
			thirdPartyTicketAppName: "RollerDiscoParties"
		)
		sut = ShowQRViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.sceneView.returnToThirdPartyAppButton.isHidden) == true
		expect(self.sut.sceneView.nextButton.isHidden) == true
		expect(self.sut.sceneView.previousButton.isHidden) == true
		expect(self.sut.sceneView.pageControl.isHidden) == true
		expect(self.sut.sceneView.pageControl.numberOfPages) == 1
	}

	func test_content_euGreenCard_multipleGreenCards() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard, greenCard],
			thirdPartyTicketAppName: nil
		)
		sut = ShowQRViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.sceneView.nextButton.isHidden) == true
		expect(self.sut.sceneView.previousButton.isHidden) == false
		expect(self.sut.sceneView.pageControl.isHidden) == false
		expect(self.sut.sceneView.pageControl.currentPage) == 1
		expect(self.sut.sceneView.pageControl.numberOfPages) == 2
	}

	func test_nextButtonTapped_euGreenCard_multipleGreenCards() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		viewModel = ShowQRViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			greenCards: [greenCard, greenCard],
			thirdPartyTicketAppName: nil
		)
		sut = ShowQRViewController(viewModel: viewModel)
		loadView()

		// When
		sut.sceneView.didTapNextButton()

		// Then
		expect(self.sut.title) == L.holderShowqrEuTitle()
		expect(self.sut.sceneView.nextButton.isHidden).toEventually(beTrue())
		expect(self.sut.sceneView.previousButton.isHidden).toEventually(beFalse())
		expect(self.sut.sceneView.pageControl.isHidden) == false
		expect(self.sut.sceneView.pageControl.currentPage).toEventually(equal(1))
		expect(self.sut.sceneView.pageControl.numberOfPages) == 2
	}

	/// Test the security features
	func test_securityFeaturesAnimation() {

		// Given
		loadView()

		// When
		sut?.sceneView.securityView.primaryButton.sendActions(for: .touchUpInside)

		// Then
		expect(self.sut.sceneView.securityView.currentAnimation) == .domesticAnimation
	}
}
