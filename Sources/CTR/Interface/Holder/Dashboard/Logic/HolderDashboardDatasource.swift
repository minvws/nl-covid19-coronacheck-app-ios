/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class HolderDashboardDatasource {
	typealias MyQRCard = HolderDashboardViewModel.MyQRCard
	typealias ExpiredQR = HolderDashboardViewModel.ExpiredQR

	var didUpdate: (([HolderDashboardViewModel.MyQRCard], [ExpiredQR]) -> Void)? {
		didSet {
			guard didUpdate != nil else { return }
			reload()
		}
	}

	private let dataStoreManager: DataStoreManaging
	private let walletManager: WalletManaging
	private var reloadTimer: Timer?
	private let now: () -> Date

	init(dataStoreManager: DataStoreManaging, walletManager: WalletManaging, now: @escaping () -> Date) {
		self.dataStoreManager = dataStoreManager
		self.walletManager = walletManager
		self.now = now
	}

	// Calls fetch, then updates subscribers.

	func reload() {
		guard let didUpdate = didUpdate else { return }

		// Clear existing timer:
		reloadTimer?.invalidate()
		reloadTimer = nil

		let expiredGreenCards: [ExpiredQR] = removeExpiredGreenCards()
		let cards: [HolderDashboardViewModel.MyQRCard] = fetchMyQRCards()

		// Callback
		didUpdate(cards, expiredGreenCards)

		// Schedule a Timer to reload the next time an origin will expire:
		reloadTimer = calculateNextReload(cards: cards).map { (nextFetchInterval: TimeInterval) in
			Timer.scheduledTimer(withTimeInterval: nextFetchInterval, repeats: false, block: { [weak self] _ in
				self?.reload()
			})
		}
	}

	private func calculateNextReload(cards: [HolderDashboardViewModel.MyQRCard]) -> TimeInterval? {
		// Calculate when the next reload is needed:
		let nextFetchInterval: TimeInterval = cards
			.flatMap { $0.origins }
			.reduce(Date.distantFuture) { (result: Date, origin: HolderDashboardViewModel.MyQRCard.Origin) -> Date in
				origin.expirationTime < result ? origin.expirationTime : result
			}.timeIntervalSinceNow

		guard nextFetchInterval > 0 else { return nil }
		return nextFetchInterval
	}

	private func removeExpiredGreenCards() -> [ExpiredQR] {
		return walletManager.removeExpiredGreenCards().compactMap { (greencardType: String, originType: String) -> ExpiredQR? in
			guard let region = QRCodeValidityRegion(rawValue: greencardType) else { return nil }
			guard let originType = QRCodeOriginType(rawValue: originType) else { return nil }
			return ExpiredQR(region: region, type: originType)
		}
	}

	/// Fetch the Greencards+Origins from Database
	/// and convert to UI-appropriate model types.
	private func fetchMyQRCards() -> [HolderDashboardViewModel.MyQRCard] {
		let walletManager = walletManager
		let greencards = walletManager.listGreenCards()

		let items = greencards
			.compactMap { (greencard: GreenCard) -> (GreenCard, [Origin])? in
				// Get all origins
				guard let untypedOrigins = greencard.origins else { return nil }
				let origins = untypedOrigins.compactMap({ $0 as? Origin })
				return (greencard, origins)
			}
			// map DB types to local types to have more control over optionality & avoid worrying about threading
			.flatMap { (greencard: GreenCard, origins: [Origin]) -> [MyQRCard] in

				// Entries on the Card that represent an Origin.
				let originEntries = origins
					.compactMap { origin -> MyQRCard.Origin? in
						guard let typeRawValue = origin.type,
							  let type = QRCodeOriginType(rawValue: typeRawValue),
							  let eventDate = origin.eventDate,
							  let expirationTime = origin.expirationTime,
							  let validFromDate = origin.validFromDate
						else { return nil }

						return MyQRCard.Origin(
							type: type,
							eventDate: eventDate,
							expirationTime: expirationTime,
							validFromDate: validFromDate
						)
					}
					.filter {
						// Pro-actively remove invalid Origins here, in case the database is laggy:
						// Future: this could be moved to the DB layer like how greencard.getActiveCredentials does it.
						self.now() < $0.expirationTime
					}
					.sorted { $0.customSortIndex < $1.customSortIndex }

				func evaluateButtonEnabledState(date: Date) -> Bool {
					guard !greencard.isDeleted else { return false }

					let activeCredential: Credential? = greencard.getActiveCredential(forDate: date)
					let enabled = !(activeCredential == nil || originEntries.isEmpty) && originEntries.contains(where: { $0.isCurrentlyValid(now: date) })
					return enabled
				}

				switch greencard.getType() {
					case .domestic:
						return [MyQRCard.netherlands(
							greenCardObjectID: greencard.objectID,
							origins: originEntries,
							shouldShowErrorBeneathCard: !greencard.hasActiveCredentialNowOrInFuture(forDate: now()), // doesn't need to be dynamically evaluated
							evaluateEnabledState: evaluateButtonEnabledState
						)]
					case .eu:
						// The EU cards should only have one entry per card, so let's divide them up:
						return originEntries.map {originEntry in
							MyQRCard.europeanUnion(
								greenCardObjectID: greencard.objectID,
								origins: [originEntry],
								shouldShowErrorBeneathCard: !greencard.hasActiveCredentialNowOrInFuture(forDate: now()), // doesn't need to be dynamically evaluated
								evaluateEnabledState: evaluateButtonEnabledState
							)
						}
					default:
						return []
				}
			}
			.filter {
				// When a GreenCard has no more origins with a
				// current/future validity, hide the Card
				!$0.origins.isEmpty
			}
			.sorted { qrCardA, qrCardB in
				qrCardA.customSortIndex < qrCardB.customSortIndex
			}

		return items
	}
}
