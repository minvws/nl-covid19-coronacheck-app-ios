/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

// MARK: - Model

extension HolderDashboardViewModel {

	// Domestic:
	//  - A single greencard
	//  - An array of Origins

	// International:
	//  - Multiple greencards
	//  - each with an array of origins

	/// Represents a (set of) Greencard(s) in the UI,
	/// Can be a single card or a stack, depending if it contains greencards which have been grouped together.
	struct QRCard {

		/// Represents the region that the Greencard applies to
		enum Region {
			case netherlands(evaluateCredentials: (QRCard.GreenCard, Date) -> DomesticCredentialAttributes?)
			case europeanUnion(evaluateEUCredentialAttributes: (QRCard.GreenCard, Date) -> EuCredentialAttributes?)
		}

		struct GreenCard: Equatable {
			let id: NSManagedObjectID
			let origins: [Origin]

			struct Origin: Equatable { // swiftlint:disable:this nesting

				let type: QRCodeOriginType // vaccination | test | recovery
				let eventDate: Date
				let expirationTime: Date
				let validFromDate: Date
				let doseNumber: Int?

				/// There is a particular order to sort these onscreen
				var customSortIndex: Int {
					type.customSortIndex
				}

				func isNotYetExpired(now: Date) -> Bool {
					expirationTime > now
				}

				func isCurrentlyValid(now: Date) -> Bool {
					isValid(duringDate: now)
				}

				func isValid(duringDate date: Date) -> Bool {
					date.isWithinTimeWindow(from: validFromDate, to: expirationTime)
				}

				func expiryIsBeyondThreeYearsFromNow(now: Date) -> Bool {
					let threeYearsFromNow: TimeInterval = 60 * 60 * 24 * 365 * 3
					return expirationTime > now.addingTimeInterval(threeYearsFromNow)
				}
			}
		}

		let region: Region // A QR Card only has one region
		let greencards: [GreenCard]
		let shouldShowErrorBeneathCard: Bool
		let evaluateEnabledState: (Date) -> Bool

		func isOfRegion(region: QRCodeValidityRegion) -> Bool {
			switch (self.region, region) {
				case (.europeanUnion, .europeanUnion): return true
				case (.netherlands, .domestic): return true
				default: return false
			}
		}

		/// There is a particular order to sort these onscreen
		var customSortIndex: Int {
			guard let firstGreenCard = greencards.first, // assumption: when multiple greencards, should all have same origin type.
				  let firstOrigin = firstGreenCard.origins.first
			else { return .max }

			return firstOrigin.customSortIndex
		}

		var origins: [GreenCard.Origin] {
			greencards.flatMap { $0.origins }
		}

		/// If at least one origin('s date range) is valid:
		func isCurrentlyValid(now: Date) -> Bool {
			origins
				.contains(where: { $0.isCurrentlyValid(now: now) })
		}

		var effectiveExpiratedAt: Date {
			origins
				.compactMap { $0.expirationTime }
				.sorted()
				.last ?? .distantPast
		}
	}

	struct ExpiredQR: Equatable {
		let id = UUID().uuidString
		let region: QRCodeValidityRegion
		let type: QRCodeOriginType
	}
}

// MARK: - Custom Equatable conformances

extension QRCard.Region: Equatable {
	static func == (lhs: HolderDashboardViewModel.QRCard.Region, rhs: HolderDashboardViewModel.QRCard.Region) -> Bool {
		switch (lhs, rhs) {
			case (.netherlands, .netherlands): return true
			case (.europeanUnion, .europeanUnion):
				// No need to compare the evaluateEUCredentialAttributes function
				return true
			default:
				return false
		}
	}
}

extension QRCard: Equatable {
	static func == (lhs: HolderDashboardViewModel.QRCard, rhs: HolderDashboardViewModel.QRCard) -> Bool {
		let regionsMatch = lhs.region == rhs.region
		let greencardsMatch = lhs.greencards == rhs.greencards
		let shouldShowErrorBeneathCardMatch = lhs.shouldShowErrorBeneathCard == rhs.shouldShowErrorBeneathCard

		return regionsMatch && greencardsMatch && shouldShowErrorBeneathCardMatch
	}
}
