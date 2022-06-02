/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol HolderDashboardQRCardDatasourceProtocol: AnyObject {
	typealias QRCard = HolderDashboardViewModel.QRCard
	typealias ExpiredQR = HolderDashboardViewModel.ExpiredQR

	var didUpdate: (([HolderDashboardViewModel.QRCard], [ExpiredQR]) -> Void)? { get set }

	func reload()
}

// Needed for referring to the CoreData Origin from within QRCard (which has it's own Origin type)
private typealias DBOrigin = Origin
// Needed for referring to the CoreData GreenCard from within QRCard (which has it's own GreenCard type)
private typealias DBGreenCard = GreenCard

class HolderDashboardQRCardDatasource: HolderDashboardQRCardDatasourceProtocol {

	var didUpdate: (([HolderDashboardViewModel.QRCard], [ExpiredQR]) -> Void)? {
		didSet {
			guard didUpdate != nil else { return }
			reload()
		}
	}

	private var reloadTimer: Timer?
	private let now: () -> Date = Current.now

	// Calls fetch, then updates subscribers.

	func reload() {
		guard let didUpdate = didUpdate else { return }

		// Clear existing timer:
		reloadTimer?.invalidate()
		reloadTimer = nil

		removeExpiredEvents() // Vaccineassessment expiration can leave some events lingering - when reloading, make sure they are cleaned up also.
		
		let expiredGreenCards: [ExpiredQR] = removeExpiredGreenCards()
		let cards: [HolderDashboardViewModel.QRCard] = fetchMyQRCards()

		// Callback
		didUpdate(cards, expiredGreenCards)

		// Schedule a Timer to reload the next time an origin will expire:
		reloadTimer = calculateNextReload(cards: cards).map { (nextFetchInterval: TimeInterval) in
			Timer.scheduledTimer(withTimeInterval: nextFetchInterval, repeats: false, block: { [weak self] _ in
				self?.reload()
			})
		}
	}

	private func calculateNextReload(cards: [HolderDashboardViewModel.QRCard]) -> TimeInterval? {
		// Calculate when the next reload is needed:
		let nextFetchInterval: TimeInterval = cards
			.flatMap { $0.greencards }
			.flatMap { $0.origins }
			.reduce(Date.distantFuture) { (result: Date, origin: HolderDashboardViewModel.QRCard.GreenCard.Origin) -> Date in
				origin.expirationTime < result ? origin.expirationTime : result
			}.timeIntervalSinceNow

		guard nextFetchInterval > 0 else { return nil }
		return nextFetchInterval
	}

	private func removeExpiredGreenCards() -> [ExpiredQR] {
		return Current.walletManager.removeExpiredGreenCards().compactMap { (greencardType: String, originType: String) -> ExpiredQR? in
			guard let region = QRCodeValidityRegion(rawValue: greencardType) else { return nil }
			guard let originType = QRCodeOriginType(rawValue: originType) else { return nil }
			return ExpiredQR(region: region, type: originType)
		}
	}
	
	private func removeExpiredEvents() {

		let configuration = Current.remoteConfigManager.storedConfiguration
		Current.walletManager.expireEventGroups(configuration: configuration)
	}

	/// Fetch the Greencards+Origins from Database
	/// and convert to UI-appropriate model types.
	private func fetchMyQRCards() -> [HolderDashboardViewModel.QRCard] {
		let dbGreencards = Current.walletManager.listGreenCards()

		let dbGreencardsWithDBOrigins = dbGreencards
			.compactMap { (greencard: DBGreenCard) -> (DBGreenCard, [DBOrigin])? in
				// Get all origins
				guard let untypedOrigins = greencard.origins else { return nil }
				let origins = untypedOrigins.compactMap({ $0 as? Origin })
				return (greencard, origins)
			}

		let groupedGreenCards = HolderDashboardQRCardDatasource.groupDBGreenCards(dbGreencards: dbGreencardsWithDBOrigins)

		// map DB types to local types to have more control over optionality & avoid worrying about threading
		let qrCards = groupedGreenCards
			.flatMap { (greencardsGroup: [(DBGreenCard, [DBOrigin])]) -> [QRCard] in

				// If this iteration has a `.domestic`, then it goes to its own QRCard function:
				if let firstPair = greencardsGroup.first,
				   let firstType = firstPair.0.getType(),
				   firstType == GreenCardType.domestic {

					// For each domestic greencard (Note: there should only be one), convert it to a domestic QRCard:
					return greencardsGroup.flatMap { greencard, origins in
						QRCard.domesticQRCards(forGreencard: greencard, withOrigins: origins, now: now)
					}

				// Otherwise, (for international greencards) the group gets wrangled into a set of europeanUnion QR Cards:
				} else {
					var cards = [QRCard]()
					greencardsGroup.forEach { greenCard, origins in
						if !origins.contains(where: { $0.type == OriginType.vaccination.rawValue }) {
							// Make individual cards for the international recovery and test cards
							origins.forEach { origin in
								cards += QRCard.euQRCards(forGreencardGroup: [(greenCard, [origin])], now: now)
							}
						} else {
							// Combine the international vaccination cards
							cards = QRCard.euQRCards(forGreencardGroup: greencardsGroup, now: now)
						}
					}
					return cards
				}
			}

		return qrCards
			// When a GreenCard has no more origins with a
			// current/future validity, hide the Card
			.filter {
				!$0.origins.isEmpty
			}
			.sorted { qrCardA, qrCardB in
				qrCardA.customSortIndex < qrCardB.customSortIndex
			}
	}

