/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import SnapshotTesting
@testable import CTR
import XCTest

class QRCardViewTests: XCTestCase {

	override func setUp() {
		super.setUp()
	}

	func testThreeRowSampleContent() {
		// Arrange

		let sut = QRCardView()
		sut.title = "Title"
		sut.viewQRButtonTitle = "viewQRButtonTitle"
		sut.region = "Region"

		sut.originRows = [
			// Isn't displayed
			QRCardView.OriginRow(
				type: "Type of Proof",
				validityString: { _ in .init(texts: ["Past"], kind: .past) }
			),
			QRCardView.OriginRow(
				type: "Type of Proof",
				validityString: { _ in .init(texts: ["Current"], kind: .current) }
			),
			QRCardView.OriginRow(
				type: "Type of Proof",
				validityString: { _ in .init(texts: ["Future"], kind: .future(desiresToShowAutomaticallyBecomesValidFooter: false)) }
			)
		]

		sut.expiryEvaluator = { _ in "Expiry Date text" }
		sut.buttonEnabledEvaluator = { _ in true }
		sut.isLoading = false

		// Assert
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 350)
		sut.assertImage()
	}

	func testOneRowSampleContent() {
		// Arrange

		let sut = QRCardView()
		sut.title = "Title"
		sut.viewQRButtonTitle = "viewQRButtonTitle"
		sut.region = "Region"

		sut.originRows = [
			QRCardView.OriginRow(
				type: "Type of Proof",
				validityString: { _ in .init(texts: ["Current"], kind: .current) }
			)
		]

		sut.expiryEvaluator = { _ in "Expiry Date text" }
		sut.buttonEnabledEvaluator = { _ in true }
		sut.isLoading = false

		// Assert
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 350)
		sut.assertImage()
	}

	func testButtonEnabledWithLoadingStatesContent() {
		// Arrange

		let sut = QRCardView()
		sut.title = "Title"
		sut.viewQRButtonTitle = "viewQRButtonTitle"
		sut.region = "Region"

		sut.originRows = [
			QRCardView.OriginRow(
				type: "Type of Proof",
				validityString: { _ in .init(texts: ["Current"], kind: .current) }
			)
		]

		sut.expiryEvaluator = { _ in "Expiry Date text" }

		// Act
		sut.buttonEnabledEvaluator = { _ in true }
		sut.isLoading = false
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 350)

		// Assert
		sut.assertImage()

		// Act
		sut.buttonEnabledEvaluator = { _ in false }
		sut.isLoading = false

		// Assert
		sut.assertImage()

		// Act
		sut.buttonEnabledEvaluator = { _ in true }
		sut.isLoading = true

		// Assert
		sut.assertImage()

		// Act
		sut.buttonEnabledEvaluator = { _ in false }
		sut.isLoading = true

		// Assert
		sut.assertImage()
	}

	func testBecomesAutomaticallyValidRowFooter() {
		// Arrange
		let sut = QRCardView()
		sut.title = "Title"
		sut.viewQRButtonTitle = "viewQRButtonTitle"
		sut.region = "Region"

		sut.originRows = [
			QRCardView.OriginRow(
				type: "Type of Proof",
				validityString: { _ in .init(texts: ["Future"], kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)) }
			)
		]

		sut.expiryEvaluator = { _ in "Expiry Date text" }
		sut.buttonEnabledEvaluator = { _ in false }
		sut.isLoading = false

		// Assert
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 350)
		sut.assertImage()
	}

	func testHidesAutomaticallyValidRowFooterIfButtonIsEnabled() {
		// Arrange
		let sut = QRCardView()
		sut.title = "Title"
		sut.viewQRButtonTitle = "viewQRButtonTitle"
		sut.region = "Region"

		sut.originRows = [
			QRCardView.OriginRow(
				type: "Type of Proof",
				validityString: { _ in .init(texts: ["Future"], kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)) }
			)
		]

		sut.expiryEvaluator = { _ in "Expiry Date text" }
		sut.buttonEnabledEvaluator = { _ in true }
		sut.isLoading = false

		// Assert
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 350)
		sut.assertImage()
	}

	func testSubtextField() {
		// Arrange
		let sut = QRCardView()
		sut.title = "Title"
		sut.viewQRButtonTitle = "viewQRButtonTitle"
		sut.region = "Region"
		sut.shouldStyleForEU = true
		sut.originRows = [
			QRCardView.OriginRow(
				type: nil,
				validityString: { _ in .init(
					texts: ["Vaccinatiebewijs: dosis 2 van 2", "Vaccinatiedatum: 15 juli 2021"],
					kind: .future(desiresToShowAutomaticallyBecomesValidFooter: false))
				}
			)
		]

		sut.buttonEnabledEvaluator = { _ in true }
		sut.isLoading = false

		// Assert
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 350)
		sut.assertImage()
	}
}
