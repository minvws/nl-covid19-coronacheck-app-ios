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

		func localizedDateExplanation(forOrigin origin: Origin, forNow now: Date, remoteConfig: RemoteConfigManaging) -> HolderDashboardViewController.ValidityText {

			if origin.expirationTime < now { // expired
				return .init(texts: [], kind: .past)
			} else if origin.validFromDate > now { // valid in future
				let prefix = localizedDateExplanationPrefix(forOrigin: origin, forNow: now)

				switch origin.type {
					case .recovery:
						let validFromDateString = HolderDashboardViewModel.dayAndMonthWithTimeFormatter.string(from: origin.validFromDate)
						let expiryDateString = HolderDashboardViewModel.dateWithoutTimeFormatter.string(from: origin.expirationTime)
						return .init(
							// geldig vanaf 17 juli t/m 11 mei 2022
							texts: ["\(prefix) \(validFromDateString) \(L.generalUptoandincluding()) \(expiryDateString)".trimmingCharacters(in: .whitespacesAndNewlines)],
							kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)
						)
					default:
						let validFromDateString = HolderDashboardViewModel.dateWithTimeFormatter.string(from: origin.validFromDate)
						return .init(
							texts: [(prefix + " " + validFromDateString).trimmingCharacters(in: .whitespacesAndNewlines)],
							kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)
						)
				}
			} else { // valid now
				if case .europeanUnion = self,
					origin.type == .vaccination,
				   let euVaccination = digitalCovidCertificate(forDate: now)?.vaccinations?.first,
				   let doseNumber = euVaccination.doseNumber,
				   let totalDose = euVaccination.totalDose {

					return .init(
						texts: [
							L.holderDashboardQrEuVaccinecertificatedoses(String(doseNumber), String(totalDose)),
							"\(L.generalVaccinationdate()): \(localizedDateExplanationDateFormatter(forOrigin: origin).string(from: origin.validFromDate))"
						],
						kind: .current
					)
				} else if case .europeanUnion = self,
					origin.type == .test,
					let euTest = digitalCovidCertificate(forDate: now)?.tests?.first {

					let testType = remoteConfig.getConfiguration().getTestTypeMapping(euTest.typeOfTest) ?? euTest.typeOfTest

					return .init(
						texts: [
							"\(L.generalTestcertificate().capitalizingFirstLetter()): \(testType)",
							"\(L.generalTestdate()): \(localizedDateExplanationDateFormatter(forOrigin: origin).string(from: origin.validFromDate))"
						],
						kind: .current
					)
				} else if case .netherlands = self,
					origin.type == .vaccination {

					let dateString = localizedDateExplanationDateFormatter(forOrigin: origin).string(from: origin.validFromDate)
					let prefix = localizedDateExplanationPrefix(forOrigin: origin, forNow: now)
					return .init(
						texts: [(prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)],
						kind: .current
					)
				} else {
					switch self {
						// Netherlands uses expireTime
						case .netherlands:
							if origin.expiryIsBeyondThreeYearsFromNow(now: now) {
								let prefix = localizedDateExplanationPrefix(forOrigin: origin, forNow: now)
								return .init(
									texts: [prefix],
									kind: .future(desiresToShowAutomaticallyBecomesValidFooter: false)
								)
							} else {
								let dateString = localizedDateExplanationDateFormatter(forOrigin: origin).string(from: origin.expirationTime)
								let prefix = localizedDateExplanationPrefix(forOrigin: origin, forNow: now)
								return .init(
									texts: [(prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)],
									kind: .current
								)
							}

						case .europeanUnion:

							switch origin.type {
								case .recovery:
									let dateString = localizedDateExplanationDateFormatter(forOrigin: origin).string(from: origin.expirationTime)
									let prefix = localizedDateExplanationPrefix(forOrigin: origin, forNow: now)
									return .init(
										texts: [(prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)],
										kind: .current
									)

								default:
									let dateString = localizedDateExplanationDateFormatter(forOrigin: origin).string(from: origin.validFromDate)
									let prefix = localizedDateExplanationPrefix(forOrigin: origin, forNow: now)
									return .init(
										texts: [(prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)],
										kind: .current
									)
							}
					}
				}
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

		/// Handy accessor. Only has a value for .europeanUnion cases.
		func digitalCovidCertificate(forDate now: Date) -> EuCredentialAttributes.DigitalCovidCertificate? {
			guard case let .europeanUnion(_, _, _, _, evaluateDCC) = self else { return nil }
			return evaluateDCC(now)
		}

		// MARK: - private

		/// Each origin has its own prefix
		private func localizedDateExplanationPrefix(forOrigin origin: Origin, forNow now: Date) -> String {

			switch self {
				case .netherlands:
					if origin.isCurrentlyValid(now: now) {
						switch origin.type {
							case .vaccination:
								return L.holderDashboardQrValidityDatePrefixValidFrom()
							default:
								return L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
						}
					} else {
						return L.holderDashboardQrValidityDatePrefixValidFrom()
					}

				case .europeanUnion:
					switch origin.type {
						case .recovery:
							return L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
						default:
							if !origin.isCurrentlyValid(now: now) && origin.isNotYetExpired(now: now) {
								return L.holderDashboardQrValidityDatePrefixAutomaticallyBecomesValidOn()
							} else {
								return ""
							}
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

				case (.europeanUnion, .vaccination),
					 (.europeanUnion, .recovery):
					return HolderDashboardViewModel.dateWithoutTimeFormatter

				case (.europeanUnion, .test):
					return HolderDashboardViewModel.dateWithDayAndTimeFormatter
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