	/// Groups greencards based on the type of their (single) origin
	/// (Greencards with multiple origin types are returned ungrouped)
	fileprivate static func groupDBGreenCards(dbGreencards: [(DBGreenCard, [DBOrigin])]) -> [[(DBGreenCard, [DBOrigin])]] {

		// Group using a temporal String key
		// (which is immediately thrown away when we return just the .values of the dictionary)

		let grouped = Dictionary(
			grouping: dbGreencards,
			by: { (dbGreencard: DBGreenCard, origins: [DBOrigin]) -> String in
				guard dbGreencard.getType() != .domestic, // we don't currently group domestic QR Cards
					  origins.count == 1, let type = origins.first?.type
				else { return UUID().uuidString } // use a random string as grouping key, - i.e. forces own group

				return type
			})

		return Array(grouped.values)
	}
}

extension QRCard {

	/// Collection of functions which get repeatedly evaluated (by an external UI timer trigger) to update state
	/// We use closures here to avoid surfacing internal types & implementation to that UI layer.
	private enum Evaluators {

		/// For a given date and greencard, return whether the UI can show that as "enabled" (i.e. it has an active credential):
		static func evaluateButtonEnabledState(date: Date, dbGreencard: DBGreenCard, origins: [GreenCard.Origin]) -> Bool {
			guard !dbGreencard.isDeleted else { return false }
			
			if dbGreencard.getType() == GreenCardType.eu {
				
				// The button is enabled for expired dccs, not for future dccs.
				return origins.contains(where: { $0.validFromDate <= date }) && dbGreencard.getLatestInternationalCredential() != nil
			} else {
				
				let activeCredential: Credential? = dbGreencard.getActiveDomesticCredential(forDate: date)
				let enabled = !(activeCredential == nil || origins.isEmpty) && origins.contains(where: { $0.isCurrentlyValid(now: date) })
				return enabled
			}
		}

		/// For a given date and greencard, return the DCC (used to calculate "X of Y doses" labels in the UI): (might be expired)
		static func evaluateEUCredentialAttributes(date: Date, dbGreencard: DBGreenCard) -> EuCredentialAttributes? {
			guard !dbGreencard.isDeleted else { return nil }

			guard dbGreencard.getType() == .eu,
				  let credentialData = dbGreencard.getLatestInternationalCredential()?.data,
				  let euCredentialAttributes = Current.cryptoManager.readEuCredentials(credentialData)
			else {
				return nil
			}
			return euCredentialAttributes
		}

		/// For a given date and greencard, return the DomesticCredentialAttributes:
		static func evaluateDomesticCredentialAttributes(date: Date, dbGreencard: DBGreenCard) -> DomesticCredentialAttributes? {
			guard !dbGreencard.isDeleted else { return nil }

			guard dbGreencard.getType() == GreenCardType.domestic,
				  let credentialData = dbGreencard.currentOrNextActiveCredential(forDate: date)?.data,
				  let domesticCredentialAttributes = Current.cryptoManager.readDomesticCredentials(credentialData)
			else {
				return nil
			}
			return domesticCredentialAttributes
		}
	}

