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

		sut.validityTexts = { (date: Date) -> [HolderDashboardViewController.ValidityText] in
			return [
				HolderDashboardViewController.ValidityText(lines: [
					"Type of Proof:",
					"Past"
				], kind: .past),
				HolderDashboardViewController.ValidityText(lines: [
					"Type of Proof:",
					"Current"
				], kind: .current),
				HolderDashboardViewController.ValidityText(lines: [
					"Type of Proof:",
					"Future"
				], kind: .future(desiresToShowAutomaticallyBecomesValidFooter: false))
			]
		}

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
		sut.validityTexts = { (date: Date) -> [HolderDashboardViewController.ValidityText] in
			return [
				HolderDashboardViewController.ValidityText(lines: [
					"Type of Proof:",
					"Current"
				], kind: .current)
			]
		}

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
		sut.validityTexts = { (date: Date) -> [HolderDashboardViewController.ValidityText] in
			return [
				HolderDashboardViewController.ValidityText(lines: [
					"Type of Proof:",
					"Current"
				], kind: .current)
			]
		}

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
		sut.validityTexts = { (date: Date) -> [HolderDashboardViewController.ValidityText] in
			return [
				HolderDashboardViewController.ValidityText(lines: [
					"Type of Proof:",
					"Future"
				], kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true))
			]
		}

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
		sut.validityTexts = { (date: Date) -> [HolderDashboardViewController.ValidityText] in
			return [
				HolderDashboardViewController.ValidityText(lines: [
					"Type of Proof:",
					"Future"
				], kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true))
			]
		}

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
		sut.validityTexts = { (date: Date) -> [HolderDashboardViewController.ValidityText] in
			return [
				HolderDashboardViewController.ValidityText(lines: [
					"Vaccinatiebewijs: dosis 2 van 2", "Vaccinatiedatum: 15 juli 2021"
				], kind: .future(desiresToShowAutomaticallyBecomesValidFooter: false))
			]
		}

		sut.buttonEnabledEvaluator = { _ in true }
		sut.isLoading = false

		// Assert
		sut.frame = CGRect(x: 0, y: 0, width: 300, height: 350)
		sut.assertImage()
	}
}
