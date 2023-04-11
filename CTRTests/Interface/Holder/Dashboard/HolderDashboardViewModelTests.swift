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
import Shared
@testable import Models
@testable import Managers

class HolderDashboardViewModelTests: XCTestCase {

	/// Subject under test
	var sut: HolderDashboardViewModel!
	var configSpy: ConfigurationGeneralSpy!
	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	var qrCardDatasourceSpy: HolderDashboardDatasourceSpy!
	var blockedEventsSpy: HolderDashboardRemovedEventsDatasourceSpy!
	var mismatchedIdentityEventsSpy: HolderDashboardRemovedEventsDatasourceSpy!
	var strippenRefresherSpy: DashboardStrippenRefresherSpy!
	var sampleGreencardObjectID: NSManagedObjectID!
	var configurationNotificationManagerSpy: ConfigurationNotificationManagerSpy!
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
		blockedEventsSpy = HolderDashboardRemovedEventsDatasourceSpy()
		mismatchedIdentityEventsSpy = HolderDashboardRemovedEventsDatasourceSpy()
		strippenRefresherSpy = DashboardStrippenRefresherSpy()
		configurationNotificationManagerSpy = ConfigurationNotificationManagerSpy()
		configurationNotificationManagerSpy.stubbedAlmostOutOfDateObservatory = Observatory.create().0
		sampleGreencardObjectID = NSManagedObjectID()
	}

	func vendSut(appVersion: String = "1.0.0") -> HolderDashboardViewModel {

		environmentSpies.featureFlagManagerSpy.stubbedAreZeroDisclosurePoliciesEnabledResult = true
		return HolderDashboardViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			qrcardDatasource: qrCardDatasourceSpy,
			blockedEventsDatasource: blockedEventsSpy,
			mismatchedIdentityDatasource: mismatchedIdentityEventsSpy,
			strippenRefresher: strippenRefresherSpy,
			configurationNotificationManager: configurationNotificationManagerSpy,
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