	// (should only be one index in the array,
	// but better to code defensively..)
	fileprivate static func domesticQRCards(
		forGreencard dbGreencard: DBGreenCard,
		withOrigins dbOrigins: [DBOrigin],
		now: () -> Date
	) -> [QRCard] {
		guard dbGreencard.getType() == GreenCardType.domestic else { return [] }

		// Entries on the Card that represent an Origin.
		let origins = QRCard.GreenCard.Origin.origins(fromDBOrigins: dbOrigins, now: now())

		return [QRCard(
			region: .netherlands(evaluateCredentialAttributes: { greencard, date in
				// Dig around to match the `UI Greencard` back with the `DB Greencard`:
				return Evaluators.evaluateDomesticCredentialAttributes(date: date, dbGreencard: dbGreencard)
			}),
			greencards: [GreenCard(id: dbGreencard.objectID, origins: origins)],
			shouldShowErrorBeneathCard: !dbGreencard.hasActiveCredentialNowOrInFuture(forDate: now()), // doesn't need to be dynamically evaluated
			evaluateEnabledState: { date in
				Evaluators.evaluateButtonEnabledState(date: date, dbGreencard: dbGreencard, origins: origins)
			}
		)]
	}

	fileprivate static func euQRCards(
		forGreencardGroup dbGreencardGroup: [(DBGreenCard, [DBOrigin])],
		now: () -> Date
	) -> [QRCard] {

		// Check that no domestic cards slipped through (logical error if so)
		guard !dbGreencardGroup.contains(where: { $0.0.getType() == GreenCardType.domestic }) else { return [] }

		// Create "UI Greencards" from the DBGreenCard+DBOrigin pairs
		let uiGreencards = dbGreencardGroup.map { pair -> GreenCard in
			let origins = QRCard.GreenCard.Origin.origins(fromDBOrigins: pair.1, now: now())
			return GreenCard(id: pair.0.objectID, origins: origins)
		}

		return [QRCard(
			region: .europeanUnion(evaluateCredentialAttributes: { greencard, date in
				// Dig around to match the `UI Greencard` back with the `DB Greencard`:
				guard let dbGreenCardOriginPair = dbGreencardGroup.first(where: { tuples in greencard.id == tuples.0.objectID })
				else { return nil }

				let dbGreencard = dbGreenCardOriginPair.0
				return Evaluators.evaluateEUCredentialAttributes(date: date, dbGreencard: dbGreencard)
			}),
			greencards: uiGreencards,
			shouldShowErrorBeneathCard: { // This one doesn't need to be (and isn't) dynamically evaluated
				let greencardsWithActiveCredentialsNowOrInFuture = dbGreencardGroup
					.map { $0.0 }
					.filter { $0.hasActiveCredentialNowOrInFuture(forDate: now()) }

				return greencardsWithActiveCredentialsNowOrInFuture.isEmpty
			}(),
			evaluateEnabledState: { date in
				// Find if there are any greencards in the group which allow the button to be enabled
				let greencardsWithEnabledButtonState = dbGreencardGroup
					.filter { pair in
						guard let matchingGreencard = uiGreencards.first(where: { $0.id == pair.0.objectID })
						else { return false }

						return Evaluators.evaluateButtonEnabledState(date: date, dbGreencard: pair.0, origins: matchingGreencard.origins)
					}

				// Return true if there are some enableable greencards:
				return !greencardsWithEnabledButtonState.isEmpty
			}
		)]
	}
}

extension QRCard.GreenCard.Origin {

	fileprivate static func origins(fromDBOrigins dbOrigins: [Origin], now: Date) -> [QRCard.GreenCard.Origin] {

		dbOrigins
			.compactMap { origin -> QRCard.GreenCard.Origin? in
				guard let typeRawValue = origin.type,
					  let type = QRCodeOriginType(rawValue: typeRawValue),
					  let eventDate = origin.eventDate,
					  let expirationTime = origin.expirationTime,
					  let validFromDate = origin.validFromDate
				else { return nil }

				return QRCard.GreenCard.Origin(
					type: type,
					eventDate: eventDate,
					expirationTime: expirationTime,
					validFromDate: validFromDate,
					doseNumber: origin.doseNumber.map { $0.intValue }
				)
			}
			.filter {
				// Pro-actively remove invalid Origins here, in case the database is laggy:
				// Future: this could be moved to the DB layer like how greencard.getActiveCredentials does it.
				now < $0.expirationTime
			}
			.sorted { $0.customSortIndex < $1.customSortIndex }
	}
}
