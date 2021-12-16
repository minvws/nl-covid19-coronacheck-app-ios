/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import XCTest
@testable import CTR
import Nimble

class ShowQRItemViewModelTests: XCTestCase {

	/// Subject under test
	var sut: ShowQRItemViewModel!

	var delegateSpy: ShowQRItemViewModelDelegateSpy!
	var cryptoManagerSpy: CryptoManagerSpy!
	var dataStoreManager: DataStoreManaging!
	var screenCaptureDetector: ScreenCaptureDetectorSpy!
	var userSettingsSpy: UserSettingsSpy!
	var remoteConfigManagingSpy: RemoteConfigManagingSpy!

	override func setUp() {
		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory)
		delegateSpy = ShowQRItemViewModelDelegateSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		screenCaptureDetector = ScreenCaptureDetectorSpy()
		userSettingsSpy = UserSettingsSpy()
		remoteConfigManagingSpy = RemoteConfigManagingSpy(
			now: { now },
			userSettings: UserSettingsSpy(),
			reachability: ReachabilitySpy(),
			networkManager: NetworkSpy()
		)
		remoteConfigManagingSpy.stubbedStoredConfiguration = .default
		remoteConfigManagingSpy.stubbedAppendReloadObserverResult = UUID()
		remoteConfigManagingSpy.stubbedAppendUpdateObserverResult = UUID()
		
		Services.use(cryptoManagerSpy)
		Services.use(remoteConfigManagingSpy)
	}

	override func tearDown() {

		super.tearDown()
		Services.revertToDefaults()
	}

	// MARK: - Tests

	/// Test all the default content
	func test_content_withDomesticGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)

		// When
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.sut.visibilityState) == .loading
		expect(self.sut.qrAccessibility) == L.holderShowqrDomesticQrTitle()
	}

	/// Test all the default content
	func test_content_withEuGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)

		// When
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// Then
		expect(self.sut.visibilityState) == .loading
		expect(self.sut.qrAccessibility) == L.holderShowqrEuQrTitle()
	}

	func test_constants() {
		expect(ShowQRItemViewModel.domesticCorrectionLevel) == "M"
		expect(ShowQRItemViewModel.internationalCorrectionLevel) == "Q"
		expect(ShowQRItemViewModel.screenshotWarningMessageDuration) == 180
	}

	func test_validity_withDomesticGreenCard_withoutCredential() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.delegateSpy.invokedItemIsNotValid) == true
	}

	func test_validity_withEuGreenCard_withoutCredential() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.delegateSpy.invokedItemIsNotValid) == true
	}

	func test_validity_withDomesticGreenCard_withValidCredential() throws {
		remoteConfigManagingSpy.stubbedStoredConfiguration = .default

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)
		cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.cryptoManagerSpy.invokedGenerateQRmessage).toEventually(beTrue())
		expect(self.sut.visibilityState).toEventually(beVisible())
		expect(self.sut.validityTimer).toEventuallyNot(beNil())
		expect(self.delegateSpy.invokedItemIsNotValid) == false
	}

	func test_validity_withEuGreenCard_withValidCredential() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.cryptoManagerSpy.invokedGenerateQRmessage).toEventually(beFalse())
		expect(self.sut.visibilityState).toEventually(beVisible())
		expect(self.sut.validityTimer).toEventuallyNot(beNil())
		expect(self.delegateSpy.invokedItemIsNotValid) == false
	}

	/// Test taking a screenshot
	func testScreenshot() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)

		// When
		screenCaptureDetector.invokedScreenshotWasTakenCallback?()

		// Then
		expect(self.sut.visibilityState).to(beScreenshotBlocking())
	}

	func testTakingAScreenshotPersistsDate() throws {

		// Given
		cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()

		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy,
			now: { now }
		)

		// When
		screenCaptureDetector.invokedScreenshotWasTakenCallback?()

		// Then
		expect(self.userSettingsSpy.invokedLastScreenshotTime).toEventually(equal(now))
	}

	func testHavingAPriorUnexpiredScreenshotStartsScreenshotBlocker() throws {

		// Given
		cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()
		userSettingsSpy.stubbedLastScreenshotTime = now.addingTimeInterval(-10)

		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy,
			now: { now }
		)

		// Then
		expect(self.sut.visibilityState).toEventually(beScreenshotBlocking(test: { message, voiceoverMessage in
			expect(message) == "Je QR-code komt terug in 2:50"
			expect(voiceoverMessage) == "Je QR-code komt terug in 2 minuten en 50 seconden"
		}))
	}

	func testHideForCapture() throws {
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector,
			userSettings: userSettingsSpy
		)
		cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.sut.visibilityState).toEventually(beVisible())

		screenCaptureDetector.invokedScreenCaptureDidChangeCallback?(true)
		expect(self.sut.visibilityState) == .hiddenForScreenCapture

		// And disable again:
		screenCaptureDetector.invokedScreenCaptureDidChangeCallback?(false)
		expect(self.sut.visibilityState).toEventually(beVisible())
	}
}

extension GreenCardModel {

	static func createFakeGreenCard(dataStoreManager: DataStoreManaging, type: GreenCardType, withValidCredential: Bool, originType: OriginType? = nil) -> GreenCard? {

		var result: GreenCard?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				result = GreenCardModel.create(
					type: type,
					wallet: wallet,
					managedContext: context
				)
				if withValidCredential, let greenCard = result {
					let now = Date().timeIntervalSince1970 - 200
					let expiration = now + 3600
					CredentialModel.create(
						data: Data(),
						validFrom: Date(timeIntervalSince1970: now),
						expirationTime: Date(timeIntervalSince1970: expiration),
						greenCard: greenCard,
						managedContext: context
					)
				}
				if let type = originType, let greenCard = result {
					let now = Date().timeIntervalSince1970 - 200
					let expiration = now + 3600
					OriginModel.create(
						type: type,
						eventDate: Date(timeIntervalSince1970: now),
						expirationTime: Date(timeIntervalSince1970: expiration),
						validFromDate: Date(timeIntervalSince1970: now),
						doseNumber: nil,
						greenCard: greenCard,
						managedContext: context
					)
				}
			}
		}
		return result
	}
}

private func beVisible(test: @escaping (UIImage) -> Void = { _ in }) -> Predicate<ShowQRItemView.VisibilityState> {
	return Predicate.define("be .expiredQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .visible(qrImage: image) = actual {
			test(image)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}
private func beScreenshotBlocking(test: @escaping (String, String) -> Void = { _, _ in }) -> Predicate<ShowQRItemView.VisibilityState> {
	return Predicate.define("be .expiredQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .screenshotBlocking(timeRemainingText, voiceoverTimeRemainingText) = actual {
			test(timeRemainingText, voiceoverTimeRemainingText)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}
