/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
@testable import CTR
import Nimble

class HolderDashboardDatasourceTests: XCTestCase {

	/// Subject under test
	var sut: HolderDashboardQRCardDatasource!

	var cryptoManagerSpy: CryptoManagerSpy!
	var dataStoreManager: DataStoreManager!
	var walletManagingSpy: WalletManagerSpy!

	override func setUp() {
		super.setUp()

		cryptoManagerSpy = CryptoManagerSpy()
		dataStoreManager = DataStoreManager(.inMemory)
		walletManagingSpy = WalletManagerSpy()

		Services.use(cryptoManagerSpy)
		Services.use(walletManagingSpy)
	}

	func test_settingDidUpdateCallbackTriggersReloadWithCallback() {
		// Arrange
		sut = HolderDashboardQRCardDatasource(now: { now })

		// Act
		var wasUpdated: Bool = false
		sut.didUpdate = { qrCards, expiredQRs in
			wasUpdated = true
		}

		// Assert
		expect(wasUpdated) == true
	}

	func test_fetching_removes_expired_greencards() {
		// Arrange
		_ = GreenCard.sampleDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: dataStoreManager)
		self.walletManagingSpy.stubbedRemoveExpiredGreenCardsResult = [
			(greencardType: "domestic", originType: "vaccination")
		]

		sut = HolderDashboardQRCardDatasource(now: { now })

		// Act
		var cards = [HolderDashboardViewModel.QRCard]()
		var expiredQRs = [HolderDashboardQRCardDatasource.ExpiredQR]()
		sut.didUpdate = {
			cards = $0
			expiredQRs = $1
		}

