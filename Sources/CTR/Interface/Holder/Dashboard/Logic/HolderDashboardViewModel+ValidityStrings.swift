/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

typealias QRCard = HolderDashboardViewModel.QRCard

extension QRCard {

	enum ValidityType {
		case isExpired
		case validityHasBegun
		case validityHasNotYetBegun

		init(expiration: Date, validFrom: Date, now: Date) {
			let isExpired = expiration < now
			let validityHasBegun = validFrom <= now // but can also have ended! see `isExpired`...

			switch (isExpired, validityHasBegun) {
				case (true, _): // Expired
					self = .isExpired
				case (false, true): // Currently Valid
					self = .validityHasBegun
				case (false, false): // Not yet valid - (valid in future)
					self = .validityHasNotYetBegun
			}
		}

		func text(qrCard: QRCard, greencard: QRCard.GreenCard, origin: QRCard.GreenCard.Origin, now: Date, remoteConfigManager: RemoteConfigManaging) -> HolderDashboardViewController.ValidityText {

			switch (self, qrCard.region, origin.type) {
				case (.isExpired, _, _):
					return validityText_isExpired()

				case (.validityHasBegun, .europeanUnion(let dccEvaluator), .vaccination):
					if let euVaccination = dccEvaluator(greencard, now)?.vaccinations?.first,
					   let doseNumber = euVaccination.doseNumber,
					   let totalDose = euVaccination.totalDose {
						return validityText_hasBegun_eu_vaccination(doseNumber: String(doseNumber), totalDoses: String(totalDose), validFrom: origin.eventDate)
					} else {
						return validityText_hasBegun_eu_fallback(origin: origin, now: now)
					}

				case (.validityHasBegun, .europeanUnion(let dccEvaluator), .test):
					if let euTest = dccEvaluator(greencard, now)?.tests?.first {
						let testType = remoteConfigManager.storedConfiguration.getTestTypeMapping(euTest.typeOfTest) ?? euTest.typeOfTest
						return validityText_hasBegun_eu_test(testType: testType, validFrom: origin.eventDate)
					} else {
						return validityText_hasBegun_eu_fallback(origin: origin, now: now)
					}

				case (.validityHasBegun, .europeanUnion, .recovery):
					return validityText_hasBegun_eu_recovery(isCurrentlyValid: origin.isCurrentlyValid(now: now), expirationTime: origin.expirationTime)

				case (.validityHasBegun, .netherlands, .vaccination):
					return validityText_hasBegun_domestic_vaccination(validFrom: origin.validFromDate)

				case (.validityHasBegun, .netherlands, .test):
					return validityText_hasBegun_domestic_test(
						expirationTime: origin.expirationTime,
						expiryIsBeyondThreeYearsFromNow: origin.expiryIsBeyondThreeYearsFromNow(now: now),
						isCurrentlyValid: origin.isCurrentlyValid(now: now)
					)

				case (.validityHasBegun, .netherlands, .recovery):
					let expiryIsBeyondThreeYearsFromNow = origin.expiryIsBeyondThreeYearsFromNow(now: now)

					return validityText_hasBegun_domestic_recovery(
						expirationTime: origin.expirationTime,
						expiryIsBeyondThreeYearsFromNow: expiryIsBeyondThreeYearsFromNow,
						isCurrentlyValid: origin.isCurrentlyValid(now: now)
					)

				case (.validityHasNotYetBegun, _, .recovery):
					return validityText_hasNotYetBegun_allRegions_recovery(
						validFrom: origin.validFromDate,
						expirationTime: origin.expirationTime
					)

				case (.validityHasNotYetBegun, _, _):
					return validityText_hasNotYetBegun_allRegions_vaccination_or_test(qrCard: qrCard, origin: origin, now: now)
			}
		}
	}
}

private func validityText_isExpired() -> HolderDashboardViewController.ValidityText {
	.init(lines: [], kind: .past)
}

private func validityText_hasBegun_eu_vaccination(doseNumber: String, totalDoses: String, validFrom: Date) -> HolderDashboardViewController.ValidityText {
	let formatter = HolderDashboardViewModel.dateWithoutTimeFormatter
	return .init(
		lines: [
			L.holderDashboardQrEuVaccinecertificatedoses(doseNumber, totalDoses),
			"\(L.generalVaccinationdate()): \(formatter.string(from: validFrom))"
		],
		kind: .current
	)
}

private func validityText_hasBegun_eu_test(testType: String, validFrom: Date) -> HolderDashboardViewController.ValidityText {
	let formatter = HolderDashboardViewModel.dateWithDayAndTimeFormatter
	return .init(
		lines: [
			"\(L.generalTesttype().capitalizingFirstLetter()): \(testType)",
			"\(L.generalTestdate()): \(formatter.string(from: validFrom))"
		],
		kind: .current
	)
}

