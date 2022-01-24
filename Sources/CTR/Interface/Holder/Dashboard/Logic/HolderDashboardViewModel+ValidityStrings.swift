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
					
				// -- EU Vaccines --
					
				case (_, .europeanUnion(let dccEvaluator), .vaccination):
					if let euVaccination = dccEvaluator(greencard, now)?.digitalCovidCertificate.vaccinations?.first,
					   let doseNumber = euVaccination.doseNumber,
					   let totalDose = euVaccination.totalDose {
						return validityText_hasBegun_eu_vaccination(doseNumber: String(doseNumber), totalDoses: String(totalDose), validFrom: origin.eventDate)
					} else {
						return validityText_hasBegun_eu_fallback(origin: origin, now: now)
					}
					
				// -- EU Tests --
					
				case (_, .europeanUnion(let dccEvaluator), .test):
					if let euTest = dccEvaluator(greencard, now)?.digitalCovidCertificate.tests?.first {
						let testType = remoteConfigManager.storedConfiguration.getTestTypeMapping(euTest.typeOfTest) ?? euTest.typeOfTest
						return validityText_hasBegun_eu_test(testType: testType, validFrom: origin.eventDate)
					} else {
						return validityText_hasBegun_eu_fallback(origin: origin, now: now)
					}
					
				// -- EU Recoveries --
					
				case (.validityHasBegun, .europeanUnion, .recovery):
					let expiryIsBeyondThreeYearsFromNow = origin.expiryIsBeyondThreeYearsFromNow(now: now)
					
					return validityText_hasBegun_eu_recovery(
						expirationTime: origin.expirationTime,
						expiryIsBeyondThreeYearsFromNow: expiryIsBeyondThreeYearsFromNow,
						isCurrentlyValid: origin.isCurrentlyValid(now: now)
					)
					
				case (.validityHasNotYetBegun, .europeanUnion, .recovery):
					return validityText_hasNotYetBegun_eu_recovery(
						validFrom: origin.validFromDate,
						expirationTime: origin.expirationTime
					)
					
				// -- Domestic Vaccinations --
					
				case (.validityHasBegun, .netherlands, .vaccination):
					let expiryIsBeyondThreeYearsFromNow = origin.expiryIsBeyondThreeYearsFromNow(now: now)
					return validityText_hasBegun_domestic_vaccination(
						expiryIsBeyondThreeYearsFromNow: expiryIsBeyondThreeYearsFromNow,
						doseNumber: origin.doseNumber,
						validFrom: origin.validFromDate,
						expirationTime: origin.expirationTime
					)
				
				case (.validityHasNotYetBegun, .netherlands, .vaccination):
					let expiryIsBeyondThreeYearsFromNow = origin.expiryIsBeyondThreeYearsFromNow(now: now)
					return validityText_hasNotYetBegun_netherlands_vaccination(
						expiryIsBeyondThreeYearsFromNow: expiryIsBeyondThreeYearsFromNow,
						doseNumber: origin.doseNumber,
						qrCard: qrCard,
						validFrom: origin.validFromDate,
						now: now,
						expirationTime: origin.expirationTime
					)
				
				// -- Domestic Tests --
					
				case (.validityHasBegun, .netherlands(let credentialsEvaluator), .test):
					return validityText_hasBegun_domestic_test(
						expirationTime: origin.expirationTime,
						expiryIsBeyondThreeYearsFromNow: origin.expiryIsBeyondThreeYearsFromNow(now: now),
						isCurrentlyValid: origin.isCurrentlyValid(now: now),
						verificationPolicy: credentialsEvaluator(greencard, now)?.verificationPolicy,
						shouldShowRiskLevel: greencard.hasValid3GTestWithoutAValidVaccineOrAValidRecovery(
							credentialEvaluator: credentialsEvaluator,
							now: now
					   )
					)
					
				case (.validityHasNotYetBegun, .netherlands, .test):
					return validityText_hasNotYetBegun_netherlands_test(qrCard: qrCard, origin: origin, now: now)
					
				// -- Domestic Recoveries --
					
				case (.validityHasBegun, .netherlands, .recovery):
					let expiryIsBeyondThreeYearsFromNow = origin.expiryIsBeyondThreeYearsFromNow(now: now)
					
					return validityText_hasBegun_domestic_recovery(
						expirationTime: origin.expirationTime,
						expiryIsBeyondThreeYearsFromNow: expiryIsBeyondThreeYearsFromNow,
						isCurrentlyValid: origin.isCurrentlyValid(now: now)
					)
					
				case (.validityHasNotYetBegun, .netherlands, .recovery):
					return validityText_hasNotYetBegun_domestic_recovery(
						validFrom: origin.validFromDate,
						expirationTime: origin.expirationTime
					)
					
					// -- Domestic Vaccination Assessements --
				case (.validityHasBegun, _, .vaccinationassessment):
					return validityText_hasBegun_domestic_vaccinationAssessment(expirationTime: origin.expirationTime)
				
				case (.validityHasNotYetBegun, _, .vaccinationassessment):
					return validityText_hasNotYetBegun_domestic_vaccinationAssessment(validFrom: origin.validFromDate)
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
				return HolderDashboardViewModel.dateWithoutTimeFormatter
			case .test, .vaccinationassessment:
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

