/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
@testable import CTR
import Nimble
import TestingShared
import Persistence
@testable import Managers

class HolderDashboardDatasourceTests: XCTestCase {
	
	/// Subject under test
	var sut: HolderDashboardQRCardDatasource!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
	}
	
	func test_settingDidUpdateCallbackTriggersReloadWithCallback() {
		// Arrange
		sut = HolderDashboardQRCardDatasource()
		
		// Act
		var wasUpdated: Bool = false
		sut.didUpdate = { qrCards, expiredQRs in
			wasUpdated = true
		}
		
		// Assert
		expect(wasUpdated) == true
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExpiredGreenCards) == true
	}
	
	func test_fetching_removes_expired_greencards() {
		// Arrange
		_ = GreenCard.sampleInternationalCredentialsExpiredWithMoreToFetch(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.walletManagerSpy.stubbedRemoveExpiredGreenCardsResult = [
			(greencardType: "eu", originType: "vaccination")
		]
		
		sut = HolderDashboardQRCardDatasource()
		
		// Act
		var cards = [HolderDashboardViewModel.QRCard]()
		var expiredQRs = [HolderDashboardQRCardDatasource.ExpiredQR]()
		sut.didUpdate = {
			cards = $0
			expiredQRs = $1
		}
		
		// Assert
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExpiredGreenCards) == true
		expect(expiredQRs.count) == 1
		expect(expiredQRs.first?.type) == .vaccination
		expect(cards.count) == 0
	}
	
	func test_fetching_removes_expired_multiple_greencards() {
		
		// Arrange
		_ = GreenCard.sampleInternationalMultipleExpiredDCC(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.walletManagerSpy.stubbedRemoveExpiredGreenCardsResult = [
			(greencardType: "eu", originType: "vaccination"),
			(greencardType: "eu", originType: "vaccination")
		]
		
		sut = HolderDashboardQRCardDatasource()
		
		// Act
		var cards = [HolderDashboardViewModel.QRCard]()
		var expiredQRs = [HolderDashboardQRCardDatasource.ExpiredQR]()
		sut.didUpdate = {
			cards = $0
			expiredQRs = $1
		}
		
		// Assert
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExpiredGreenCards) == true
		expect(expiredQRs.count) == 2
		expect(expiredQRs.first?.type) == .vaccination
		expect(expiredQRs.first?.region) == .europeanUnion
		expect(expiredQRs.last?.type) == .vaccination
		expect(expiredQRs.last?.region) == .europeanUnion
		expect(cards.count) == 0
	}
}

// MARK: Grouping

extension HolderDashboardDatasourceTests {

