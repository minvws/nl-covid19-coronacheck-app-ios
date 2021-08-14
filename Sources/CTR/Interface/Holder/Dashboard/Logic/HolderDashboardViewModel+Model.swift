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

	/// Represents a Greencard in the UI,
	/// Contains an array of `MyQRCard.Origin`.

	// Future: it's turned out that this can be converted to a struct with a `.region` enum instead
	enum MyQRCard {
		case europeanUnion(greenCardObjectID: NSManagedObjectID, origins: [Origin], shouldShowErrorBeneathCard: Bool, evaluateEnabledState: (Date) -> Bool, evaluateDCC: (Date) -> EuCredentialAttributes.DigitalCovidCertificate?)
		case netherlands(greenCardObjectID: NSManagedObjectID, origins: [Origin], shouldShowErrorBeneathCard: Bool, evaluateEnabledState: (Date) -> Bool)

		/// Represents an Origin
		struct Origin {

			let type: QRCodeOriginType // vaccination | test | recovery
			let eventDate: Date
			let expirationTime: Date
			let validFromDate: Date

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

		func isOfRegion(region: QRCodeValidityRegion) -> Bool {
			switch (self, region) {
				case (.europeanUnion, .europeanUnion): return true
				case (.netherlands, .domestic): return true
				default: return false
			}
		}

		/// There is a particular order to sort these onscreen
		var customSortIndex: Int {
			guard let firstOrigin = origins.first else { return .max }
			return firstOrigin.customSortIndex
		}

		var greencardID: NSManagedObjectID {
			switch self {
				case let .europeanUnion(greenCardObjectID, _, _, _, _), let .netherlands(greenCardObjectID, _, _, _):
					return greenCardObjectID
			}
		}

		/// If at least one origin('s date range) is valid:
		func isCurrentlyValid(now: Date) -> Bool {
			origins.contains(where: { $0.isCurrentlyValid(now: now) })
		}

		/// Without distinguishing NL/EU, just give me the origins:
		var origins: [Origin] {
			switch self {
				case .europeanUnion(_, let origins, _, _, _), .netherlands(_, let origins, _, _):
					return origins
			}
		}

		var effectiveExpiratedAt: Date {
			return origins.compactMap { $0.expirationTime }.sorted().last ?? .distantPast
		}
	}

	struct ExpiredQR {
		let id = UUID().uuidString
		let region: QRCodeValidityRegion
		let type: QRCodeOriginType
	}
}
