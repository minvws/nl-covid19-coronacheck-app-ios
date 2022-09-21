/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import CoreData

class HolderDashboardViewModelTests: XCTestCase {

	/// Subject under test
	var sut: HolderDashboardViewModel!
	var configSpy: ConfigurationGeneralSpy!
	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	var qrCardDatasourceSpy: HolderDashboardDatasourceSpy!
	var blockedEventsSpy: HolderDashboardBlockedEventsDatasourceSpy!
	var strippenRefresherSpy: DashboardStrippenRefresherSpy!
	var sampleGreencardObjectID: NSManagedObjectID!
	var configurationNotificationManagerSpy: ConfigurationNotificationManagerSpy!
	var vaccinationAssessmentNotificationManagerSpy: VaccinationAssessmentNotificationManagerSpy!
	var environmentSpies: EnvironmentSpies!
	private static var initialTimeZone: TimeZone?

	override class func setUp() {
		super.setUp()
		initialTimeZone = NSTimeZone.default
		NSTimeZone.default = TimeZone(abbreviation: "CEST")!
	}

	override class func tearDown() {
		super.tearDown()

		if let timeZone = initialTimeZone {
			NSTimeZone.default = timeZone
		}
	}

	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()

		configSpy = ConfigurationGeneralSpy()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		qrCardDatasourceSpy = HolderDashboardDatasourceSpy()
		blockedEventsSpy = HolderDashboardBlockedEventsDatasourceSpy()
		strippenRefresherSpy = DashboardStrippenRefresherSpy()
		configurationNotificationManagerSpy = ConfigurationNotificationManagerSpy()
		configurationNotificationManagerSpy.stubbedAlmostOutOfDateObservatory = Observatory.create().0
		vaccinationAssessmentNotificationManagerSpy = VaccinationAssessmentNotificationManagerSpy()
		sampleGreencardObjectID = NSManagedObjectID()
	}

	func vendSut(dashboardRegionToggleValue: QRCodeValidityRegion, appVersion: String = "1.0.0", activeDisclosurePolicies: [DisclosurePolicy] = [.policy3G]) -> HolderDashboardViewModel {

		environmentSpies.userSettingsSpy.stubbedDashboardRegionToggleValue = dashboardRegionToggleValue
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.disclosurePolicies = activeDisclosurePolicies.map { $0.featureFlag }
		environmentSpies.featureFlagManagerSpy.stubbedAreBothDisclosurePoliciesEnabledResult = activeDisclosurePolicies.sorted(by: { $0.featureFlag < $1.featureFlag }) == [.policy1G, .policy3G]
		environmentSpies.featureFlagManagerSpy.stubbedIs1GExclusiveDisclosurePolicyEnabledResult = activeDisclosurePolicies == [.policy1G]
		environmentSpies.featureFlagManagerSpy.stubbedIs3GExclusiveDisclosurePolicyEnabledResult = activeDisclosurePolicies == [.policy3G]
		environmentSpies.featureFlagManagerSpy.stubbedAreZeroDisclosurePoliciesEnabledResult = activeDisclosurePolicies.isEmpty
		return HolderDashboardViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			qrcardDatasource: qrCardDatasourceSpy,
			blockedEventsDatasource: blockedEventsSpy,
			strippenRefresher: strippenRefresherSpy,
			configurationNotificationManager: configurationNotificationManagerSpy,
			vaccinationAssessmentNotificationManager: vaccinationAssessmentNotificationManagerSpy,
			versionSupplier: AppVersionSupplierSpy(version: appVersion)
		)
	}
}

// MARK: - Nimble Matchers for `HolderDashboardViewController.Card` enum cases
// See: https://medium.com/@Tovkal/testing-enums-with-associated-values-using-nimble-839b0e53128

