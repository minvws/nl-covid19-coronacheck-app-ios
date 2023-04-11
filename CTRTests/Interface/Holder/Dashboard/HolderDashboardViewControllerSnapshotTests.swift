/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length type_name

import UIKit
import XCTest
import SnapshotTesting
import CoreData
import Nimble
import Shared
@testable import CTR
@testable import Resources
import ReusableViews

class HolderDashboardViewControllerSnapshotTests: XCTestCase {

	var viewModelSpy: HolderDashboardViewModelSpy!
	
	override func setUp() {
		super.setUp()
		_ = setupEnvironmentSpies()
		viewModelSpy = HolderDashboardViewModelSpy()
		viewModelSpy.stubbedTitle = Observable(value: L.holderDashboardTitle())
		viewModelSpy.stubbedInternationalCards = Observable(value: [])
		viewModelSpy.stubbedPrimaryButtonTitle = Observable(value: L.holderMenuProof())
		viewModelSpy.stubbedCurrentlyPresentedAlert = Observable(value: nil)
		viewModelSpy.stubbedShouldShowAddCertificateFooter = Observable(value: false)
	}
	
	func testInitial() {
		
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_headerMessage() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)

		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.headerMessage(message: "Message", buttonTitle: nil)
		]

		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_headerMessage_withButtonTitle() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.headerMessage(message: "Message", buttonTitle: "Button title")
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_emptyStateDescription() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.emptyStateDescription(message: "Message", buttonTitle: nil)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_emptyStateDescription_withButtonTitle() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.emptyStateDescription(message: "Message", buttonTitle: "Button title")
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_emptyStatePlaceholdImage_international() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.emptyStatePlaceholderImage(image: I.dashboard.international()!, title: L.holderDashboardEmptyInternationalTitle())
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_addCertificate() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.addCertificate(title: "Title", didTapAdd: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_expiredQR() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.expiredQR(message: "Title", didTapClose: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_expiredVaccinationQR() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.expiredVaccinationQR(message: "message", callToActionButtonText: "callToActionButtonText", didTapCallToAction: {}, didTapClose: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_deviceHasClockDeviation() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.deviceHasClockDeviation(message: "message", callToActionButtonText: "callToActionButtonText", didTapCallToAction: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_configAlmostOutOfDate() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.configAlmostOutOfDate(message: "message", callToActionButtonText: "callToActionButtonText", didTapCallToAction: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_errorMessage_short() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 1,
				validityTexts: { _ in [] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in true },
				expiryCountdownEvaluator: nil,
				error: .init(message: "Here is an error message", didTapURL: { _ in })
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_errorMessage_long() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 1,
				validityTexts: { _ in [] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in true },
				expiryCountdownEvaluator: nil,
				error: .init(message: "Here is a much longer error message that almost certainly takes up numerous many or several lines", didTapURL: { _ in })
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_completeYourVaccinationAssessment() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.completeYourVaccinationAssessment(title: "title", buttonText: "buttonText", didTapCallToAction: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_vaccinationAssessmentInvalidOutsideNL() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.vaccinationAssessmentInvalidOutsideNL(title: "title", buttonText: "buttonText", didTapCallToAction: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_recommendedUpdate() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.recommendedUpdate(message: "message", callToActionButtonText: "callToActionButtonText", didTapCallToAction: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_disclosurePolicyInformation() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.disclosurePolicyInformation(title: "title", buttonText: "buttonText", accessibilityIdentifier: "accessibilityIdentifier", didTapCallToAction: {}, didTapClose: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	// MARK: - International QR -
	
	func test_internationalQR_static() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 1,
				validityTexts: { _ in [] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in false },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_internationalQR_static_stackSize2() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 2,
				validityTexts: { _ in [] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in false },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}

	func test_internationalQR_static_stackSize3() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 3,
				validityTexts: { _ in [] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in false },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_internationalQR_static_stackSize4() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 4,
				validityTexts: { _ in [] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in false },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_internationalQR_loading_buttonEnabled() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 1,
				validityTexts: { _ in [] },
				isLoading: true,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in true },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_internationalQR_loading_buttonDisabled() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 1,
				validityTexts: { _ in [] },
				isLoading: true,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in false },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_internationalQR_expiryCountdown() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 1,
				validityTexts: { _ in [] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in false },
				expiryCountdownEvaluator: { _ in "expiryCountdownEvaluator" },
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_internationalQR_validityTexts_past() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 1,
				validityTexts: { _ in [
					HolderDashboardViewController.ValidityText(lines: ["line"], kind: .past)
				] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in false },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_internationalQR_validityTexts_current() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 1,
				validityTexts: { _ in [
					HolderDashboardViewController.ValidityText(lines: ["line"], kind: .current)
				] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in false },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_internationalQR_validityTexts_future() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 1,
				validityTexts: { _ in [
					HolderDashboardViewController.ValidityText(lines: ["line"], kind: .future(
						desiresToShowAutomaticallyBecomesValidFooter: false
					))
				] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in false },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_internationalQR_validityTexts_future_desiresToShowAutomaticallyBecomesValidFooter() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedInternationalCards.value = [
			.europeanUnionQR(
				title: "title",
				stackSize: 1,
				validityTexts: { _ in [
					HolderDashboardViewController.ValidityText(lines: ["line"], kind: .future(
						desiresToShowAutomaticallyBecomesValidFooter: true
					))
				] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in false },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
}