private func validityText_hasBegun_domestic_vaccination(expiryIsBeyondThreeYearsFromNow: Bool, doseNumber: Int?, validFrom: Date, expirationTime: Date) -> HolderDashboardViewController.ValidityText {

	let titleString: String = {
		var string = ""
		string += QRCodeOriginType.vaccination.localizedProof.capitalizingFirstLetter()
		if let doseNumber = doseNumber, doseNumber > 0 {
			let dosePluralised = doseNumber == 1 ? L.generalDose() : L.generalDoses()
			string += " (\(doseNumber) \(dosePluralised))"
		}
		string += ":"
		return string
	}()
	
	let formatter = HolderDashboardViewModel.dateWithoutTimeFormatter
	let dateString: String = expiryIsBeyondThreeYearsFromNow ? formatter.string(from: validFrom) : formatter.string(from: expirationTime)
	let prefix: String = expiryIsBeyondThreeYearsFromNow ? L.holderDashboardQrValidityDatePrefixValidFrom() : L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
	let valueString: String = (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)
	
	return .init(
		lines: [titleString, valueString],
		kind: .current
	)
}

private func validityText_hasNotYetBegun_netherlands_vaccination(expiryIsBeyondThreeYearsFromNow: Bool, doseNumber: Int?, qrCard: QRCard, validFrom: Date, now: Date, expirationTime: Date) -> HolderDashboardViewController.ValidityText {
	let prefix: String = L.holderDashboardQrValidityDatePrefixValidFrom()
	let validFromDateString = HolderDashboardViewModel.dateWithTimeFormatter.string(from: validFrom)
	
	let titleString: String = {
		var string = ""
		string += QRCodeOriginType.vaccination.localizedProof.capitalizingFirstLetter()
		if let doseNumber = doseNumber, doseNumber > 0 {
			let dosePluralised = doseNumber == 1 ? L.generalDose() : L.generalDoses()
			string += " (\(doseNumber) \(dosePluralised))"
		}
		string += ":"
		return string
	}()
	
	var valueString = (prefix + " " + validFromDateString).trimmingCharacters(in: .whitespacesAndNewlines)
	if !expiryIsBeyondThreeYearsFromNow {
		let validUntilDateString = HolderDashboardViewModel.dateWithoutTimeFormatter.string(from: expirationTime)
		valueString = (valueString + " " + L.generalUptoandincluding() + " " + validUntilDateString).trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	return .init(
		lines: [titleString, valueString],
		kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)
	)
}

