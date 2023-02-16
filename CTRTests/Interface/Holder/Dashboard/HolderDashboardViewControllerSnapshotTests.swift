/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable file_length type_body_length type_name

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
		viewModelSpy.stubbedSelectedTab = Observable(value: .domestic)
		viewModelSpy.stubbedDomesticCards = Observable(value: [])
		viewModelSpy.stubbedInternationalCards = Observable(value: [])
		viewModelSpy.stubbedPrimaryButtonTitle = Observable(value: L.holderMenuProof())
		viewModelSpy.stubbedShouldShowTabBar = Observable(value: false)
		viewModelSpy.stubbedCurrentlyPresentedAlert = Observable(value: nil)
		viewModelSpy.stubbedDashboardRegionToggleValue = .domestic
		viewModelSpy.stubbedShouldShowAddCertificateFooter = Observable(value: false)
		viewModelSpy.stubbedShouldShowOnlyInternationalPane = Observable(value: false)
	}
	
	func testInitial() {
		
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_headerMessage() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)

		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.headerMessage(message: "Message", buttonTitle: nil)
		]

		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_headerMessage_withButtonTitle() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.headerMessage(message: "Message", buttonTitle: "Button title")
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_emptyStateDescription() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.emptyStateDescription(message: "Message", buttonTitle: nil)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_emptyStateDescription_withButtonTitle() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.emptyStateDescription(message: "Message", buttonTitle: "Button title")
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_emptyStatePlaceholdImage_domestic() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.emptyStatePlaceholderImage(image: I.dashboard.domestic()!, title: L.holderDashboardEmptyDomesticTitle())
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_emptyStatePlaceholdImage_international() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.emptyStatePlaceholderImage(image: I.dashboard.international()!, title: L.holderDashboardEmptyInternationalTitle())
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_addCertificate() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.addCertificate(title: "Title", didTapAdd: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_expiredQR() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.expiredQR(message: "Title", didTapClose: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_expiredVaccinationQR() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.expiredVaccinationQR(message: "message", callToActionButtonText: "callToActionButtonText", didTapCallToAction: {}, didTapClose: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_originNotValidInThisRegion() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.originNotValidInThisRegion(message: "message", callToActionButtonText: "callToActionButtonText", didTapCallToAction: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_deviceHasClockDeviation() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.deviceHasClockDeviation(message: "message", callToActionButtonText: "callToActionButtonText", didTapCallToAction: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_configAlmostOutOfDate() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.configAlmostOutOfDate(message: "message", callToActionButtonText: "callToActionButtonText", didTapCallToAction: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_errorMessage_short() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
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
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
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
	
	func test_newValidityInfoForVaccinationAndRecoveries() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.newValidityInfoForVaccinationAndRecoveries(title: "title", buttonText: "buttonText", didTapCallToAction: {}, didTapClose: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_completeYourVaccinationAssessment() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.completeYourVaccinationAssessment(title: "title", buttonText: "buttonText", didTapCallToAction: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_vaccinationAssessmentInvalidOutsideNL() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.vaccinationAssessmentInvalidOutsideNL(title: "title", buttonText: "buttonText", didTapCallToAction: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_recommendedUpdate() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.recommendedUpdate(message: "message", callToActionButtonText: "callToActionButtonText", didTapCallToAction: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_disclosurePolicyInformation() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.disclosurePolicyInformation(title: "title", buttonText: "buttonText", accessibilityIdentifier: "accessibilityIdentifier", didTapCallToAction: {}, didTapClose: {})
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	// MARK: - Domestic QR -
	
	func test_domesticQR_staticTexts() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
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
	
	func test_domesticQR_buttonEnabled() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
				validityTexts: { _ in [] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in true },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_domesticQR_buttonEnabled_butDisabledByDisclosurePolicy() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: true,
				validityTexts: { _ in [] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in true },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_domesticQR_buttonDisabled_loading() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
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
	
	func test_domesticQR_buttonEnabled_loading() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
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
	
	func test_domesticQR_expiryCountdown() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
				validityTexts: { _ in [] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in true },
				expiryCountdownEvaluator: { _ in "Expiry text" },
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_domesticQR_validityText_past() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
				validityTexts: { _ in [
					HolderDashboardViewController.ValidityText(
						lines: ["line"],
						kind: .past
					)
				] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in true },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_domesticQR_validityText_current_longline() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
				validityTexts: { _ in [
					HolderDashboardViewController.ValidityText(
						lines: ["line is very very very very very very very very long "],
						kind: .current
					)
				] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in true },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_domesticQR_validityText_current_longlines() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
				validityTexts: { _ in [
					HolderDashboardViewController.ValidityText(
						lines: ["line is very very very very very very very very long "],
						kind: .current
					),
					HolderDashboardViewController.ValidityText(
						lines: ["line is very very very very very very very very long "],
						kind: .current
					)
				] },
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in true },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_domesticQR_validityText_future() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
				validityTexts: { _ in [
					HolderDashboardViewController.ValidityText(
						lines: ["line"],
						kind: .future(desiresToShowAutomaticallyBecomesValidFooter: false)
					)
				]},
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in true },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	func test_domesticQR_validityText_future_desiresToShowAutomaticallyBecomesValidFooter_buttonDisabled() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
				validityTexts: { _ in [
					HolderDashboardViewController.ValidityText(
						lines: ["line"],
						kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)
					)
				]},
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
	
	func test_domesticQR_validityText_future_desiresToShowAutomaticallyBecomesValidFooter_buttonEnabled() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
			.domesticQR(
				disclosurePolicyLabel: "NL",
				title: "title",
				isDisabledByDisclosurePolicy: false,
				validityTexts: { _ in [
					HolderDashboardViewController.ValidityText(
						lines: ["line"],
						kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)
					)
				]},
				isLoading: false,
				didTapViewQR: {},
				buttonEnabledEvaluator: { _ in true },
				expiryCountdownEvaluator: nil,
				error: nil
			)
		]
		
		// Assert
		assertSnapshot(matching: sut, as: .image)
	}
	
	// MARK: - International QR -
	
	func test_internationalQR_static() {

		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		
		// Act
		viewModelSpy.stubbedDomesticCards.value = [
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
		viewModelSpy.stubbedDomesticCards.value = [
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
		viewModelSpy.stubbedDomesticCards.value = [
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
		viewModelSpy.stubbedDomesticCards.value = [
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
		viewModelSpy.stubbedDomesticCards.value = [
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
		viewModelSpy.stubbedDomesticCards.value = [
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
		viewModelSpy.stubbedDomesticCards.value = [
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
		viewModelSpy.stubbedDomesticCards.value = [
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
		viewModelSpy.stubbedDomesticCards.value = [
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
		viewModelSpy.stubbedDomesticCards.value = [
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
		viewModelSpy.stubbedDomesticCards.value = [
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