/// For when e.g. we can't retrieve exactly what we needed from the DCC for proper display,
/// this one provides a fallback for display.
private func validityText_hasBegun_eu_fallback(origin: QRCard.GreenCard.Origin, now: Date) -> HolderDashboardViewController.ValidityText {
	var formatter: DateFormatter {
		switch origin.type {
			case .vaccination, .recovery:
				return HolderDashboardViewModel.dateWithoutTimeFormatter
			case .test:
				return HolderDashboardViewModel.dateWithDayAndTimeFormatter
		}
	}
	var prefix: String {
		if origin.isCurrentlyValid(now: now) {
			switch origin.type {
				case .vaccination:
					return ""
				default:
					return L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding() // "geldig tot"
			}
		} else {
			return L.holderDashboardQrValidityDatePrefixValidFrom()
		}
	}
	let dateString = formatter.string(from: origin.validFromDate)

	let titleString = origin.type.localizedProof.capitalizingFirstLetter() + ":"
	let valueString = (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)

	return .init(
		lines: [titleString, valueString],
		kind: .current
	)
}

private func validityText_hasBegun_eu_recovery(isCurrentlyValid: Bool, expirationTime: Date) -> HolderDashboardViewController.ValidityText {
	var prefix: String {
		if isCurrentlyValid {
			return L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
		}
		return L.holderDashboardQrValidityDatePrefixValidFrom()
	}
	let formatter = HolderDashboardViewModel.dateWithoutTimeFormatter
	let dateString = formatter.string(from: expirationTime)

	let valueString = (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)
	return .init(
		lines: [valueString],
		kind: .current
	)
}

private func validityText_hasBegun_domestic_vaccination(validFrom: Date) -> HolderDashboardViewController.ValidityText {
	let formatter = HolderDashboardViewModel.dateWithoutTimeFormatter
	let dateString = formatter.string(from: validFrom)
	let prefix = L.holderDashboardQrValidityDatePrefixValidFrom()

	let titleString = QRCodeOriginType.vaccination.localizedProof.capitalizingFirstLetter() + ":"
	let valueString = (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)
	return .init(
		lines: [titleString, valueString],
		kind: .current
	)
}

private func validityText_hasBegun_domestic_test(expirationTime: Date, expiryIsBeyondThreeYearsFromNow: Bool, isCurrentlyValid: Bool) -> HolderDashboardViewController.ValidityText {
	let prefix = L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
	let formatter = HolderDashboardViewModel.dateWithDayAndTimeFormatter
	let dateString = formatter.string(from: expirationTime)

	let titleString = QRCodeOriginType.test.localizedProof.capitalizingFirstLetter() + ":"
	let valueString = (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)
	return .init(
		lines: [titleString, valueString],
		kind: .current
	)
}

private func validityText_hasBegun_domestic_recovery(expirationTime: Date, expiryIsBeyondThreeYearsFromNow: Bool, isCurrentlyValid: Bool) -> HolderDashboardViewController.ValidityText {

	let prefix = L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
	let formatter = HolderDashboardViewModel.dateWithoutTimeFormatter
	let dateString = formatter.string(from: expirationTime)

	let titleString = QRCodeOriginType.recovery.localizedProof.capitalizingFirstLetter() + ":"
	let valueString = (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)
	return .init(
		lines: [titleString, valueString],
		kind: .current
	)
}

private func validityText_hasNotYetBegun_allRegions_recovery(validFrom: Date, expirationTime: Date) -> HolderDashboardViewController.ValidityText {

	let prefix = L.holderDashboardQrValidityDatePrefixValidFrom()
	let validFromDateString = HolderDashboardViewModel.dayAndMonthWithTimeFormatter.string(from: validFrom)
	let expiryDateString = HolderDashboardViewModel.dateWithoutTimeFormatter.string(from: expirationTime)

	let titleString = QRCodeOriginType.recovery.localizedProof.capitalizingFirstLetter() + ":"
	let valueString = "\(prefix) \(validFromDateString) \(L.generalUptoandincluding()) \(expiryDateString)".trimmingCharacters(in: .whitespacesAndNewlines)
	return .init(
		// geldig vanaf 17 juli t/m 11 mei 2022
		lines: [titleString, valueString],
		kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)
	)
}

// Caveats!
// - "future validity" for a test probably won't happen..
// - "future validity" for EU doesn't exist currently.
private func validityText_hasNotYetBegun_allRegions_vaccination_or_test(qrCard: QRCard, origin: QRCard.GreenCard.Origin, now: Date) -> HolderDashboardViewController.ValidityText {
	var prefix: String {
		switch qrCard.region {
			case .netherlands:
				return L.holderDashboardQrValidityDatePrefixValidFrom()

			case .europeanUnion:
				return L.holderDashboardQrValidityDatePrefixAutomaticallyBecomesValidOn()
		}
	}

	let validFromDateString = HolderDashboardViewModel.dateWithTimeFormatter.string(from: origin.validFromDate)

	let titleString = origin.type.localizedProof.capitalizingFirstLetter() + ":"
	let valueString = (prefix + " " + validFromDateString).trimmingCharacters(in: .whitespacesAndNewlines)
	return .init(
		lines: [titleString, valueString],
		kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)
	)
}
