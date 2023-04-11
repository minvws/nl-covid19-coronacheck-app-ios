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
import Shared
import TestingShared
import Persistence
@testable import Models
@testable import Managers
@testable import Resources

extension HolderDashboardViewModelTests {
	
	// MARK: Datasource Updating
	
	func test_didBecomeActiveNotification_triggersDatasourceReload() {
		// Arrange

		sut = vendSut()
		expect(self.qrCardDatasourceSpy.invokedReload) == false

		// Act
		NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

		// Assert
		expect(self.qrCardDatasourceSpy.invokedReload) == true
	}

	func test_viewWillAppear_triggersDatasourceReload() {
		// Arrange

		sut = vendSut()
		expect(self.qrCardDatasourceSpy.invokedReload) == false

		// Act
		sut.viewWillAppear()

		// Assert
		expect(self.qrCardDatasourceSpy.invokedReload) == true
	}

	func test_datasourceupdate_mutliplefailures_shouldShowHelpDeskErrorBeneathCard() {

		// Arrange
		environmentSpies.contactInformationSpy.stubbedPhoneNumberLink = "<a href=\"tel:TEST\">TEST</a>"
		sut = vendSut()

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])

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
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { _, _, _, _, _, _, error in
			expect(error?.message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk("<a href=\"tel:TEST\">TEST</a>")
			expect(self.environmentSpies.contactInformationSpy.invokedPhoneNumberLinkGetter) == true
		}))
	}

	// MARK: - Single, Currently Valid, International

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_1_of_2() {

		// Arrange
		sut = vendSut()

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
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).to(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
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
		expect(self.sut.internationalCards.value[3]).toEventually(beAddCertificateCard())
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_ExpiringSoon() {

		// Arrange
		sut = vendSut()

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
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).to(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
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
		expect(self.sut.internationalCards.value[3]).toEventually(beAddCertificateCard())
	}

	func test_datasourceupdate_multipleCurrentlyValidDCCs_IssuedAbroad() {

		// Arrange
		sut = vendSut()

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
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(6))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).to(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Dosis 1/2 (Duitsland)" // only vaccine has country in UI
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 15 juni 2021"
		}))
		expect(self.sut.internationalCards.value[3]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Type test: LP6464-4"
			expect(nowValidityTexts[0].lines[1]) == "Testdatum: donderdag 15 juli 16:02"
		}))
		expect(self.sut.internationalCards.value[4]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(1))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Geldig tot 11 mei 2022"
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_0_of_2() {

		// Arrange
		sut = vendSut()

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
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).to(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
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
		expect(self.sut.internationalCards.value[3]).toEventually(beAddCertificateCard())
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_nil_of_2() {

		// Arrange
		sut = vendSut()

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
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
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
		expect(self.sut.internationalCards.value[3]).toEventually(beAddCertificateCard())
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalTest() {
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		environmentSpies.mappingManagerSpy.stubbedGetTestTypeResult = "PCR (NAAT)"

		// Arrange
		sut = vendSut()

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in return EuCredentialAttributes.fake(dcc: .sampleWithTest()) }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
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
		expect(self.sut.internationalCards.value[3]).toEventually(beAddCertificateCard())
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalRecovery() {

		// Arrange
		sut = vendSut()

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		// Act
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in

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
		expect(self.sut.internationalCards.value[3]).toEventually(beAddCertificateCard())
	}

	// MARK: - Triple, Currently Valid, International

	func test_datasourceupdate_tripleCurrentlyValidInternationalVaccination() {

		// Arrange
		sut = vendSut()

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
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(6))
		
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.general_vaccinationcertificate_0G().capitalizingFirstLetter()

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 2
			expect(nowValidityTexts[0].lines[0]) == L.general_vaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "14 juli 2021"

			expect(expiryCountdownEvaluator?(now)) == nil
		}))

		expect(self.sut.internationalCards.value[3]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.general_recoverycertificate_0G().capitalizingFirstLetter()

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 1
			expect(nowValidityTexts[0].lines[0]) == "Geldig tot 11 mei 2022"

			expect(expiryCountdownEvaluator?(now)) == nil
		}))

		expect(self.sut.internationalCards.value[4]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(isLoading) == false
			expect(title) == L.general_testcertificate_0G().capitalizingFirstLetter()

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 2
			expect(nowValidityTexts[0].lines[0]) == L.general_testcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot donderdag 15 juli 16:02"

			expect(expiryCountdownEvaluator?(now)) == nil
		}))
	}

	// MARK: - Single, Not Yet Valid, International

	// This shouldn't happen because DCC Vaccines are immediately valid
	// But the test can at least track the behaviour in case it does.
	func test_datasourceupdate_singleNotYetValidInternationalVaccination() {

		// Arrange
		sut = vendSut()

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_vaccination_expires30DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in false }
			)
		]

		// Act
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).to(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
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
		sut = vendSut()

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in false }
			)
		]

		// Act
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards.value[1]).to(beDisclosurePolicyInformationCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in

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

	func test_datasourceupdate_internationalExpired() {

		// Arrange
		sut = vendSut()

		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
			.init(region: .europeanUnion, type: .recovery),
			.init(region: .europeanUnion, type: .test),
			.init(region: .europeanUnion, type: .vaccination),
			.init(region: .europeanUnion, type: .vaccinationassessment)
		]

		// Act
		qrCardDatasourceSpy.invokedDidUpdate?([], expiredCards)

		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(6))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
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

	func test_datasourceupdate_multipleDCC_1of2_2of2() {

		// Arrange
		sut = vendSut()

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
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
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
		sut = vendSut()
		
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
		qrCardDatasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_filledState_international_0G_message()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		
		expect(self.sut.internationalCards.value[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error in
			// check isLoading
			expect(title) == L.general_vaccinationcertificate_0G().capitalizingFirstLetter()
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
