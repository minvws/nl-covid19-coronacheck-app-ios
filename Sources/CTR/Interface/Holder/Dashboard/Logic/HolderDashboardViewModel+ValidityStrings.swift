/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Persistence
import Resources

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

		func text(qrCard: QRCard, greencard: QRCard.GreenCard, origin: QRCard.GreenCard.Origin, now: Date) -> HolderDashboardViewController.ValidityText {
			
			switch (self, qrCard.region, origin.type) {
					
				// -- EU Vaccines --
					
				case (.validityHasBegun, .europeanUnion(let dccEvaluator), .vaccination),
					(.validityHasNotYetBegun, .europeanUnion(let dccEvaluator), .vaccination):
					
					if let euVaccination = dccEvaluator(greencard, now)?.digitalCovidCertificate.vaccinations?.first,
					   let doseNumber = euVaccination.doseNumber,
					   let totalDose = euVaccination.totalDose {
						return validityText_hasBegun_eu_vaccination(doseNumber: String(doseNumber), totalDoses: String(totalDose), issuingCountryCode: euVaccination.country, validFrom: origin.eventDate)
					} else {
						return validityText_hasBegun_eu_fallback(origin: origin, now: now)
					}
					
				// -- EU Tests --
					
				case (_, .europeanUnion(let dccEvaluator), .test):
					if let euTest = dccEvaluator(greencard, now)?.digitalCovidCertificate.tests?.first {
						let testType = Current.mappingManager.getTestType(euTest.typeOfTest) ?? euTest.typeOfTest
						return validityText_hasBegun_eu_test(testType: testType, validFrom: origin.eventDate)
					} else {
						return validityText_hasBegun_eu_fallback(origin: origin, now: now)
					}
					
				// -- EU Recoveries --
					
				case (.validityHasBegun, .europeanUnion, .recovery):
					return validityText_hasBegun_eu_recovery(expirationTime: origin.expirationTime)
					
				case (.validityHasNotYetBegun, .europeanUnion, .recovery):
					return validityText_hasNotYetBegun_eu_recovery(
						validFrom: origin.validFromDate,
						expirationTime: origin.expirationTime
					)
					
				case (.isExpired, .europeanUnion, .recovery):
					return validityText_expired_eu_recovery(
						expirationTime: origin.expirationTime
					)
					
					// -- Expired --
					
				case (.isExpired, _, _):
					return validityText_isExpired_fallback()
					
			}
		}
	}
}

private func validityText_isExpired_fallback() -> HolderDashboardViewController.ValidityText {
	.init(lines: [], kind: .past)
}

private func validityText_hasBegun_eu_vaccination(doseNumber: String, totalDoses: String, issuingCountryCode: String, validFrom: Date) -> HolderDashboardViewController.ValidityText {
	let formatter = DateFormatter.Format.dayMonthYear
	
	let dosesAndCountryLine: String = {
		let doses = L.holderDashboardQrEuVaccinecertificatedoses(doseNumber, totalDoses)
		
		// If issued by another country than NL, get the localized name and append to the String:
		if issuingCountryCode != "NL", let issuingCountry = Locale.autoupdatingCurrent.localizedString(forRegionCode: issuingCountryCode) {
			return doses + " (\(issuingCountry))"
		} else {
			return doses
		}
	}()
	
	return .init(
		lines: [
			Shared.Sanitizer.sanitize(dosesAndCountryLine),
			Shared.Sanitizer.sanitize("\(L.generalVaccinationdate()): \(formatter.string(from: validFrom))")
		],
		kind: .current
	)
}

private func validityText_hasBegun_eu_test(testType: String, validFrom: Date) -> HolderDashboardViewController.ValidityText {
	let formatter = DateFormatter.Format.dayNameDayNumericMonthWithTime
	return .init(
		lines: [
			"\(L.generalTesttype().capitalizingFirstLetter()): \(testType)",
			"\(L.generalTestdate().capitalizingFirstLetter()): \(formatter.string(from: validFrom))"
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
				return DateFormatter.Format.dayMonthYear
			case .test:
				return DateFormatter.Format.dayNameDayNumericMonthWithTime
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
	let valueString = Shared.Sanitizer.sanitize((prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines))
	
	return .init(
		lines: [titleString, valueString],
		kind: .current
	)
}

private func validityText_hasBegun_eu_recovery(expirationTime: Date) -> HolderDashboardViewController.ValidityText {
	
	let prefix = L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding().capitalizingFirstLetter()
	let formatter = DateFormatter.Format.dayMonthYear
	let dateString = formatter.string(from: expirationTime)
	
	let valueString = Shared.Sanitizer.sanitize((prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines))
	return .init(
		lines: [valueString],
		kind: .current
	)
}

private func validityText_hasNotYetBegun_eu_recovery(validFrom: Date, expirationTime: Date) -> HolderDashboardViewController.ValidityText {
	
	let prefix = L.holderDashboardQrValidityDatePrefixValidFrom().capitalizingFirstLetter()
	let validFromDateString = DateFormatter.Format.dayMonthWithTime.string(from: validFrom)
	let expiryDateString = DateFormatter.Format.dayMonthYear.string(from: expirationTime)
	
	let valueString = Shared.Sanitizer.sanitize("\(prefix) \(validFromDateString) \(L.generalUptoandincluding()) \(expiryDateString)".trimmingCharacters(in: .whitespacesAndNewlines))
	return .init(
		// geldig vanaf 17 juli t/m 11 mei 2022
		lines: [valueString],
		kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)
	)
}

private func validityText_expired_eu_recovery(expirationTime: Date) -> HolderDashboardViewController.ValidityText {
	
	guard Current.featureFlagManager.isInArchiveMode() else {
		return validityText_isExpired_fallback()
	}
	
	let prefix = L.holder_dashboard_qrValidityDate_expired()
	let expiryDateString = DateFormatter.Format.dayMonthYear.string(from: expirationTime)
	
	let titleString = OriginType.recovery.localizedProof.capitalizingFirstLetter() + ":"
	let valueString = "\(prefix) \(expiryDateString)".trimmingCharacters(in: .whitespacesAndNewlines)
	return .init(
		lines: [titleString, valueString],
		kind: .past
	)
}
