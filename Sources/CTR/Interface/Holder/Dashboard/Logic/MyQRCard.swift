/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

// MARK: - MyQRCard

extension HolderDashboardViewModel {

	/// Represents a Greencard in the UI,
	/// Contains an array of `MyQRCard.Origin`.

	// Future: it's turned out that this can be converted to a struct with a `.region` enum instead
	enum MyQRCard {
		case europeanUnion(greenCardObjectID: NSManagedObjectID, origins: [Origin], shouldShowErrorBeneathCard: Bool, evaluateEnabledState: (Date) -> Bool)
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

			var isNotYetExpired: Bool {
				expirationTime > Date()
			}

			var isCurrentlyValid: Bool {
				isValid(duringDate: Date())
			}

			func isValid(duringDate date: Date) -> Bool {
				date.isWithinTimeWindow(from: validFromDate, to: expirationTime)
			}

			var expiryIsBeyondThreeYearsFromNow: Bool {
				let threeYearsFromNow: TimeInterval = 60 * 60 * 24 * 365 * 3
				return expirationTime > Date(timeIntervalSinceNow: threeYearsFromNow)
			}
		}

		func isOfRegion(region: QRCodeValidityRegion) -> Bool {
			switch (self, region) {
				case (.europeanUnion, .europeanUnion): return true
				case (.netherlands, .domestic): return true
				default: return false
			}
		}

		func localizedDateExplanation(forOrigin origin: Origin, forNow now: Date = Date()) -> HolderDashboardViewController.ValidityText {

			if origin.expirationTime < now { // expired
				return .init(text: "", kind: .past)
			} else if origin.validFromDate > now {
				if origin.validFromDate > (now.addingTimeInterval(60 * 60 * 24)) { // > 1 day until valid

					// we want "full" days in future, so calculate by midnight of the validFromDate day, minus 1 second.
					// (note, when there is <1 day remaining, it switches to counting down in
					// hours/minutes using `HolderDashboardViewModel.hmsRelativeFormatter`
					// elsewhere, so this doesn't apply there anyway.
					let validFromDateEndOfDay: Date? = origin.validFromDate.oneSecondBeforeMidnight

					let dateString = validFromDateEndOfDay.flatMap {
						HolderDashboardViewModel.daysRelativeFormatter.string(from: Date(), to: $0)
					} ?? "-"

					let prefix = localizedDateExplanationPrefix(forOrigin: origin)
					return .init(
						text: (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines),
						kind: .future
					)
				} else {
					let dateString = HolderDashboardViewModel.hmsRelativeFormatter.string(from: Date(), to: origin.validFromDate) ?? "-"
					let prefix = localizedDateExplanationPrefix(forOrigin: origin)
					return .init(
						text: (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines),
						kind: .future
					)
				}
			} else {
				switch self {
					// Netherlands uses expireTime
					case .netherlands:
						if origin.expiryIsBeyondThreeYearsFromNow {
							let prefix = localizedDateExplanationPrefix(forOrigin: origin)
							return .init(text: prefix, kind: .future)
						} else {
							let dateString = localizedDateExplanationDateFormatter(forOrigin: origin).string(from: origin.expirationTime)
							let prefix = localizedDateExplanationPrefix(forOrigin: origin)
								return .init(
									text: (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines),
									kind: .current
								)
						}

					// EU cards use Valid From (eventTime) because we don't know the expiry date
					case .europeanUnion:
						let dateString = localizedDateExplanationDateFormatter(forOrigin: origin).string(from: origin.validFromDate)
						let prefix = localizedDateExplanationPrefix(forOrigin: origin)
						return .init(
							text: (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines),
							kind: .current
						)
				}
			}
		}

		/// There is a particular order to sort these onscreen
		var customSortIndex: Int {
			guard let firstOrigin = origins.first else { return .max }
			return firstOrigin.customSortIndex
		}

		// MARK: - private

		/// Each origin has its own prefix
		private func localizedDateExplanationPrefix(forOrigin origin: Origin) -> String {

			switch self {
				case .netherlands:
					if origin.isCurrentlyValid {
						if origin.expiryIsBeyondThreeYearsFromNow {
							return ""
						} else {
							return L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
						}

					} else {
						return L.holderDashboardQrValidityDatePrefixAutomaticallyBecomesValidOn()
					}

				case .europeanUnion:
					if !origin.isCurrentlyValid && origin.isNotYetExpired {
						return L.holderDashboardQrValidityDatePrefixAutomaticallyBecomesValidOn()
					} else {
						return ""
					}
			}
		}

		/// Each origin has a different date/time format
		/// (Region + Origin) -> DateFormatter
		private func localizedDateExplanationDateFormatter(forOrigin origin: Origin) -> DateFormatter {
			switch (self, origin.type) {
				case (.netherlands, .test):
					return HolderDashboardViewModel.dateWithDayAndTimeFormatter

				case (.netherlands, _):
					return HolderDashboardViewModel.dateWithoutTimeFormatter

				case (.europeanUnion, .vaccination):
					return HolderDashboardViewModel.dateWithoutTimeFormatter

				case (.europeanUnion, .recovery):
					return HolderDashboardViewModel.dayAndMonthFormatter

				case (.europeanUnion, .test):
					return HolderDashboardViewModel.dateWithDayAndTimeFormatter
			}
		}

		/// If at least one origin('s date range) is valid:
		var isCurrentlyValid: Bool {
			origins.contains(where: { $0.isCurrentlyValid })
		}

		/// Without distinguishing NL/EU, just give me the origins:
		var origins: [Origin] {
			switch self {
				case .europeanUnion(_, let origins, _, _), .netherlands(_, let origins, _, _):
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
