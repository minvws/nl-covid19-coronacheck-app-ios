/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

typealias MyQRCard = HolderDashboardViewModel.MyQRCard

extension MyQRCard {

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

		func text(myQRCard: MyQRCard, origin: MyQRCard.Origin, now: Date, remoteConfigManager: RemoteConfigManaging) -> HolderDashboardViewController.ValidityText {

			switch (self, myQRCard, origin.type) {
				case (.isExpired, _, _):
					return validityText_isExpired()

				case (.validityHasBegun, .europeanUnion, .vaccination):
					if let euVaccination = myQRCard.digitalCovidCertificate(forDate: now)?.vaccinations?.first,
					   let doseNumber = euVaccination.doseNumber,
					   let totalDose = euVaccination.totalDose {
						return validityText_hasBegun_eu_vaccination(doseNumber: String(doseNumber), totalDoses: String(totalDose), validFrom: origin.validFromDate)
					} else {
						return validityText_hasBegun_eu_fallback(origin: origin, now: now)
					}

				case (.validityHasBegun, .europeanUnion, .test):
					if let euTest = myQRCard.digitalCovidCertificate(forDate: now)?.tests?.first {
						let testType = remoteConfigManager.getConfiguration().getTestTypeMapping(euTest.typeOfTest) ?? euTest.typeOfTest
						return validityText_hasBegun_eu_test(testType: testType, validFrom: origin.validFromDate)
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
					return validityText_hasNotYetBegun_allRegions_vaccination_or_test(qrCard: myQRCard, origin: origin, now: now)
			}
		}
	}
}

private extension MyQRCard {

	/// Handy accessor. Only has a value for .europeanUnion cases.
	func digitalCovidCertificate(forDate now: Date) -> EuCredentialAttributes.DigitalCovidCertificate? {
		guard case let .europeanUnion(_, _, _, _, evaluateDCC) = self else { return nil }
		return evaluateDCC(now)
	}
}

private func validityText_isExpired() -> HolderDashboardViewController.ValidityText {
	.init(texts: [], kind: .past)
}

private func validityText_hasBegun_eu_vaccination(doseNumber: String, totalDoses: String, validFrom: Date) -> HolderDashboardViewController.ValidityText {
	let formatter = HolderDashboardViewModel.dateWithoutTimeFormatter
	return .init(
		texts: [
			L.holderDashboardQrEuVaccinecertificatedoses(doseNumber, totalDoses),
			"\(L.generalVaccinationdate()): \(formatter.string(from: validFrom))"
		],
		kind: .current
	)
}

private func validityText_hasBegun_eu_test(testType: String, validFrom: Date) -> HolderDashboardViewController.ValidityText {
	let formatter = HolderDashboardViewModel.dateWithDayAndTimeFormatter
	return .init(
		texts: [
			"\(L.generalTestcertificate().capitalizingFirstLetter()): \(testType)",
			"\(L.generalTestdate()): \(formatter.string(from: validFrom))"
		],
		kind: .current
	)
}

/// For when e.g. we can't retrieve exactly what we needed from the DCC for proper display,
/// this one provides a fallback for display.
private func validityText_hasBegun_eu_fallback(origin: MyQRCard.Origin, now: Date) -> HolderDashboardViewController.ValidityText {
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
					return L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
			}
		} else {
			return L.holderDashboardQrValidityDatePrefixValidFrom()
		}
	}
	let dateString = formatter.string(from: origin.validFromDate)
	return .init(
		texts: [(prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)],
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

	return .init(
		texts: [(prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)],
		kind: .current
	)
}

private func validityText_hasBegun_domestic_vaccination(validFrom: Date) -> HolderDashboardViewController.ValidityText {
	let formatter = HolderDashboardViewModel.dateWithoutTimeFormatter
	let dateString = formatter.string(from: validFrom)
	let prefix = L.holderDashboardQrValidityDatePrefixValidFrom()

	return .init(
		texts: [(prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)],
		kind: .current
	)
}

private func validityText_hasBegun_domestic_test(expirationTime: Date, expiryIsBeyondThreeYearsFromNow: Bool, isCurrentlyValid: Bool) -> HolderDashboardViewController.ValidityText {
	let prefix = L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
	let formatter = HolderDashboardViewModel.dateWithDayAndTimeFormatter
	let dateString = formatter.string(from: expirationTime)
	return .init(
		texts: [(prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)],
		kind: .current
	)
}

private func validityText_hasBegun_domestic_recovery(expirationTime: Date, expiryIsBeyondThreeYearsFromNow: Bool, isCurrentlyValid: Bool) -> HolderDashboardViewController.ValidityText {

	let prefix = L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
	let formatter = HolderDashboardViewModel.dateWithoutTimeFormatter
	let dateString = formatter.string(from: expirationTime)
	return .init(
		texts: [(prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)],
		kind: .current
	)
}

private func validityText_hasNotYetBegun_allRegions_recovery(validFrom: Date, expirationTime: Date) -> HolderDashboardViewController.ValidityText {

	let prefix = L.holderDashboardQrValidityDatePrefixValidFrom()
	let validFromDateString = HolderDashboardViewModel.dayAndMonthWithTimeFormatter.string(from: validFrom)
	let expiryDateString = HolderDashboardViewModel.dateWithoutTimeFormatter.string(from: expirationTime)

	return .init(
		// geldig vanaf 17 juli t/m 11 mei 2022
		texts: ["\(prefix) \(validFromDateString) \(L.generalUptoandincluding()) \(expiryDateString)".trimmingCharacters(in: .whitespacesAndNewlines)],
		kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)
	)
}

private func validityText_hasNotYetBegun_allRegions_vaccination_or_test(qrCard: MyQRCard, origin: MyQRCard.Origin, now: Date) -> HolderDashboardViewController.ValidityText {
	var prefix: String {
		switch qrCard {
			case .netherlands:
				return L.holderDashboardQrValidityDatePrefixValidFrom()

			case .europeanUnion:
				return L.holderDashboardQrValidityDatePrefixAutomaticallyBecomesValidOn()
		}
	}

	let validFromDateString = HolderDashboardViewModel.dateWithTimeFormatter.string(from: origin.validFromDate)
	return .init(
		texts: [(prefix + " " + validFromDateString).trimmingCharacters(in: .whitespacesAndNewlines)],
		kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)
	)
}