private func validityText_hasBegun_domestic_test(expirationTime: Date, expiryIsBeyondThreeYearsFromNow: Bool, isCurrentlyValid: Bool, verificationPolicy: VerificationPolicy?, shouldShowRiskLevel: Bool) -> HolderDashboardViewController.ValidityText {
	let prefix = L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
	let formatter = HolderDashboardViewModel.dateWithDayAndTimeFormatter
	let dateString = formatter.string(from: expirationTime)

	let titleString = QRCodeOriginType.test.localizedProof.capitalizingFirstLetter() + ":"
	let valueString: String = {
		let value = (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)
		// TODO: Update copy
		switch (verificationPolicy, shouldShowRiskLevel) {
			case (.policy1G, true):
				return value + (Current.featureFlagManager.isVerificationPolicyEnabled() ? " " + L.holder_dashboard_qr_validity_suffix_2g() : "")
			case (.policy3G, true):
				return value + (Current.featureFlagManager.isVerificationPolicyEnabled() ? " " + L.holder_dashboard_qr_validity_suffix_3g() : "")
			default:
				return value
		}
	}()
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

private func validityText_hasBegun_eu_recovery(expirationTime: Date, expiryIsBeyondThreeYearsFromNow: Bool, isCurrentlyValid: Bool) -> HolderDashboardViewController.ValidityText {

    let prefix = L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding().capitalizingFirstLetter()
	let formatter = HolderDashboardViewModel.dateWithoutTimeFormatter
	let dateString = formatter.string(from: expirationTime)

	let valueString = (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)
	return .init(
		lines: [valueString],
		kind: .current
	)
}

private func validityText_hasNotYetBegun_domestic_recovery(validFrom: Date, expirationTime: Date) -> HolderDashboardViewController.ValidityText {

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

private func validityText_hasNotYetBegun_eu_recovery(validFrom: Date, expirationTime: Date) -> HolderDashboardViewController.ValidityText {

    let prefix = L.holderDashboardQrValidityDatePrefixValidFrom().capitalizingFirstLetter()
	let validFromDateString = HolderDashboardViewModel.dayAndMonthWithTimeFormatter.string(from: validFrom)
	let expiryDateString = HolderDashboardViewModel.dateWithoutTimeFormatter.string(from: expirationTime)

	let valueString = "\(prefix) \(validFromDateString) \(L.generalUptoandincluding()) \(expiryDateString)".trimmingCharacters(in: .whitespacesAndNewlines)
	return .init(
		// geldig vanaf 17 juli t/m 11 mei 2022
		lines: [valueString],
		kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)
	)
}

// Caveat: - "future validity" for a test probably won't happen..
private func validityText_hasNotYetBegun_netherlands_test(qrCard: QRCard, origin: QRCard.GreenCard.Origin, now: Date) -> HolderDashboardViewController.ValidityText {
	let prefix: String = L.holderDashboardQrValidityDatePrefixValidFrom()
	let validFromDateString = HolderDashboardViewModel.dateWithTimeFormatter.string(from: origin.validFromDate)

	let titleString = origin.type.localizedProof.capitalizingFirstLetter() + ":"
	let valueString = (prefix + " " + validFromDateString).trimmingCharacters(in: .whitespacesAndNewlines)
	return .init(
		lines: [titleString, valueString],
		kind: .future(desiresToShowAutomaticallyBecomesValidFooter: true)
	)
}

private func validityText_hasBegun_domestic_vaccinationAssessment(expirationTime: Date) -> HolderDashboardViewController.ValidityText {
	
	let prefix = L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
	let formatter = HolderDashboardViewModel.dateWithDayAndTimeFormatter
	let dateString = formatter.string(from: expirationTime)
	
	let titleString = QRCodeOriginType.vaccinationassessment.localizedProof.capitalizingFirstLetter() + ":"
	let valueString = (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)
	return .init(
		lines: [titleString, valueString],
		kind: .current
	)
}

private func validityText_hasNotYetBegun_domestic_vaccinationAssessment(validFrom: Date) -> HolderDashboardViewController.ValidityText {
	
	let prefix = L.holderDashboardQrValidityDatePrefixValidFrom()
	let formatter = HolderDashboardViewModel.dateWithDayAndTimeFormatter
	let dateString = formatter.string(from: validFrom)
	
	let titleString = QRCodeOriginType.vaccinationassessment.localizedProof.capitalizingFirstLetter() + ":"
	let valueString = (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines)
	return .init(
		lines: [titleString, valueString],
		kind: .current
	)
}
