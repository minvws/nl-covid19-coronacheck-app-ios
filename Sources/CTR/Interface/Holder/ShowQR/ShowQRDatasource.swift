/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import UIKit

protocol ShowQRDatasourceProtocol {

	var items: [ShowQRItem] { get }

	init(greenCards: [GreenCard], internationalQRRelevancyDays: TimeInterval)

	func getGreenCardForIndex(_ index: Int) -> GreenCard?

	func shouldGreenCardBeHidden(_ greenCard: GreenCard) -> Bool

	func getIndexForMostRelevantGreenCard() -> Int
}

class ShowQRDatasource: ShowQRDatasourceProtocol, Logging {

	weak private var cryptoManager: CryptoManaging? = Current.cryptoManager

	private let internationalQRRelevancyDays: TimeInterval

	private(set) var items = [ShowQRItem]()

	private var fullyVaccinatedGreenCards = [(greenCard: GreenCard, doseNumber: Int, totalDose: Int)]()

	required init(greenCards: [GreenCard], internationalQRRelevancyDays: TimeInterval) {

		self.internationalQRRelevancyDays = internationalQRRelevancyDays

		self.items = greenCards
			.compactMap { greenCard in
				// map on greenCard, sorted origins.
				greenCard.castOrigins().map { (greenCard: greenCard, origins: $0.sorted { lhsOrigin, rhsOrigin in
					// Sort the origins ascending
					lhsOrigin.eventDate ?? .distantFuture < rhsOrigin.eventDate ?? .distantFuture
				}) }
			}
			.sorted { lhs, rhs in
				// Sort the greenCards ascending (on the first origin)
				if let lhsEventDate = lhs.origins.first?.eventDate, let rhsEventDate = rhs.origins.first?.eventDate {
					return lhsEventDate < rhsEventDate
				}
				return false
			}
			.map { ShowQRItem(greenCard: $0.greenCard) }

		self.fullyVaccinatedGreenCards = findFullyVaccinatedGreenCards()
	}

	func getGreenCardForIndex(_ index: Int) -> GreenCard? {

		guard items.count > index, index >= 0 else {
			return nil
		}

		return items[index].greenCard
	}

	private func findFullyVaccinatedGreenCards() -> [(greenCard: GreenCard, doseNumber: Int, totalDose: Int)] {

		let vaccinationGreenCardsWithAttributes: [(greenCard: GreenCard, attributes: EuCredentialAttributes)] = items
		// only international
			.filter { $0.greenCard.type == GreenCardType.eu.rawValue }
		// only with attributes
			.compactMap { cardsWithSortedOrigin in
				if let credential = cardsWithSortedOrigin.greenCard.getActiveCredential(),
				   let data = credential.data,
				   let euCredentialAttributes = self.cryptoManager?.readEuCredentials(data) {

					return (cardsWithSortedOrigin.greenCard, attributes: euCredentialAttributes)
				}
				return nil
			}
		// only with vaccinations
			.filter { $0.attributes.digitalCovidCertificate.vaccinations?.first != nil }

		// Map with dosage and date information
		let greencardsWithDateAndDosage: [(greenCard: GreenCard, date: Date, doseNumber: Int, totalDose: Int)] = vaccinationGreenCardsWithAttributes
			.compactMap {
				if let euVaccination = $0.attributes.digitalCovidCertificate.vaccinations?.first,
				   let eventDate = Formatter.getDateFrom(dateString8601: euVaccination.dateOfVaccination),
				   let doseNumber = euVaccination.doseNumber,
				   let totalDose = euVaccination.totalDose {

					return ($0.greenCard, date: eventDate, doseNumber: doseNumber, totalDose: totalDose)
				}
				return nil
			}

		// Get the ones that are fully vaccinated
		let fullyVaccinated = greencardsWithDateAndDosage.filter { $0.doseNumber == $0.totalDose }.sorted { lhs, rhs in lhs.totalDose > rhs.totalDose }

		// Filter older than 28 days
		let fullyVaccinatedOldEnough = fullyVaccinated.filter {
			return $0.date < Date().addingTimeInterval(internationalQRRelevancyDays * 24 * 60 * 60 * -1)
		}

		return fullyVaccinatedOldEnough.map {
			// Loose the date, no longer needed.
			($0.greenCard, $0.doseNumber, $0.totalDose)
		}
	}

	func shouldGreenCardBeHidden(_ greenCard: GreenCard) -> Bool {

		guard self.items.count > 1,
			greenCard.type == GreenCardType.eu.rawValue,
			let highestFullyVaccinatedGreenCard = fullyVaccinatedGreenCards.first,
			let credential = greenCard.getActiveCredential(),
			let data = credential.data,
			let euCredentialAttributes = self.cryptoManager?.readEuCredentials(data),
			let euVaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first,
			let doseNumber = euVaccination.doseNumber,
			let totalDose = euVaccination.totalDose,
			totalDose != doseNumber else {
			return false
		}

		logVerbose("We are \(doseNumber) / \(totalDose) : \(highestFullyVaccinatedGreenCard.totalDose)")
		return doseNumber < highestFullyVaccinatedGreenCard.totalDose
	}

	func getIndexForMostRelevantGreenCard() -> Int {

//		// Rule 1: If available, return 2/2 (older than internationalQRRelevancyDays days)
//		for card in fullyVaccinatedGreenCards where card.totalDose == 2 {
//			if let index = items.firstIndex(where: { $0.greenCard == card.greenCard }) {
//				return index
//			}
//		}

		// Rule 2: return highest fully vaccinated card (older than internationalQRRelevancyDays days)
		if let card = fullyVaccinatedGreenCards.first {
			if let index = items.firstIndex(where: { $0.greenCard == card.greenCard }) {
				return index
			}
		}

		// Rule 3: return the last one
		return items.count - 1
	}
}