	func test_fetching_international_greencards_with_different_origins_are_not_grouped() {
		// Arrange
		let greencards = GreenCard.sampleInternationalCredentialsVaccinationExpiringIn10DaysWithMoreToFetchWithValidTest(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.walletManagerSpy.stubbedListGreenCardsResult = greencards

		// Act
		sut = HolderDashboardQRCardDatasource()

		var cards = [HolderDashboardViewModel.QRCard]()
		var expiredQRs = [HolderDashboardQRCardDatasource.ExpiredQR]()
		sut.didUpdate = {
			cards = $0
			expiredQRs = $1
		}

		// Assert
		expect(expiredQRs).to(beEmpty())
		expect(cards.count) == 2

		let firstQRCard = cards[0]
		guard case .europeanUnion = firstQRCard.region else { fail(); return }

		let firstGreencard = firstQRCard.greencards[0]
		expect(firstGreencard.id) == greencards[1].objectID

		expect(firstGreencard.origins.count) == 1
		expect(firstGreencard.origins.first?.eventDate) == now.addingTimeInterval(8 * days * ago)
		expect(firstGreencard.origins.first?.expirationTime) == now.addingTimeInterval(40 * days * fromNow)
		expect(firstGreencard.origins.first?.customSortIndex) == 0
		expect(firstGreencard.origins.first?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(firstGreencard.origins.first?.isCurrentlyValid(now: now)) == true
		expect(firstGreencard.origins.first?.isNotYetExpired(now: now)) == true
		expect(firstQRCard.shouldShowErrorBeneathCard) == false
		expect(firstQRCard.evaluateEnabledState(now)) == true

		// unwrap next index to same variables
		let secondQRCard = cards[1]
		guard case .europeanUnion = secondQRCard.region else { fail(); return }

		let secondGreencard = secondQRCard.greencards[0]
		expect(secondGreencard.id) == greencards[0].objectID

		expect(secondGreencard.origins.count) == 1
		expect(secondGreencard.origins.first?.eventDate) == now.addingTimeInterval(4 * hours * ago)
		expect(secondGreencard.origins.first?.expirationTime) == now.addingTimeInterval(20 * hours * fromNow)
		expect(secondGreencard.origins.first?.customSortIndex) ≈ (3.8, 0.2)
		expect(secondGreencard.origins.first?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(secondGreencard.origins.first?.isCurrentlyValid(now: now)) == true
		expect(secondGreencard.origins.first?.isNotYetExpired(now: now)) == true
		expect(secondQRCard.shouldShowErrorBeneathCard) == false
		expect(secondQRCard.evaluateEnabledState(now)) == true
	}

	func test_fetching_international_single_greencard_with_different_origins_are_not_grouped() {
		// Arrange
		let greencards = GreenCard.sampleInternationalCredentialsVaccinationExpiringIn10DaysWithMoreToFetchWithValidTest(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.walletManagerSpy.stubbedListGreenCardsResult = greencards

		// Act
		sut = HolderDashboardQRCardDatasource()

		var cards = [HolderDashboardViewModel.QRCard]()
		var expiredQRs = [HolderDashboardQRCardDatasource.ExpiredQR]()
		sut.didUpdate = {
			cards = $0
			expiredQRs = $1
		}

		// Assert
		expect(expiredQRs).to(beEmpty())
		expect(cards.count) == 2

		let firstQRCard = cards[0]
		guard case .europeanUnion = firstQRCard.region else { fail(); return }

		let firstGreencard = firstQRCard.greencards[0]
		expect(firstGreencard.id) == greencards[1].objectID

		expect(firstGreencard.origins.count) == 1
		expect(firstGreencard.origins.first?.eventDate) == now.addingTimeInterval(8 * days * ago)
		expect(firstGreencard.origins.first?.expirationTime) == now.addingTimeInterval(40 * days * fromNow)
		expect(firstGreencard.origins.first?.customSortIndex) == 0
		expect(firstGreencard.origins.first?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(firstGreencard.origins.first?.isCurrentlyValid(now: now)) == true
		expect(firstGreencard.origins.first?.isNotYetExpired(now: now)) == true
		expect(firstQRCard.shouldShowErrorBeneathCard) == false
		expect(firstQRCard.evaluateEnabledState(now)) == true

		// unwrap next index to same variables
		let secondQRCard = cards[1]
		guard case .europeanUnion = secondQRCard.region else { fail(); return }

		let secondGreencard = secondQRCard.greencards[0]
		expect(secondGreencard.id) == greencards[0].objectID

		expect(secondGreencard.origins.count) == 1
		expect(secondGreencard.origins.first?.eventDate) == now.addingTimeInterval(4 * hours * ago)
		expect(secondGreencard.origins.first?.expirationTime) == now.addingTimeInterval(20 * hours * fromNow)
		expect(secondGreencard.origins.first?.customSortIndex) ≈ (3.8, 0.2)
		expect(secondGreencard.origins.first?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(secondGreencard.origins.first?.isCurrentlyValid(now: now)) == true
		expect(secondGreencard.origins.first?.isNotYetExpired(now: now)) == true
		expect(secondQRCard.shouldShowErrorBeneathCard) == false
		expect(secondQRCard.evaluateEnabledState(now)) == true
	}

	func test_fetching_international_multiple_vaccination_greencards_with_same_origins_are_grouped() {
		// Arrange
		let greencards = GreenCard.sampleInternationalMultipleVaccineDCC(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.walletManagerSpy.stubbedListGreenCardsResult = greencards

		// Act
		sut = HolderDashboardQRCardDatasource()

		var cards = [HolderDashboardViewModel.QRCard]()
		var expiredQRs = [HolderDashboardQRCardDatasource.ExpiredQR]()
		sut.didUpdate = {
			cards = $0
			expiredQRs = $1
		}

		// Assert
		expect(expiredQRs).to(beEmpty())
		expect(cards.count) == 1 // only one card for two greencards.

		let qrCard = cards[0]
		guard case .europeanUnion = qrCard.region else { fail(); return }

		expect(qrCard.shouldShowErrorBeneathCard) == false
		expect(qrCard.evaluateEnabledState(now)) == true

		let firstGreencard = qrCard.greencards[0]
		expect(firstGreencard.id) == greencards[0].objectID
		expect(firstGreencard.origins.count) == 1
		expect(firstGreencard.origins.first?.eventDate) == now.addingTimeInterval(40 * days * ago)
		expect(firstGreencard.origins.first?.expirationTime) == now.addingTimeInterval(10 * days * fromNow)
		expect(firstGreencard.origins.first?.customSortIndex) == 0
		expect(firstGreencard.origins.first?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(firstGreencard.origins.first?.isCurrentlyValid(now: now)) == true
		expect(firstGreencard.origins.first?.isNotYetExpired(now: now)) == true

		let secondGreencard = qrCard.greencards[1]
		expect(secondGreencard.id) == greencards[1].objectID
		expect(secondGreencard.origins.count) == 1
		expect(secondGreencard.origins.first?.eventDate) == now.addingTimeInterval(20 * days * ago)
		expect(secondGreencard.origins.first?.expirationTime) == now.addingTimeInterval(30 * days * fromNow)
		expect(secondGreencard.origins.first?.customSortIndex) == 0
		expect(secondGreencard.origins.first?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(secondGreencard.origins.first?.isCurrentlyValid(now: now)) == true
		expect(secondGreencard.origins.first?.isNotYetExpired(now: now)) == true//
	}
	
	func test_fetching_international_multiple_recoveries_greencards_are_not_grouped() {
		// Arrange
		let greencards = GreenCard.sampleInternationalMultiplRecoveryDCC(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.walletManagerSpy.stubbedListGreenCardsResult = greencards

		// Act
		sut = HolderDashboardQRCardDatasource()

		var cards = [HolderDashboardViewModel.QRCard]()
		var expiredQRs = [HolderDashboardQRCardDatasource.ExpiredQR]()
		sut.didUpdate = {
			cards = $0
			expiredQRs = $1
		}

		// Assert
		expect(expiredQRs).to(beEmpty())
		expect(cards.count) == 2

		let firstQRCard = cards[0]
		guard case .europeanUnion = firstQRCard.region else { fail(); return }

		let firstGreencard = firstQRCard.greencards[0]
		expect(firstGreencard.id) == greencards[1].objectID

		expect(firstGreencard.origins.count) == 1
		expect(firstGreencard.origins.first?.eventDate) == now.addingTimeInterval(20 * days * ago)
		expect(firstGreencard.origins.first?.expirationTime) == now.addingTimeInterval(30 * days * fromNow)
		expect(firstGreencard.origins.first?.customSortIndex) ≈ (1.8, 0.2)
		expect(firstGreencard.origins.first?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(firstGreencard.origins.first?.isCurrentlyValid(now: now)) == true
		expect(firstGreencard.origins.first?.isNotYetExpired(now: now)) == true
		expect(firstQRCard.shouldShowErrorBeneathCard) == false
		expect(firstQRCard.evaluateEnabledState(now)) == true

		let secondQRCard = cards[1]
		guard case .europeanUnion = secondQRCard.region else { fail(); return }

		let secondGreencard = secondQRCard.greencards[0]
		expect(secondGreencard.id) == greencards[0].objectID

		expect(secondGreencard.origins.count) == 1
		expect(secondGreencard.origins.first?.eventDate) == now.addingTimeInterval(40 * days * ago)
		expect(secondGreencard.origins.first?.expirationTime) == now.addingTimeInterval(10 * days * fromNow)
		expect(secondGreencard.origins.first?.customSortIndex) ≈ (1.8, 0.2)
		expect(secondGreencard.origins.first?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(secondGreencard.origins.first?.isCurrentlyValid(now: now)) == true
		expect(secondGreencard.origins.first?.isNotYetExpired(now: now)) == true
		expect(secondQRCard.shouldShowErrorBeneathCard) == false
		expect(secondQRCard.evaluateEnabledState(now)) == true
	}
	
	func test_fetching_international_multiple_recoveries_greencards_are_not_grouped_one_future_valid() {
		// Arrange
		let greencards = GreenCard.sampleInternationalMultiplRecoveryDCCOneFutureValid(dataStoreManager: environmentSpies.dataStoreManager)
		environmentSpies.walletManagerSpy.stubbedListGreenCardsResult = greencards

		// Act
		sut = HolderDashboardQRCardDatasource()

		var cards = [HolderDashboardViewModel.QRCard]()
		var expiredQRs = [HolderDashboardQRCardDatasource.ExpiredQR]()
		sut.didUpdate = {
			cards = $0
			expiredQRs = $1
		}

		// Assert
		expect(expiredQRs).to(beEmpty())
		expect(cards.count) == 2

		let firstQRCard = cards[0]
		guard case .europeanUnion = firstQRCard.region else { fail(); return }

		let firstGreencard = firstQRCard.greencards[0]
		expect(firstGreencard.id) == greencards[0].objectID

		expect(firstGreencard.origins.count) == 1
		expect(firstGreencard.origins.first?.eventDate) == now.addingTimeInterval(40 * days * ago)
		expect(firstGreencard.origins.first?.expirationTime) == now.addingTimeInterval(10 * days * fromNow)
		expect(firstGreencard.origins.first?.customSortIndex) ≈ (1.8, 0.2)
		expect(firstGreencard.origins.first?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(firstGreencard.origins.first?.isCurrentlyValid(now: now)) == true
		expect(firstGreencard.origins.first?.isNotYetExpired(now: now)) == true
		expect(firstQRCard.shouldShowErrorBeneathCard) == false
		expect(firstQRCard.evaluateEnabledState(now)) == true

		let secondQRCard = cards[1]
		guard case .europeanUnion = secondQRCard.region else { fail(); return }

		let secondGreencard = secondQRCard.greencards[0]
		expect(secondGreencard.id) == greencards[1].objectID

		expect(secondGreencard.origins.count) == 1
		expect(secondGreencard.origins.first?.eventDate) == now.addingTimeInterval(20 * days * fromNow)
		expect(secondGreencard.origins.first?.expirationTime) == now.addingTimeInterval(30 * days * fromNow)
		expect(secondGreencard.origins.first?.customSortIndex) == 1.99
		expect(secondGreencard.origins.first?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(secondGreencard.origins.first?.isCurrentlyValid(now: now)) == false
		expect(secondGreencard.origins.first?.isNotYetExpired(now: now)) == true
		expect(secondQRCard.shouldShowErrorBeneathCard) == false
		expect(secondQRCard.evaluateEnabledState(now)) == false
	}
}
