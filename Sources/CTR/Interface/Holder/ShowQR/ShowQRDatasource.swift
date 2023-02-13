/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import UIKit
import Shared
import Persistence
import Models

protocol ShowQRDatasourceProtocol {

	var items: [ShowQRItem] { get }

	func getGreenCardForIndex(_ index: Int) -> GreenCard?
	
	func getEuCredentialAttributes(_ greenCard: GreenCard) -> EuCredentialAttributes?

	func getIndexForMostRelevantGreenCard() -> Int
	
	func getState(_ greenCard: GreenCard) -> ShowQRState
}

enum ShowQRState {
	
	case regular
	case expired
	case irrelevant
}

class ShowQRDatasource: ShowQRDatasourceProtocol {

	weak private var cryptoManager: CryptoManaging? = Current.cryptoManager

	private(set) var items = [ShowQRItem]()

	private var fullyVaccinatedGreenCards = [(greenCard: GreenCard, doseNumber: Int, totalDose: Int)]()
	private var greencardsWithDosage = [(greenCard: GreenCard, doseNumber: Int, totalDose: Int)]()

	init(greenCards: [GreenCard], disclosurePolicy: DisclosurePolicy?) {

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
			.map { ShowQRItem(greenCard: $0.greenCard, policy: disclosurePolicy) }

		self.prepareVaccinatedGreenCards()
	}

	func getGreenCardForIndex(_ index: Int) -> GreenCard? {

		guard items.count > index, index >= 0 else {
			return nil
		}

		return items[index].greenCard
	}

	private func prepareVaccinatedGreenCards() {

		let vaccinationGreenCardsWithAttributes: [(greenCard: GreenCard, attributes: EuCredentialAttributes)] = items
		// only international
			.filter { $0.greenCard.getType() == GreenCardType.eu }
		// only with attributes
			.compactMap { cardsWithSortedOrigin in
				if let credentialData = cardsWithSortedOrigin.greenCard.getLatestInternationalCredential()?.data,
				   let euCredentialAttributes = self.cryptoManager?.readEuCredentials(credentialData) {

					return (cardsWithSortedOrigin.greenCard, attributes: euCredentialAttributes)
				}
				return nil
			}
		// only with vaccinations
			.filter { $0.attributes.digitalCovidCertificate.vaccinations?.first != nil }

		// Map with dosage
		greencardsWithDosage = vaccinationGreenCardsWithAttributes
			.compactMap {
				if let euVaccination = $0.attributes.digitalCovidCertificate.vaccinations?.first,
				   let doseNumber = euVaccination.doseNumber,
				   let totalDose = euVaccination.totalDose {

					return ($0.greenCard, doseNumber: doseNumber, totalDose: totalDose)
				}
				return nil
			}

		// Get the ones that are fully vaccinated
		fullyVaccinatedGreenCards = greencardsWithDosage.filter { $0.doseNumber == $0.totalDose }.sorted { lhs, rhs in lhs.totalDose > rhs.totalDose }
	}

	private func isDosenumberSmallerThanTotalDose(_ greenCard: GreenCard) -> Bool {

		guard self.items.count > 1,
			  greenCard.getType() == GreenCardType.eu,
			let highestFullyVaccinatedGreenCard = fullyVaccinatedGreenCards.first,
			let euCredentialAttributes = getEuCredentialAttributes(greenCard),
			let euVaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first,
			let doseNumber = euVaccination.doseNumber,
			let totalDose = euVaccination.totalDose,
			totalDose != doseNumber else {
			// Total Dose equals doseNumber
			return false
		}
		
		logVerbose("We are \(doseNumber) / \(totalDose) : \(highestFullyVaccinatedGreenCard.totalDose)")
		return doseNumber < highestFullyVaccinatedGreenCard.totalDose
	}
	
	private func isCredentialExpired(_ greenCard: GreenCard) -> Bool {
		
		guard greenCard.getType() == GreenCardType.eu,
			  let euCredentialAttributes = getEuCredentialAttributes(greenCard) else {
			// No attributes
			return false
		}
		logVerbose("expirationTime: \(Date(timeIntervalSince1970: euCredentialAttributes.expirationTime))")
		return Date(timeIntervalSince1970: euCredentialAttributes.expirationTime) < Current.now()
	}
	
	func getEuCredentialAttributes(_ greenCard: GreenCard) -> EuCredentialAttributes? {
		
		guard greenCard.getType() == GreenCardType.eu else { return nil }
		
		if let credentialData = greenCard.getLatestInternationalCredential()?.data,
		   let euCredentialAttributes = cryptoManager?.readEuCredentials(credentialData) {
			return euCredentialAttributes
		}
		return nil
	}
	
	func getIndexForMostRelevantGreenCard() -> Int {
		
		// Sort by doseNumber, totalDose
		let sorted = greencardsWithDosage.sorted { lhs, rhs in
			if lhs.doseNumber == rhs.doseNumber {
				return lhs.totalDose > rhs.totalDose
			}
			return lhs.doseNumber > rhs.doseNumber
		}
		
		// Rule 1: return the card with the highest doseNumber
		if let card = sorted.first,
		   let index = items.firstIndex(where: { $0.greenCard == card.greenCard }) {
			logVerbose("getIndexForMostRelevantGreenCard -> \(index)")
			return index
		}
		return 0
	}
	
	func getState(_ greenCard: GreenCard) -> ShowQRState {
		
		if isDosenumberSmallerThanTotalDose(greenCard) {
			return .irrelevant
		} else if isCredentialExpired(greenCard) {
			return .expired
		}
		return .regular
	}
}