		// Assert
		expect(self.walletManagingSpy.invokedRemoveExpiredGreenCards) == true
		expect(expiredQRs.count) == 1
		expect(expiredQRs.first?.type) == .vaccination
		expect(cards.count) == 0
	}

	func test_fetching_fetchesExpiringDomesticGreencard() {
		// Arrange
		let greencard = GreenCard.sampleDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		walletManagingSpy.stubbedListGreenCardsResult = [greencard]

		// Act
		sut = HolderDashboardQRCardDatasource(now: { now })

		var cards = [HolderDashboardViewModel.QRCard]()
		var expiredQRs = [HolderDashboardQRCardDatasource.ExpiredQR]()
		sut.didUpdate = {
			cards = $0
			expiredQRs = $1
		}

		// Assert
		expect(expiredQRs).to(beEmpty())

		guard let qrcard = cards.first, case .netherlands = qrcard.region, let firstGreencard = qrcard.greencards.first
		else { fail(); return }

		expect(firstGreencard.id) == greencard.objectID

		expect(firstGreencard.origins.count) == 1
		expect(firstGreencard.origins.first!.eventDate) == now.addingTimeInterval(8 * days * ago)
		expect(firstGreencard.origins.first!.expirationTime) == now.addingTimeInterval(30 * days * fromNow)
		expect(firstGreencard.origins.first!.customSortIndex) == 0
		expect(firstGreencard.origins.first!.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(firstGreencard.origins.first!.isCurrentlyValid(now: now)) == true
		expect(firstGreencard.origins.first!.isNotYetExpired(now: now)) == true
		expect(qrcard.shouldShowErrorBeneathCard) == false
		expect(qrcard.evaluateEnabledState(now)) == true
	}

	func test_fetching_expiredWithMoreToFetchDomesticGreencard() {
		// Arrange
		let greencard = GreenCard.sampleDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: dataStoreManager)
		walletManagingSpy.stubbedListGreenCardsResult = [greencard]

		// Act
		sut = HolderDashboardQRCardDatasource(now: { now })

		var cards = [HolderDashboardViewModel.QRCard]()
		var expiredQRs = [HolderDashboardQRCardDatasource.ExpiredQR]()
		sut.didUpdate = {
			cards = $0
			expiredQRs = $1
		}

		// Assert
		expect(expiredQRs).to(beEmpty())

		guard let qrcard = cards.first, case .netherlands = qrcard.region, let firstGreencard = qrcard.greencards.first
		else { fail(); return }

		expect(firstGreencard.id) == greencard.objectID

		expect(firstGreencard.origins.count) == 1
		expect(firstGreencard.origins.first!.eventDate) == now.addingTimeInterval(8 * days * ago)
		expect(firstGreencard.origins.first!.expirationTime) == now.addingTimeInterval(30 * days * fromNow)
		expect(firstGreencard.origins.first!.customSortIndex) == 0
		expect(firstGreencard.origins.first!.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(firstGreencard.origins.first!.isCurrentlyValid(now: now)) == true
		expect(firstGreencard.origins.first!.isNotYetExpired(now: now)) == true
		expect(qrcard.shouldShowErrorBeneathCard) == true
		expect(qrcard.evaluateEnabledState(now)) == false
	}

	func test_fetching_domestic_cards_are_grouped() {
		// Arrange
		let greencard = GreenCard.sampleDomesticCredentialsVaccinationExpiringIn10DaysWithMoreToFetchWithValidTest(dataStoreManager: dataStoreManager)
		walletManagingSpy.stubbedListGreenCardsResult = [greencard]

		// Act
		sut = HolderDashboardQRCardDatasource(now: { now })

		var cards = [HolderDashboardViewModel.QRCard]()
		var expiredQRs = [HolderDashboardQRCardDatasource.ExpiredQR]()
		sut.didUpdate = {
			cards = $0
			expiredQRs = $1
		}

		// Assert
		expect(expiredQRs).to(beEmpty())
		expect(cards.count) == 1 // two origins, but grouped in one card.

		guard let qrcard = cards.first, case .netherlands = qrcard.region, let firstGreencard = qrcard.greencards.first
		else { fail(); return }

		expect(firstGreencard.id) == greencard.objectID

		expect(firstGreencard.origins.count) == 2

		let vaccinationOrigin = firstGreencard.origins.first(where: { $0.type == .vaccination })
		let testOrigin = firstGreencard.origins.first(where: { $0.type == .test })

		expect(vaccinationOrigin?.eventDate) == now.addingTimeInterval(8 * days * ago)
		expect(vaccinationOrigin?.expirationTime) == now.addingTimeInterval(40 * days * fromNow)
		expect(vaccinationOrigin?.customSortIndex) == 0
		expect(vaccinationOrigin?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(vaccinationOrigin?.isCurrentlyValid(now: now)) == true
		expect(vaccinationOrigin?.isNotYetExpired(now: now)) == true

		expect(testOrigin?.eventDate) == now.addingTimeInterval(4 * hours * ago)
		expect(testOrigin?.expirationTime) == now.addingTimeInterval(20 * hours * fromNow)
		expect(testOrigin?.customSortIndex) == 2
		expect(testOrigin?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(testOrigin?.isCurrentlyValid(now: now)) == true
		expect(testOrigin?.isNotYetExpired(now: now)) == true

		expect(qrcard.shouldShowErrorBeneathCard) == false
		expect(qrcard.evaluateEnabledState(now)) == true
	}

	func test_fetching_international_cards_are_not_grouped() {
		// Arrange
		let greencards = GreenCard.sampleInternationalCredentialsVaccinationExpiringIn10DaysWithMoreToFetchWithValidTest(dataStoreManager: dataStoreManager)
		walletManagingSpy.stubbedListGreenCardsResult = greencards

		// Act
		sut = HolderDashboardQRCardDatasource(now: { now })

		var cards = [HolderDashboardViewModel.QRCard]()
		var expiredQRs = [HolderDashboardQRCardDatasource.ExpiredQR]()
		sut.didUpdate = {
			cards = $0
			expiredQRs = $1
		}

		// Assert
		expect(expiredQRs).to(beEmpty())
		expect(cards.count) == 2 // two origins, but grouped in one card.

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
		expect(secondGreencard.origins.first?.customSortIndex) == 2
		expect(secondGreencard.origins.first?.expiryIsBeyondThreeYearsFromNow(now: now)) == false
		expect(secondGreencard.origins.first?.isCurrentlyValid(now: now)) == true
		expect(secondGreencard.origins.first?.isNotYetExpired(now: now)) == true
		expect(secondQRCard.shouldShowErrorBeneathCard) == false
		expect(secondQRCard.evaluateEnabledState(now)) == true
	}
}
