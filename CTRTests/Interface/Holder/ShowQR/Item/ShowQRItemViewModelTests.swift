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
	var screenCaptureDetector: ScreenCaptureDetectorSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		delegateSpy = ShowQRItemViewModelDelegateSpy()
		environmentSpies = setupEnvironmentSpies()
		screenCaptureDetector = ScreenCaptureDetectorSpy()
	}

	// MARK: - Tests

	/// Test all the default content
	func test_content_withDomesticGreenCard() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)

		// When
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector
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
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: true
			)
		)

		// When
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector
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
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector
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
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .eu,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.delegateSpy.invokedItemIsNotValid) == true
	}

	func test_validity_withDomesticGreenCard_withValidCredential() throws {
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration = .default

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: true
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector
		)
		environmentSpies.cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.environmentSpies.cryptoManagerSpy.invokedGenerateQRmessage).toEventually(beTrue())
		expect(self.sut.visibilityState).toEventually(beVisible())
		expect(self.sut.validityTimer).toEventuallyNot(beNil())
		expect(self.delegateSpy.invokedItemIsNotValid) == false
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
			screenCaptureDetector: screenCaptureDetector
		)

		// When
		sut?.checkQRValidity()

		// Then
		expect(self.environmentSpies.cryptoManagerSpy.invokedGenerateQRmessage).toEventually(beFalse())
		expect(self.sut.visibilityState).toEventually(beVisible())
		expect(self.sut.validityTimer).toEventuallyNot(beNil())
		expect(self.delegateSpy.invokedItemIsNotValid) == false
	}

	/// Test taking a screenshot
	func testScreenshot() throws {

		// Given
		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector
		)

		// When
		screenCaptureDetector.invokedScreenshotWasTakenCallback?()

		// Then
		expect(self.sut.visibilityState).to(beScreenshotBlocking())
	}

	func testTakingAScreenshotPersistsDate() throws {

		// Given
		environmentSpies.cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()

		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector
		)

		// When
		screenCaptureDetector.invokedScreenshotWasTakenCallback?()

		// Then
		expect(self.environmentSpies.userSettingsSpy.invokedLastScreenshotTime).toEventually(equal(now))
	}

	func testHavingAPriorUnexpiredScreenshotStartsScreenshotBlocker() throws {

		// Given
		environmentSpies.cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()
		environmentSpies.userSettingsSpy.stubbedLastScreenshotTime = now.addingTimeInterval(-10)

		let greenCard = try XCTUnwrap(
			GreenCardModel.createFakeGreenCard(
				dataStoreManager: environmentSpies.dataStoreManager,
				type: .domestic,
				withValidCredential: false
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
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
				type: .domestic,
				withValidCredential: true
			)
		)
		sut = ShowQRItemViewModel(
			delegate: delegateSpy,
			greenCard: greenCard,
			screenCaptureDetector: screenCaptureDetector
		)
		environmentSpies.cryptoManagerSpy.stubbedGenerateQRmessageResult = Data()

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
