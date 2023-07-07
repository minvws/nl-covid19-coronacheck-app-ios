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
import QRGenerator

class ShowQRItemViewModelTests: XCTestCase {

	/// Subject under test
	var sut: ShowQRItemViewModel!

	var delegateSpy: ShowQRItemViewModelDelegateSpy!
	var screenCaptureDetector: ScreenCaptureDetectorSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		delegateSpy = ShowQRItemViewModelDelegateSpy()
		environmentSpies = setupEnvironmentSpies()
		environmentSpies.secureUserSettingsSpy.stubbedHolderSecretKey = Data()
		screenCaptureDetector = ScreenCaptureDetectorSpy()
	}

	// MARK: - Tests

	/// Test all the default content
	func test_content_withEuGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)

		// When
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			state: .regular,
			screenCaptureDetector: screenCaptureDetector
		)

		// Then
		expect(self.sut.visibilityState) == .loading
		expect(self.sut.qrAccessibility) == L.holderShowqrEuQrTitle()
	}

	func test_constants() {
		
		expect(ShowQRItemViewModel.internationalCorrectionLevel) == CorrectionLevel.quartile
		expect(ShowQRItemViewModel.screenshotWarningMessageDuration) == 180
	}

	func test_validity_withEuGreenCard_withoutCredential() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			state: .regular,
			screenCaptureDetector: screenCaptureDetector
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.delegateSpy.invokedItemIsNotValid) == true
	}
	
	func test_validity_withEuGreenCard_withValidCredential() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			state: .regular,
			screenCaptureDetector: screenCaptureDetector
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.sut.visibilityState).toEventually(beVisible())
		expect(self.sut.validityTimer).toEventuallyNot(beNil())
		expect(self.delegateSpy.invokedItemIsNotValid) == false
		expect(self.sut.overlayIcon) == nil
		expect(self.sut.overlayTitle) == nil
		expect(self.sut.overlayInfoTitle) == nil
		expect(self.sut.overlayRevealTitle) == nil
	}

	func test_validity_withEuGreenCard_withValidCredential_expired() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			state: .expired,
			screenCaptureDetector: screenCaptureDetector
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.sut.visibilityState).toEventually(beOverlay())
		expect(self.sut.validityTimer).toEventuallyNot(beNil())
		expect(self.delegateSpy.invokedItemIsNotValid) == false
		expect(self.sut.overlayIcon) == I.expired()
		expect(self.sut.overlayTitle) == L.holder_qr_code_expired_overlay_title()
		expect(self.sut.overlayInfoTitle) == L.holder_qr_code_hidden_explanation_button()
		expect(self.sut.overlayRevealTitle) == L.holderShowqrShowqr()
	}

	func test_validity_withEuGreenCard_withValidCredential_irrelevant() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			state: .irrelevant,
			screenCaptureDetector: screenCaptureDetector
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.sut.visibilityState).toEventually(beOverlay())
		expect(self.sut.validityTimer).toEventuallyNot(beNil())
		expect(self.delegateSpy.invokedItemIsNotValid) == false
		expect(self.sut.overlayIcon) == I.eye()
		expect(self.sut.overlayTitle) == L.holderShowqrQrhidden()
		expect(self.sut.overlayInfoTitle) == L.holder_qr_code_hidden_explanation_button()
		expect(self.sut.overlayRevealTitle) == L.holderShowqrShowqr()
	}
	
	/// Test taking a screenshot
	func testScreenshot() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			state: .regular,
			screenCaptureDetector: screenCaptureDetector
		)

		// When
		screenCaptureDetector.invokedScreenshotWasTakenCallback?()

		// Then
		expect(self.sut.visibilityState).to(beScreenshotBlocking())
	}

	func testTakingAScreenshotPersistsDate() throws {

		// Given

		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			state: .regular,
			screenCaptureDetector: screenCaptureDetector
		)

		// When
		screenCaptureDetector.invokedScreenshotWasTakenCallback?()

		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedLastScreenshotTime).toEventually(equal(now))
	}

	func testHavingAPriorUnexpiredScreenshotStartsScreenshotBlocker() throws {

		// Given
		environmentSpies.userSettingsSpy.stubbedLastScreenshotTime = now.addingTimeInterval(-10)

		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			state: .regular,
			screenCaptureDetector: screenCaptureDetector
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
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			state: .regular,
			screenCaptureDetector: screenCaptureDetector
		)
		
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
		
	func test_infoButtonTapped_regular() throws {
		
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			state: .regular,
			screenCaptureDetector: screenCaptureDetector
		)
		
		// When
		sut.infoButtonTapped()
		
		// Then
		expect(self.delegateSpy.invokedShowInfoHiddenQR) == false
		expect(self.delegateSpy.invokedShowInfoExpiredQR) == false
	}
	
	func test_infoButtonTapped_expired() throws {
		
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,

			state: .expired,
			screenCaptureDetector: screenCaptureDetector
		)
		
		// When
		sut.infoButtonTapped()
		
		// Then
		expect(self.delegateSpy.invokedShowInfoHiddenQR) == false
		expect(self.delegateSpy.invokedShowInfoExpiredQR) == true
	}
	
	func test_infoButtonTapped_irrelevant() throws {
		
		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			state: .irrelevant,
			screenCaptureDetector: screenCaptureDetector
		)
		
		// When
		sut.infoButtonTapped()
		
		// Then
		expect(self.delegateSpy.invokedShowInfoHiddenQR) == true
		expect(self.delegateSpy.invokedShowInfoExpiredQR) == false
	}
}

extension GreenCardModel {

	static func createFakeGreenCard(dataStoreManager: DataStoreManaging, type: GreenCardType, withValidCredential: Bool, originType: OriginType? = nil) -> GreenCard? {

		var result: GreenCard?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				result = GreenCard(
					type: type,
					wallet: wallet,
					managedContext: context
				)
				if withValidCredential, let greenCard = result {
					let now = Date().timeIntervalSince1970 - 200
					let expiration = now + 3600
					Credential(
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
					Origin(
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
	return Predicate.define("be .visible with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .visible(qrImage: image) = actual {
			test(image)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}
private func beOverlay(test: @escaping (UIImage) -> Void = { _ in }) -> Predicate<ShowQRItemView.VisibilityState> {
	return Predicate.define("be .overlay with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .overlay(qrImage: image) = actual {
			test(image)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}
private func beScreenshotBlocking(test: @escaping (String, String) -> Void = { _, _ in }) -> Predicate<ShowQRItemView.VisibilityState> {
	return Predicate.define("be .screenshotBlocking with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .screenshotBlocking(timeRemainingText, voiceoverTimeRemainingText) = actual {
			test(timeRemainingText, voiceoverTimeRemainingText)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}
