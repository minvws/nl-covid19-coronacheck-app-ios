/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */
// swiftlint:disable file_length

import XCTest
@testable import CTR
import Nimble
import CoreData

extension HolderDashboardViewModelTests {
	
	// MARK: Datasource Updating
	
	func test_didBecomeActiveNotification_triggersDatasourceReload() {
		// Arrange
		
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		expect(self.datasourceSpy.invokedReload) == false

		// Act
		NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

		// Assert
		expect(self.datasourceSpy.invokedReload) == true
	}
	
	func test_viewWillAppear_triggersDatasourceReload() {
		// Arrange
		
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		expect(self.datasourceSpy.invokedReload) == false

		// Act
		sut.viewWillAppear()

		// Assert
		expect(self.datasourceSpy.invokedReload) == true
	}
	
	func test_datasourceupdate_mutliplefailures_shouldShowHelpDeskErrorBeneathCard() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: DashboardStrippenRefresher.Error.networkError(error: .invalidRequest, timestamp: now)),
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: true,
			errorOccurenceCount: 3
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(4))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { _, _, _, _, _, _, _, error in
			expect(error?.message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk()
		}))
	}
	
	// MARK: - Single VACCINE, Currently Valid, Domestic
	
	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination_3g() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(isDisabledByDisclosurePolicy) == false
			expect(disclosurePolicyLabel) == "3G"
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(1 * years * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot 20 augustus 2024"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.disclosurePolicy) == DisclosurePolicy.policy3G
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		
		expect(self.sut.domesticCards.value[3]).toEventually(beAddCertificateCard { title, didTapAdd in
			expect(title) == L.holder_dashboard_addCard_title()
			
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToCreateAQR) == false
			didTapAdd()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToCreateAQR) == true
		})
		
		expect(self.sut.internationalCards.value).toEventually(haveCount(3))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards.value[1]).toEventually(beOriginNotValidInThisRegionCard())
	}
	
	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination_1G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(isDisabledByDisclosurePolicy) == true
			expect(disclosurePolicyLabel) == "3G"
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		
		expect(self.sut.domesticCards.value[3]).toEventually(beAddCertificateCard())
		
		expect(self.sut.internationalCards.value).toEventually(haveCount(3))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards.value[1]).toEventually(beOriginNotValidInThisRegionCard())
	}
	
	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination_1G3G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G, .policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(isDisabledByDisclosurePolicy) == false
			expect(disclosurePolicyLabel) == "3G"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.disclosurePolicy) == DisclosurePolicy.policy3G
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		
		expect(self.sut.domesticCards.value[3]).toEventually(beAddCertificateCard())
		
		expect(self.sut.internationalCards.value).toEventually(haveCount(3))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards.value[1]).toEventually(beOriginNotValidInThisRegionCard())
	}
	
	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination_lessthan3years() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.valid5DaysAgo_vaccination_expires25DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot 9 augustus 2021"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot 9 augustus 2021"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		
		expect(self.sut.internationalCards.value).toEventually(haveCount(3))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards.value[1]).toEventually(beOriginNotValidInThisRegionCard())
	}
	
	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination_secondDose() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 2)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (2 doses)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (2 doses)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		
	}
	
	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination_expiringSoon() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.valid30DaysAgo_vaccination_expires60SecondsFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot 15 juli 2021"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .past
			expect(futureValidityTexts[0].lines).to(beEmpty())
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(24 * hours * ago))) == nil
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(22 * hours * ago))) == "Verloopt over 22 uur en 1 minuut"
			expect(expiryCountdownEvaluator?(now)) == "Verloopt over 1 minuut en 1 seconde"
		}))
	}
	
	// MARK: - Single TEST, Currently Valid, Domestic
	
	func test_datasourceupdate_singleCurrentlyValidDomesticTest_3G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in
					DomesticCredentialAttributes.sample(category: "3")
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.holder_dashboard_domesticQRCard_3G_title()
			expect(isDisabledByDisclosurePolicy) == false
			expect(disclosurePolicyLabel) == "3G"
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot vrijdag 16 juli 16:02"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot vrijdag 16 juli 16:02"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(17 * hours * fromNow))) == nil
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(19 * hours * fromNow))) == "Verloopt over 4 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(22.5 * hours))) == "Verloopt over 30 minuten"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(25 * hours * fromNow))) == nil
		}))
	}
	
	func test_datasourceupdate_singleCurrentlyValidDomesticTest_1G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G])
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in
					DomesticCredentialAttributes.sample(category: "1")
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only1Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(isDisabledByDisclosurePolicy) == false
			expect(disclosurePolicyLabel) == "1G"
			expect(title) == L.holder_dashboard_domesticQRCard_1G_title()
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot vrijdag 16 juli 16:02"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(17 * hours * fromNow))) == nil
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(19 * hours * fromNow))) == "Verloopt over 4 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(22.5 * hours))) == "Verloopt over 30 minuten"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(25 * hours * fromNow))) == nil
		}))
	}
	
	func test_datasourceupdate_singleCurrentlyValidDomesticTest_1G3G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G, .policy1G])
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in
					DomesticCredentialAttributes.sample(category: "1")
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(6))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_3Gand1Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(isDisabledByDisclosurePolicy) == false
			expect(disclosurePolicyLabel) == "3G"
			expect(title) == L.holder_dashboard_domesticQRCard_3G_title()
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot vrijdag 16 juli 16:02"

			// check didTapViewQR
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.disclosurePolicy) == .policy3G
			
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(17 * hours * fromNow))) == nil
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(19 * hours * fromNow))) == "Verloopt over 4 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(22.5 * hours))) == "Verloopt over 30 minuten"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(25 * hours * fromNow))) == nil
		}))
		expect(self.sut.domesticCards.value[3]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(isDisabledByDisclosurePolicy) == false
			expect(disclosurePolicyLabel) == "1G"
			expect(title) == L.holder_dashboard_domesticQRCard_1G_title()
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot vrijdag 16 juli 16:02"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot vrijdag 16 juli 16:02"
			
			// check didTapViewQR
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.disclosurePolicy) == .policy1G
			
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(17 * hours * fromNow))) == nil
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(19 * hours * fromNow))) == "Verloopt over 4 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(22.5 * hours))) == "Verloopt over 30 minuten"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(25 * hours * fromNow))) == nil
		}))
		expect(self.sut.domesticCards.value[4]).toEventually(beAddCertificateCard())
	}
	
	// MARK: - Multiple TEST, Currently Valid, Domestic
	
	func test_datasourceupdate_multpileCurrentlyValidDomesticTests_3G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in
					DomesticCredentialAttributes.sample(category: "3")
				}),
				greencards: [.init(
					id: sampleGreencardObjectID,
					origins: [
						.validOneDayAgo_test_expires1HourFromNow(),
						.validOneHourAgo_test_expires23HoursFromNow(),
						.validOneDayAgo_test_expires5MinutesFromNow()
					])
				],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.holder_dashboard_domesticQRCard_3G_title()
			expect(isDisabledByDisclosurePolicy) == false
			expect(disclosurePolicyLabel) == "3G"
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot vrijdag 16 juli 16:02"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot vrijdag 16 juli 16:02"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(17 * hours * fromNow))) == nil
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(19 * hours * fromNow))) == "Verloopt over 4 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(22.5 * hours))) == "Verloopt over 30 minuten"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(25 * hours * fromNow))) == nil
		}))
	}
	
	// MARK: - Single RECOVERY, Currently Valid, Domestic
	
	func test_datasourceupdate_singleCurrentlyValidDomesticRecovery_3g() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			expect(title) == L.holder_dashboard_domesticQRCard_3G_title()
			expect(isDisabledByDisclosurePolicy) == false
			expect(disclosurePolicyLabel) == "3G"
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_recoverycertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot 11 mei 2022"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.general_recoverycertificate().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot 11 mei 2022"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(299 * days * fromNow).addingTimeInterval(23 * hours))) == "Verloopt over 1 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(299 * days * fromNow).addingTimeInterval(1 * hours))) == "Verloopt over 23 uur"
		}))
	}
	
	func test_datasourceupdate_singleCurrentlyValidDomesticRecovery_1g() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G])
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only1Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard(test: { title, buttonText, didTapCallToAction, didTapClose in
			expect(title) == L.holder_dashboard_only1GaccessBanner_title()
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			expect(isDisabledByDisclosurePolicy) == true
			expect(disclosurePolicyLabel) == "3G"
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_recoverycertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot 11 mei 2022"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			
			expect(expiryCountdownEvaluator?(now)) == nil
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(299 * days * fromNow).addingTimeInterval(23 * hours))) == "Verloopt over 1 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(299 * days * fromNow).addingTimeInterval(1 * hours))) == "Verloopt over 23 uur"
		}))
	}
	
	func test_datasourceupdate_singleCurrentlyValidDomesticRecovery_1G3G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G, .policy1G])
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_3Gand1Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			expect(isDisabledByDisclosurePolicy) == false
			expect(disclosurePolicyLabel) == "3G"
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_recoverycertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot 11 mei 2022"
	
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(299 * days * fromNow).addingTimeInterval(23 * hours))) == "Verloopt over 1 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(299 * days * fromNow).addingTimeInterval(1 * hours))) == "Verloopt over 23 uur"
		}))
	}
	
	// MARK: - Single, Currently Valid, International
	
	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_1_of_2() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					return EuCredentialAttributes.fakeVaccination()
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Dosis 1/2"
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == "Dosis 1/2"
			expect(futureValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		expect(self.sut.internationalCards.value[2]).toEventually(beAddCertificateCard())
	}
	
	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_ExpiringSoon() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date)  in
					return EuCredentialAttributes.fakeVaccination()
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.valid30DaysAgo_vaccination_expires60SecondsFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Dosis 1/2"
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 15 juni 2021"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * minutes * fromNow))
			expect(futureValidityTexts[0].kind) == .past
			expect(futureValidityTexts[0].lines).to(beEmpty())
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_multipleCurrentlyValidDCCs_IssuedAbroad() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					EuCredentialAttributes.fake(dcc: .sampleWithVaccine(doseNumber: 1, totalDose: 2, country: "DE"), issuer: "NL")
				}),
				greencards: [
					.init(id: NSManagedObjectID(), origins: [.valid30DaysAgo_vaccination_expires60SecondsFromNow()])
				],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					EuCredentialAttributes.fake(dcc: .sampleWithTest(country: "BE"), issuer: "NL")
				}),
				greencards: [
					.init(id: NSManagedObjectID(), origins: [.validOneHourAgo_test_expires23HoursFromNow()])
				],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					EuCredentialAttributes.fake(dcc: .sampleWithRecovery(country: "IT"), issuer: "NL")
				}),
				greencards: [
					.init(id: NSManagedObjectID(), origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])
				],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(6))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Dosis 1/2 (Duitsland)" // only vaccine has country in UI
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 15 juni 2021"
		}))
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Type test: LP6464-4"
			expect(nowValidityTexts[0].lines[1]) == "Testdatum: donderdag 15 juli 16:02"
		}))
		expect(self.sut.internationalCards.value[3]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(1))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Geldig tot 11 mei 2022"
		}))
		expect(self.sut.internationalCards.value[5]).toEventually(beRecommendCoronaMelderCard())
	}
	
	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_0_of_2() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 0, totalDose: 2))
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Dosis 0/2"
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_nil_of_2() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: nil, totalDose: 2))
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			// Here we've got an invalid `EuCredentialAttributes.DigitalCovidCertificate` (nil of 2)
			// So we fallback to default `localizedDateExplanation` for an EU origin:
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Vaccinatiebewijs:"
			expect(nowValidityTexts[0].lines[1]) == "14 juli 2021"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_singleCurrentlyValidInternationalTest() {
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		environmentSpies.mappingManagerSpy.stubbedGetTestTypeResult = "PCR (NAAT)"
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in return EuCredentialAttributes.fake(dcc: .sampleWithTest()) }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Type test: PCR (NAAT)"
			expect(nowValidityTexts[0].lines[1]) == "Testdatum: donderdag 15 juli 16:02"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == "Type test: PCR (NAAT)"
			expect(futureValidityTexts[0].lines[1]) == "Testdatum: donderdag 15 juli 16:02"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_singleCurrentlyValidInternationalRecovery() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(1))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Geldig tot 11 mei 2022"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(299 * days * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == "Geldig tot 11 mei 2022"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(299 * days * fromNow))) == "Verloopt over 24 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval((299 * days) - (6 * hours) * fromNow))) == "Verloopt over 1 dag en 6 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval((299 * days) + (12 * hours) * fromNow))) == "Verloopt over 12 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval((299 * days) + (23 * hours) + (30 * minutes) * fromNow))) == "Verloopt over 30 minuten"
		}))
	}
	
	// MARK: - Multiple, One Valid, One not yet Valid, Domestic
	
	func test_datasourceupdate_validVaccine_prematureRecovery_domestic_3G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1),
					.validIn48Hours_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(2))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"
			expect(nowValidityTexts[1].lines).to(haveCount(2))
			expect(nowValidityTexts[1].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[1].lines[0]) == L.general_recoverycertificate().capitalized + ":"
			expect(nowValidityTexts[1].lines[1]) == "geldig vanaf 17 juli 17:02 tot 11 mei 2022"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"
			expect(futureValidityTexts[1].kind) == .current
			expect(futureValidityTexts[1].lines[0]) == L.general_recoverycertificate().capitalized + ":"
			expect(futureValidityTexts[1].lines[1]) == "geldig tot 11 mei 2022"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		expect(self.sut.domesticCards.value[3]).toEventually(beAddCertificateCard())
	}
	
	func test_datasourceupdate_validVaccine_prematureRecovery_domestic_1G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1),
					.validIn48Hours_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only1Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.holder_dashboard_domesticQRCard_3G_title()
			expect(isDisabledByDisclosurePolicy) == true
			expect(disclosurePolicyLabel) == "3G"
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(2))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"
			expect(nowValidityTexts[1].lines).to(haveCount(2))
			expect(nowValidityTexts[1].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[1].lines[0]) == L.general_recoverycertificate().capitalized + ":"
			expect(nowValidityTexts[1].lines[1]) == "geldig vanaf 17 juli 17:02 tot 11 mei 2022"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		expect(self.sut.domesticCards.value[3]).toEventually(beAddCertificateCard())
	}
	
	// MARK: - Triple, Currently Valid, Domestic
	
	func test_datasourceupdate_tripleCurrentlyValidDomestic_3G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1),
					.validOneHourAgo_test_expires23HoursFromNow(),
					.validOneHourAgo_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(
			test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
				
				// check isLoading
				expect(isLoading) == false
				
				let nowValidityTexts = validityTextEvaluator(now)
				expect(nowValidityTexts).to(haveCount(3))
				expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
				expect(nowValidityTexts[1].lines[0]) == L.general_recoverycertificate().capitalized + ":"
				expect(nowValidityTexts[2].lines[0]) == L.general_testcertificate().capitalized + ":"
				
				expect(expiryCountdownEvaluator?(now)) == nil
			}
		))
		
	}
	
	func test_datasourceupdate_tripleCurrentlyValidDomestic_1G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1),
					.validOneHourAgo_test_expires23HoursFromNow(),
					.validOneHourAgo_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(6))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only1Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(
			test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
				
				expect(isLoading) == false
				expect(title) == L.holder_dashboard_domesticQRCard_1G_title()
				expect(isDisabledByDisclosurePolicy) == false
				expect(disclosurePolicyLabel) == "1G"
				
				let nowValidityTexts = validityTextEvaluator(now)
				expect(nowValidityTexts).to(haveCount(1))
				expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
				
				self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs = false
				didTapViewQR()
				expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
				
				expect(expiryCountdownEvaluator?(now)) == nil
			}
		))
		expect(self.sut.domesticCards.value[3]).toEventually(beDomesticQRCard(
			test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
				
				expect(isLoading) == false
				expect(title) == L.holder_dashboard_domesticQRCard_3G_title()
				expect(isDisabledByDisclosurePolicy) == true
				expect(disclosurePolicyLabel) == "3G"
				
				let nowValidityTexts = validityTextEvaluator(now)
				expect(nowValidityTexts).to(haveCount(2))
				expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
				expect(nowValidityTexts[1].lines[0]) == L.general_recoverycertificate().capitalized + ":"
				
				self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs = false
				didTapViewQR()
				expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
				
				expect(expiryCountdownEvaluator?(now)) == nil
			}
		))
		
		expect(self.sut.domesticCards.value[4]).toEventually(beAddCertificateCard())
	}
	
	func test_datasourceupdate_tripleCurrentlyValidDomestic_1G3G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G, .policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1),
					.validOneHourAgo_test_expires23HoursFromNow(),
					.validOneHourAgo_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(6))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_3Gand1Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(
			test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
				
				expect(isLoading) == false
				expect(title) == L.holder_dashboard_domesticQRCard_3G_title()
				expect(isDisabledByDisclosurePolicy) == false
				expect(disclosurePolicyLabel) == "3G"
				
				let nowValidityTexts = validityTextEvaluator(now)
				expect(nowValidityTexts).to(haveCount(2))
				expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
				expect(nowValidityTexts[1].lines[0]) == L.general_recoverycertificate().capitalized + ":"
				
				self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs = false
				didTapViewQR()
				expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
				
				expect(expiryCountdownEvaluator?(now)) == nil
			}
		))
		expect(self.sut.domesticCards.value[3]).toEventually(beDomesticQRCard(
			test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
				
				expect(isLoading) == false
				expect(title) == L.holder_dashboard_domesticQRCard_1G_title()
				expect(isDisabledByDisclosurePolicy) == false
				expect(disclosurePolicyLabel) == "1G"
				
				let nowValidityTexts = validityTextEvaluator(now)
				expect(nowValidityTexts).to(haveCount(1))
				expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
				
				self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs = false
				didTapViewQR()
				expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
				
				expect(expiryCountdownEvaluator?(now)) == nil
			}
		))
		
		expect(self.sut.domesticCards.value[4]).toEventually(beAddCertificateCard())
	}
	
	func test_datasourceupdate_tripleCurrentlyValidDomestic_oneExpiringSoon() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.valid30DaysAgo_vaccination_expires60SecondsFromNow(),
					.validOneHourAgo_test_expires23HoursFromNow(),
					.validOneHourAgo_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(3))
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[1].lines[0]) == L.general_recoverycertificate().capitalized + ":"
			expect(nowValidityTexts[2].lines[0]) == L.general_testcertificate().capitalized + ":"
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_tripleCurrentlyValidDomestic_allExpiringSoon() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.valid30DaysAgo_vaccination_expires60SecondsFromNow(),
					.validOneDayAgo_test_expires5MinutesFromNow(),
					.validOneMonthAgo_recovery_expires2HoursFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(3))
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[1].lines[0]) == L.general_recoverycertificate().capitalized + ":"
			expect(nowValidityTexts[2].lines[0]) == L.general_testcertificate().capitalized + ":"
			
			expect(expiryCountdownEvaluator?(now)) == "Verloopt over 2 uur"
		}))
	}
	
	// MARK: - Triple, Currently Valid, International
	
	func test_datasourceupdate_tripleCurrentlyValidInternationalVaccination() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let vaccineGreenCardID = NSManagedObjectID()
		let testGreenCardID = NSManagedObjectID()
		let recoveryGreenCardID = NSManagedObjectID()
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: vaccineGreenCardID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: recoveryGreenCardID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: testGreenCardID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(6))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.general_vaccinationcertificate().capitalizingFirstLetter()
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 2
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "14 juli 2021"
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.general_recoverycertificate().capitalizingFirstLetter()
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 1
			expect(nowValidityTexts[0].lines[0]) == "Geldig tot 11 mei 2022"
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		
		expect(self.sut.internationalCards.value[3]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.general_testcertificate().capitalizingFirstLetter()
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 2
			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot donderdag 15 juli 16:02"
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	// MARK: - Triple, Currently Valid, Domestic but viewing International Tab
	
	func test_datasourceupdate_tripleCurrentlyValidDomesticButViewingInternationalTab() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1),
					.validOneHourAgo_test_expires23HoursFromNow(),
					.validOneHourAgo_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(5))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _, _ in
			expect(message) == L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(L.general_vaccinationcertificate())
		}))
		
		expect(self.sut.internationalCards.value[2]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _, _ in
			expect(message) == L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(L.general_recoverycertificate())
		}))
		
		expect(self.sut.internationalCards.value[3]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _, _ in
			expect(message) == L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(L.general_testcertificate())
		}))
	}
	
	// MARK: - Triple, Currently Valid, International
	
	func test_datasourceupdate_tripleCurrentlyValidInternationalVaccinationButViewingDomesticTab() {
		
		// Arrange
		environmentSpies.userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let vaccineGreenCardID = NSManagedObjectID()
		let testGreenCardID = NSManagedObjectID()
		let recoveryGreenCardID = NSManagedObjectID()
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: vaccineGreenCardID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: recoveryGreenCardID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: testGreenCardID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(6))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		
		expect(self.sut.domesticCards.value[2]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _, _ in
			expect(message) == L.holderDashboardOriginNotValidInNetherlandsButIsInEU(L.general_vaccinationcertificate())
		}))
		
		expect(self.sut.domesticCards.value[3]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _, _ in
			expect(message) == L.holderDashboardOriginNotValidInNetherlandsButIsInEU(L.general_recoverycertificate())
		}))
		
		expect(self.sut.domesticCards.value[4]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _, _ in
			expect(message) == L.holderDashboardOriginNotValidInNetherlandsButIsInEU(L.general_testcertificate())
		}))
	}
	
	func test_datasourceupdate_singleCurrentlyValidInternationalVaccinationButViewingDomesticTab_tappingMoreInfo() {
		
		// Arrange
		environmentSpies.userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let vaccineGreenCardID = NSManagedObjectID()
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: vaccineGreenCardID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(4))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard())
		
		expect(self.sut.domesticCards.value[2]).toEventually(beOriginNotValidInThisRegionCard(test: { _, _, didTapMoreInfo in
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQR) == false
			didTapMoreInfo()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQR) == true
		}))
	}
	
	// MARK: - Valid VaccinationAssessment, Test expired
	
	func test_datasourceupdate_currentlyValidVaccinationAssessment_expiredTest_domesticTab_3G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: NSManagedObjectID(), origins: [
					.init(
						type: QRCodeOriginType.vaccinationassessment,
						eventDate: now.addingTimeInterval(72 * hours * ago),
						expirationTime: now.addingTimeInterval(11 * days * fromNow),
						validFromDate: now.addingTimeInterval(72 * hours * ago),
						doseNumber: nil
					),
					.init(
						type: QRCodeOriginType.test,
						eventDate: now.addingTimeInterval(60 * hours * ago),
						expirationTime: now.addingTimeInterval(12 * hours * ago),
						validFromDate: now.addingTimeInterval(60 * hours * ago),
						doseNumber: nil
					)
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: NSManagedObjectID(), origins: [
					.init(
						type: QRCodeOriginType.test,
						eventDate: now.addingTimeInterval(60 * hours * ago),
						expirationTime: now.addingTimeInterval(30 * days * fromNow),
						validFromDate: now.addingTimeInterval(60 * hours * ago),
						doseNumber: nil
					)
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, _, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(2))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_visitorPass().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot maandag 26 juli 17:02"
			expect(nowValidityTexts[1].kind) == .past // the expired test (hidden in UI)
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		
		expect(self.sut.internationalCards.value).toEventually(haveCount(5))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards.value[1]).toEventually(beOriginNotValidInThisRegionCard(test: { title, callToActionButtonText, _ in
			expect(title) == L.holder_dashboard_visitorPassInvalidOutsideNLBanner_title()
			expect(callToActionButtonText) == L.general_readmore()
		}))
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, _, expiryCountdownEvaluator, error in
			// check isLoading
			expect(title) == L.general_testcertificate().capitalized
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot dinsdag 13 juli 05:02"
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_currentlyValidVaccinationAssessment_expiredTest_domesticTab_1G3G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G, .policy1G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: NSManagedObjectID(), origins: [
					.init(
						type: QRCodeOriginType.vaccinationassessment,
						eventDate: now.addingTimeInterval(72 * hours * ago),
						expirationTime: now.addingTimeInterval(11 * days * fromNow),
						validFromDate: now.addingTimeInterval(72 * hours * ago),
						doseNumber: nil
					),
					.init(
						type: QRCodeOriginType.test,
						eventDate: now.addingTimeInterval(60 * hours * ago),
						expirationTime: now.addingTimeInterval(12 * hours * ago),
						validFromDate: now.addingTimeInterval(60 * hours * ago),
						doseNumber: nil
					)
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: NSManagedObjectID(), origins: [
					.init(
						type: QRCodeOriginType.test,
						eventDate: now.addingTimeInterval(60 * hours * ago),
						expirationTime: now.addingTimeInterval(30 * days * fromNow),
						validFromDate: now.addingTimeInterval(60 * hours * ago),
						doseNumber: nil
					)
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.holder_dashboard_domesticQRCard_3G_title()
			expect(isDisabledByDisclosurePolicy) == false
			expect(disclosurePolicyLabel) == "3G"
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_visitorPass().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot maandag 26 juli 17:02"
			
			self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs = false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		
		expect(self.sut.internationalCards.value).toEventually(haveCount(5))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards.value[1]).toEventually(beOriginNotValidInThisRegionCard(test: { title, callToActionButtonText, _ in
			expect(title) == L.holder_dashboard_visitorPassInvalidOutsideNLBanner_title()
			expect(callToActionButtonText) == L.general_readmore()
		}))
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, _, expiryCountdownEvaluator, error in
			// check isLoading
			expect(title) == L.general_testcertificate().capitalized
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot dinsdag 13 juli 05:02"
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_currentlyValidVaccinationAssessment_expiredTest_domesticTab_1G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy1G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: NSManagedObjectID(), origins: [
					.init(
						type: QRCodeOriginType.vaccinationassessment,
						eventDate: now.addingTimeInterval(72 * hours * ago),
						expirationTime: now.addingTimeInterval(11 * days * fromNow),
						validFromDate: now.addingTimeInterval(72 * hours * ago),
						doseNumber: nil
					),
					.init(
						type: QRCodeOriginType.test,
						eventDate: now.addingTimeInterval(60 * hours * ago),
						expirationTime: now.addingTimeInterval(12 * hours * ago),
						validFromDate: now.addingTimeInterval(60 * hours * ago),
						doseNumber: nil
					)
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: NSManagedObjectID(), origins: [
					.init(
						type: QRCodeOriginType.test,
						eventDate: now.addingTimeInterval(60 * hours * ago),
						expirationTime: now.addingTimeInterval(30 * days * fromNow),
						validFromDate: now.addingTimeInterval(60 * hours * ago),
						doseNumber: nil
					)
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.holder_dashboard_domesticQRCard_3G_title()
			expect(isDisabledByDisclosurePolicy) == true
			expect(disclosurePolicyLabel) == "3G"
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_visitorPass().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot maandag 26 juli 17:02"
			
			self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs = false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
		
		expect(self.sut.internationalCards.value).toEventually(haveCount(5))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards.value[1]).toEventually(beOriginNotValidInThisRegionCard(test: { title, callToActionButtonText, _ in
			expect(title) == L.holder_dashboard_visitorPassInvalidOutsideNLBanner_title()
			expect(callToActionButtonText) == L.general_readmore()
		}))
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, _, expiryCountdownEvaluator, error in
			// check isLoading
			expect(title) == L.general_testcertificate().capitalized
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot dinsdag 13 juli 05:02"
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	// MARK: - Single, Not Yet Valid, Domestic
	
	func test_datasourceupdate_singleNotYetValidDomesticVaccination() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_singleNotYetValidDomesticVaccination_lessThan3Years() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_vaccination_expires30DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 tot 14 augustus 2021"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 tot 14 augustus 2021"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_singleNotYetValidDomesticVaccination_dose2() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_vaccination_expires30DaysFromNow(doseNumber: 2)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (2 doses)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 tot 14 augustus 2021"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + " (2 doses)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 tot 14 augustus 2021"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_singleNotYetValidDomesticRecovery() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in false }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.general_recoverycertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 tot 11 mei 2022"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == L.general_recoverycertificate().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 tot 11 mei 2022"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_singleNotYetValidDomesticTest_3G() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validInFiveMinutes_test_expires24HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in false }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard(test: { disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			
			expect(title) == L.holder_dashboard_domesticQRCard_3G_title()
			expect(isDisabledByDisclosurePolicy) == false
			expect(disclosurePolicyLabel) == "3G"
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 15 juli 17:07"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	// MARK: - Single, Not Yet Valid, International
	
	// This shouldn't happen because DCC Vaccines are immediately valid
	// But the test can at least track the behaviour in case it does.
	func test_datasourceupdate_singleNotYetValidInternationalVaccination() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_vaccination_expires30DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in false }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 2021"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_singleNotYetValidInternationalRecovery() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in false }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(1))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == "Geldig vanaf 17 juli 17:02 tot 11 mei 2022"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == "Geldig vanaf 17 juli 17:02 tot 11 mei 2022"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	 
	// MARK: - Expired cards
	
	func test_datasourceupdate_domesticExpired() {
		
		// Arrange
		environmentSpies.userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
			.init(region: .domestic, type: .recovery),
			.init(region: .domestic, type: .test),
			.init(region: .domestic, type: .vaccination),
			.init(region: .domestic, type: .vaccinationassessment)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?([], expiredCards)
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(6))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle) == nil
		}))
		expect(self.sut.domesticCards.value[1]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_domesticRecovery_title()
		}))
		expect(self.sut.domesticCards.value[2]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_domesticTest_title()
		}))
		expect(self.sut.domesticCards.value[3]).toEventually(beExpiredVaccinationQRCard(test: { message, callToActionButtonText, callToAction, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_domesticVaccine_title()
			expect(callToActionButtonText) == L.general_readmore()
			
			callToAction() // user taps..
			
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutExpiredDomesticVaccination) == true
		}))
		expect(self.sut.domesticCards.value[4]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_visitorPass_title()
		}))
	}
	
	func test_datasourceupdate_domesticExpired_tapForMoreInfo() {
		
		// Arrange
		environmentSpies.userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
		
		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
			.init(region: .domestic, type: .recovery)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?([], expiredCards)
		
		// Assert
		expect(self.sut.domesticCards.value).toEventually(haveCount(3))
		
		// At this point cache the domestic cards value, because `didTapClose()` mutates it:
		let domesticCards = sut.domesticCards
		
		expect(domesticCards.value[0]).toEventually(beHeaderMessageCard())
		expect(domesticCards.value[1]).toEventually(beExpiredQRCard(test: { message, didTapClose in
			expect(message) == L.holder_dashboard_originExpiredBanner_domesticRecovery_title()
			didTapClose()
			
			// Check the non-cached value now to check that the Expired QR row was removed:
			expect(self.sut.domesticCards.value).to(haveCount(3))
			expect(self.sut.domesticCards.value[0]).to(beEmptyStateDescription())
			expect(self.sut.domesticCards.value[1]).to(beDisclosurePolicyInformationCard())
			expect(self.sut.domesticCards.value[2]).to(beEmptyStatePlaceholderImage())
			
		}))
	}
	
	func test_datasourceupdate_internationalExpired() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
			.init(region: .europeanUnion, type: .recovery),
			.init(region: .europeanUnion, type: .test),
			.init(region: .europeanUnion, type: .vaccination),
			.init(region: .europeanUnion, type: .vaccinationassessment)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?([], expiredCards)
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(5))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		})
		expect(self.sut.internationalCards.value[1]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_internationalRecovery_title()
		}))
		expect(self.sut.internationalCards.value[2]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_internationalTest_title()
		}))
		expect(self.sut.internationalCards.value[3]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_internationalVaccine_title()
		}))
		expect(self.sut.internationalCards.value[4]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_visitorPass_title()
		}))
	}
	
	func test_datasourceupdate_domesticExpiredButOnInternationalTab() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
			.init(region: .domestic, type: .recovery),
			.init(region: .domestic, type: .test),
			.init(region: .domestic, type: .vaccination)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?([], expiredCards)
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(2))
		expect(self.sut.internationalCards.value[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards.value[1]).toEventually(beEmptyStatePlaceholderImage())
	}
	
	func test_datasourceupdate_multipleDCC_1of2_2of2() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let oneOfTwoGreencardObjectID = NSManagedObjectID()
		let twoOfTwoGreencardObjectID = NSManagedObjectID()
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					if greencard.id === oneOfTwoGreencardObjectID {
						return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 1, totalDose: 2))
					} else if greencard.id === twoOfTwoGreencardObjectID {
						return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 2, totalDose: 2))
					} else {
						fail("Unrecognised greencard received in closure")
						return nil
					}
				}),
				greencards: [
					.init(id: oneOfTwoGreencardObjectID, origins: [.valid30DaysAgo_vaccination_expires60SecondsFromNow()]),
					.init(id: twoOfTwoGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires30DaysFromNow()])
				],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			
			expect(stackSize) == 2
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(2))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Dosis 2/2"
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"
			expect(nowValidityTexts[1].lines).to(haveCount(2))
			expect(nowValidityTexts[1].kind) == .current
			expect(nowValidityTexts[1].lines[0]) == "Dosis 1/2"
			expect(nowValidityTexts[1].lines[1]) == "Vaccinatiedatum: 15 juni 2021"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs[0]) === oneOfTwoGreencardObjectID
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs[1]) === twoOfTwoGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
	
	func test_datasourceupdate_multipleDCC_1of2_2of2_3of2_3of3() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		let oneOfTwoGreencardObjectID = NSManagedObjectID()
		let twoOfTwoGreencardObjectID = NSManagedObjectID()
		let threeOfTwoGreencardObjectID = NSManagedObjectID()
		let threeOfThreeGreencardObjectID = NSManagedObjectID()
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					if greencard.id === oneOfTwoGreencardObjectID {
						return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 1, totalDose: 2))
					} else if greencard.id === twoOfTwoGreencardObjectID {
						return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 2, totalDose: 2))
					} else if greencard.id === threeOfTwoGreencardObjectID {
						return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 3, totalDose: 2))
					} else if greencard.id === threeOfThreeGreencardObjectID {
						return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 3, totalDose: 3))
					} else {
						fail("Unrecognised greencard received in closure")
						return nil
					}
				}),
				greencards: [
					.init(id: oneOfTwoGreencardObjectID, origins: [.valid30DaysAgo_vaccination_expires60SecondsFromNow()]),
					.init(id: twoOfTwoGreencardObjectID, origins: [.valid15DaysAgo_vaccination_expires14DaysFromNow()]),
					.init(id: threeOfTwoGreencardObjectID, origins: [.valid5DaysAgo_vaccination_expires25DaysFromNow()]),
					.init(id: threeOfThreeGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires30DaysFromNow()])
				],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(title) == L.general_vaccinationcertificate().capitalizingFirstLetter()
			expect(isLoading) == false
			
			expect(stackSize) == 3 // max value here is 3 - shouldn't be 4.
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(4))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Dosis 3/3"
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"
			expect(nowValidityTexts[1].lines).to(haveCount(2))
			expect(nowValidityTexts[1].kind) == .current
			expect(nowValidityTexts[1].lines[0]) == "Dosis 3/2"
			expect(nowValidityTexts[1].lines[1]) == "Vaccinatiedatum: 10 juli 2021"
			expect(nowValidityTexts[2].lines).to(haveCount(2))
			expect(nowValidityTexts[2].kind) == .current
			expect(nowValidityTexts[2].lines[0]) == "Dosis 2/2"
			expect(nowValidityTexts[2].lines[1]) == "Vaccinatiedatum: 30 juni 2021"
			expect(nowValidityTexts[3].lines).to(haveCount(2))
			expect(nowValidityTexts[3].kind) == .current
			expect(nowValidityTexts[3].lines[0]) == "Dosis 1/2"
			expect(nowValidityTexts[3].lines[1]) == "Vaccinatiedatum: 15 juni 2021"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs[0]) === oneOfTwoGreencardObjectID
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs[1]) === twoOfTwoGreencardObjectID
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs[2]) === threeOfTwoGreencardObjectID
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs[3]) === threeOfThreeGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}
}