func beEmptyStateDescription(test: @escaping (String, String?) -> Void = { _, _  in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .emptyStateDescription with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .emptyStateDescription(message1, buttonTitle1) = actual {
			test(message1, buttonTitle1)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beEmptyStatePlaceholderImage(test: @escaping (UIImage?, String) -> Void = { _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .emptyStatePlaceholderImage with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .emptyStatePlaceholderImage(image, title1) = actual {
			test(image, title1)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beHeaderMessageCard(test: @escaping (String, String?) -> Void = { _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .headerMessage with matching value") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .headerMessage(message1, buttonTitle1) = actual {
			test(message1, buttonTitle1)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beDomesticQRCard(test: @escaping (String, String, Bool, (Date) -> [HolderDashboardViewController.ValidityText], Bool, () -> Void, ((Date) -> String?)?, HolderDashboardViewController.Card.Error?) -> Void = { _, _, _, _, _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .domesticQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   // Skip buttonEnabledEvaluator because it always comes from the `HolderDashboardViewModel.MyQRCard` itself (which means it is stubbed in the test)
		   case let .domesticQR(disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, _, expiryCountdownEvaluator, error) = actual {
			test(disclosurePolicyLabel, title, isDisabledByDisclosurePolicy, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beEuropeanUnionQRCard(test: @escaping (String, Int, (Date) -> [HolderDashboardViewController.ValidityText], Bool, () -> Void, ((Date) -> String?)?, HolderDashboardViewController.Card.Error?) -> Void = { _, _, _, _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .europeanUnionQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .europeanUnionQR(title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, _, expiryCountdownEvaluator, error) = actual {
			test(title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator, error)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beExpiredQRCard(test: @escaping (String, () -> Void) -> Void = { _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .expiredQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .expiredQR(message2, didTapClose) = actual {
			test(message2, didTapClose)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beExpiredVaccinationQRCard(test: @escaping (String, String, () -> Void, () -> Void) -> Void = { _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .expiredVaccinationQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .expiredVaccinationQR(message2, callToActionButtonText2, didTapCallToAction2, didTapClose2) = actual {
			test(message2, callToActionButtonText2, didTapCallToAction2, didTapClose2)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beOriginNotValidInThisRegionCard(test: @escaping (String, String, () -> Void) -> Void = { _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .originNotValidInThisRegion with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .originNotValidInThisRegion(message2, callToActionButtonText, didTapCallToAction) = actual {
			test(message2, callToActionButtonText, didTapCallToAction)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beConfigurationAlmostOutOfDateCard(test: @escaping (String, String, () -> Void) -> Void = { _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .configAlmostOutOfDate with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .configAlmostOutOfDate(message2, callToActionButtonText, didTapCallToAction) = actual {
			test(message2, callToActionButtonText, didTapCallToAction)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beRecommendCoronaMelderCard() -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beRecommendCoronaMelderCard with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case .recommendCoronaMelder = actual {
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beRecommendedUpdateCard(test: @escaping (String, String, () -> Void) -> Void = { _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beRecommendedUpdateCard with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .recommendedUpdate(message2, callToActionButtonText, didTapCallToAction) = actual {
			test(message2, callToActionButtonText, didTapCallToAction)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beNewValidityInfoForVaccinationAndRecoveriesCard(test: @escaping (String, String, () -> Void, () -> Void) -> Void = { _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beNewValidityInfoForVaccinationAndRecoveriesCard with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .newValidityInfoForVaccinationAndRecoveries(message2, callToActionButtonText, didTapCallToAction, didTapToClose) = actual {
			test(message2, callToActionButtonText, didTapCallToAction, didTapToClose)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beCompleteYourVaccinationAssessmentCard(test: @escaping (String, String, () -> Void) -> Void = { _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beCompleteYourVaccinationAssessmentCard with matching value") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .completeYourVaccinationAssessment(message2, callToActionButtonText, didTapCallToAction) = actual {
			test(message2, callToActionButtonText, didTapCallToAction)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beVaccinationAssessmentInvalidOutsideNLCard(test: @escaping (String, String, () -> Void) -> Void = { _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beVaccinationAssessmentInvalidOutsideNLCard with matching value") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .vaccinationAssessmentInvalidOutsideNL(message2, callToActionButtonText, didTapCallToAction) = actual {
			test(message2, callToActionButtonText, didTapCallToAction)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

func beAddCertificateCard(test: @escaping (String, () -> Void) -> Void = { _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beAddCertificateCardCard with matching value") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .addCertificate(title, didTapAdd) = actual {
			test(title, didTapAdd)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

/// title, buttonText, didTapCallToAction, didTapClose
func beDisclosurePolicyInformationCard(test: @escaping (String, String, () -> Void, () -> Void) -> Void = { _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beAddCertificateCardCard with matching value") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .disclosurePolicyInformation(title, buttonText, _, didTapCallToAction, didTapClose) = actual {
			test(title, buttonText, didTapCallToAction, didTapClose)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}
