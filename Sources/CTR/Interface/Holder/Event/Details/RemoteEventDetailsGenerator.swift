/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared

class NegativeTestDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, event: EventFlow.Event) -> [EventDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (identity.birthDateString ?? "")
		let formattedTestLongDate: String = event.negativeTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayNameDayNumericMonthWithTime.string) ?? (event.negativeTest?.sampleDateString ?? "")

		// Type
		let testType = mappingManager.getTestType(event.negativeTest?.type) ?? (event.negativeTest?.type ?? "")

		// Manufacturer
		let manufacturer = mappingManager.getTestManufacturer(event.negativeTest?.manufacturer) ?? (event.negativeTest?.manufacturer ?? "")

		// Test name
		var testName: String? = event.negativeTest?.name
		if mappingManager.isRatTest(event.negativeTest?.type) {
			testName = mappingManager.getTestName(event.negativeTest?.manufacturer) ?? event.negativeTest?.name
		}

		return [
			EventDetails(field: EventDetailsTest.subtitle, value: nil),
			EventDetails(field: EventDetailsTest.name, value: identity.fullName),
			EventDetails(field: EventDetailsTest.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsTest.testType, value: testType),
			EventDetails(field: EventDetailsTest.testName, value: testName),
			EventDetails(field: EventDetailsTest.date, value: formattedTestLongDate),
			EventDetails(field: EventDetailsTest.result, value: L.holderShowqrEuAboutTestNegativeSingleLanguage()),
			EventDetails(field: EventDetailsTest.facility, value: event.negativeTest?.facility),
			EventDetails(field: EventDetailsTest.manufacturer, value: manufacturer),
			EventDetails(field: EventDetailsTest.uniqueIdentifer, value: event.unique)
		]
	}
}

class PositiveTestDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, event: EventFlow.Event) -> [EventDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (identity.birthDateString ?? "")
		let formattedTestLongDate: String = event.positiveTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayNameDayNumericMonthYearWithTime.string) ?? (event.positiveTest?.sampleDateString ?? "")

		// Type
		let testType = mappingManager.getTestType(event.positiveTest?.type) ?? (event.positiveTest?.type ?? "")

		// Manufacturer
		let manufacturer = mappingManager.getTestManufacturer(event.positiveTest?.manufacturer) ?? (event.negativeTest?.manufacturer ?? "")

		// Test name
		var testName: String? = event.positiveTest?.name
		if mappingManager.isRatTest(event.positiveTest?.type) {
			testName = mappingManager.getTestName(event.positiveTest?.manufacturer) ?? event.positiveTest?.name
		}

		return [
			EventDetails(field: EventDetailsTest.subtitle, value: nil),
			EventDetails(field: EventDetailsTest.name, value: identity.fullName),
			EventDetails(field: EventDetailsTest.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsTest.testType, value: testType),
			EventDetails(field: EventDetailsTest.testName, value: testName),
			EventDetails(field: EventDetailsTest.date, value: formattedTestLongDate),
			EventDetails(field: EventDetailsTest.result, value: L.holderShowqrEuAboutTestPostive()),
			EventDetails(field: EventDetailsTest.facility, value: event.positiveTest?.facility),
			EventDetails(field: EventDetailsTest.manufacturer, value: manufacturer),
			EventDetails(field: EventDetailsTest.uniqueIdentifer, value: event.unique)
		]
	}
}

class DCCTestDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, test: EuCredentialAttributes.TestEntry) -> [EventDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (identity.birthDateString ?? "")

		let formattedTestDate: String = Formatter.getDateFrom(dateString8601: test.sampleDate)
			.map(DateFormatter.Format.dayNameDayNumericMonthWithTime.string) ?? test.sampleDate

		let testType = mappingManager.getTestType(test.typeOfTest) ?? (test.typeOfTest)
		let manufacturer = mappingManager.getTestManufacturer(test.marketingAuthorizationHolder) ?? (test.marketingAuthorizationHolder ?? "")

		let testResult: String
		switch test.testResult {
			case "260415000": testResult = L.holderShowqrEuAboutTestNegativeSingleLanguage()
			case "260373001": testResult = L.holderShowqrEuAboutTestPostive()
			default: testResult = ""
		}

		return [
			EventDetails(field: EventDetailsDCCTest.subtitle, value: nil),
			EventDetails(field: EventDetailsDCCTest.name, value: identity.fullName),
			EventDetails(field: EventDetailsDCCTest.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsDCCTest.pathogen, value: L.holderDccTestPathogenvalue()),
			EventDetails(field: EventDetailsDCCTest.testType, value: testType),
			EventDetails(field: EventDetailsDCCTest.testName, value: test.name),
			EventDetails(field: EventDetailsDCCTest.date, value: formattedTestDate),
			EventDetails(field: EventDetailsDCCTest.result, value: testResult),
			EventDetails(field: EventDetailsDCCTest.facility, value: mappingManager.getDisplayFacility(test.testCenter)),
			EventDetails(field: EventDetailsDCCTest.manufacturer, value: manufacturer),
			EventDetails(field: EventDetailsDCCTest.country, value: mappingManager.getDisplayCountry(test.country)),
			EventDetails(field: EventDetailsDCCTest.issuer, value: mappingManager.getDisplayIssuer(test.issuer, country: test.country)),
			EventDetails(field: EventDetailsDCCTest.certificateIdentifier, value: test.certificateIdentifier)
		]
	}
}

class VaccinationDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, event: EventFlow.Event, providerIdentifier: String) -> [EventDetails] {
		
		let mappingManager: MappingManaging = Current.mappingManager
		
		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (identity.birthDateString ?? "")
		let formattedShotDate: String = event.vaccination?.dateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (event.vaccination?.dateString ?? "")
		let provider: String = mappingManager.getProviderIdentifierMapping(providerIdentifier) ?? providerIdentifier
		
		var vaccinName: String?
		var vaccineDisplayName: String?
		var vaccineType: String?
		var vaccineManufacturer: String?
		if let hpkCode = event.vaccination?.hpkCode,
		   let hpkData = mappingManager.getHpkData(hpkCode) {
			vaccinName = mappingManager.getVaccinationBrand(hpkData.medicalProduct)
			vaccineType = mappingManager.getVaccinationType(hpkData.vaccineOrProphylaxis)
			vaccineManufacturer = mappingManager.getVaccinationManufacturer(hpkData.marketingAuthorizationHolder)
			vaccineDisplayName = hpkData.displayName
		}
		
		if vaccinName == nil, let brand = event.vaccination?.brand {
			vaccinName = mappingManager.getVaccinationBrand(brand)
		}
		if vaccineType == nil {
			vaccineType = mappingManager.getVaccinationType(event.vaccination?.type) ?? event.vaccination?.type
		}
		if vaccineManufacturer == nil {
			vaccineManufacturer = mappingManager.getVaccinationManufacturer(event.vaccination?.manufacturer)
			?? event.vaccination?.manufacturer
		}
		
		var dosage: String?
		if let doseNumber = event.vaccination?.doseNumber,
		   let totalDose = event.vaccination?.totalDoses {
			dosage = L.holderVaccinationAboutOff("\(doseNumber)", "\(totalDose)")
		}
		
		let country = mappingManager.getDisplayCountry(event.vaccination?.country ?? "")
		
		var details = [EventDetails]()
		details += [EventDetails(field: EventDetailsVaccination.subtitle(provider: provider), value: nil)]
		details += [EventDetails(field: EventDetailsVaccination.name, value: identity.fullName)]
		details += [EventDetails(field: EventDetailsVaccination.dateOfBirth, value: formattedBirthDate)]
		details += [EventDetails(field: EventDetailsVaccination.pathogen, value: L.holderEventAboutVaccinationPathogenvalue())]
		details += [EventDetails(field: EventDetailsVaccination.vaccineBrand, value: vaccinName)]
		if vaccineDisplayName != nil {
			details += [EventDetails(field: EventDetailsVaccination.vaccineProductname, value: vaccineDisplayName)]
		}
		details += [EventDetails(field: EventDetailsVaccination.vaccineType, value: vaccineType)]
		details += [EventDetails(field: EventDetailsVaccination.vaccineManufacturer, value: vaccineManufacturer)]
		details += [EventDetails(field: EventDetailsVaccination.dosage, value: dosage)]
		details += [EventDetails(field: EventDetailsVaccination.completionReason, value: event.vaccination?.completionStatus)]
		details += [EventDetails(field: EventDetailsVaccination.date, value: formattedShotDate)]
		details += [EventDetails(field: EventDetailsVaccination.country, value: country)]
		details += [EventDetails(field: EventDetailsVaccination.uniqueIdentifer, value: event.unique)]
		
		return details
	}
}

class DCCVaccinationDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, vaccination: EuCredentialAttributes.Vaccination) -> [EventDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (identity.birthDateString ?? "")

		var dosage: String?
		if let doseNumber = vaccination.doseNumber, let totalDose = vaccination.totalDose, doseNumber > 0, totalDose > 0 {
			dosage = L.holderVaccinationAboutOff("\(doseNumber)", "\(totalDose)")
		}

		let vaccineType = mappingManager.getVaccinationType(vaccination.vaccineOrProphylaxis)
		?? vaccination.vaccineOrProphylaxis
		let vaccineBrand = mappingManager.getVaccinationBrand(vaccination.medicalProduct)
		?? vaccination.medicalProduct
		let vaccineManufacturer = mappingManager.getVaccinationManufacturer( vaccination.marketingAuthorizationHolder)
		?? vaccination.marketingAuthorizationHolder
		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: vaccination.dateOfVaccination)
			.map(DateFormatter.Format.dayMonthYear.string) ?? vaccination.dateOfVaccination

		return [
			EventDetails(field: EventDetailsDCCVaccination.subtitle, value: nil),
			EventDetails(field: EventDetailsDCCVaccination.name, value: identity.fullName),
			EventDetails(field: EventDetailsDCCVaccination.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsDCCVaccination.pathogen, value: L.holderDccVaccinationPathogenvalue()),
			EventDetails(field: EventDetailsDCCVaccination.vaccineBrand, value: vaccineBrand),
			EventDetails(field: EventDetailsDCCVaccination.vaccineType, value: vaccineType),
			EventDetails(field: EventDetailsDCCVaccination.vaccineManufacturer, value: vaccineManufacturer),
			EventDetails(field: EventDetailsDCCVaccination.dosage, value: dosage),
			EventDetails(field: EventDetailsDCCVaccination.date, value: formattedVaccinationDate),
			EventDetails(field: EventDetailsDCCVaccination.country, value: mappingManager.getDisplayCountry(vaccination.country)),
			EventDetails(field: EventDetailsDCCVaccination.issuer, value: mappingManager.getDisplayIssuer(vaccination.issuer, country: vaccination.country)),
			EventDetails(field: EventDetailsDCCVaccination.certificateIdentifier, value: vaccination.certificateIdentifier)
		]
	}
}

class VaccinationAssessementDetailsGenerator {
	
	static func getDetails(identity: EventFlow.Identity, event: EventFlow.Event) -> [EventDetails] {
		
		let mappingManager: MappingManaging = Current.mappingManager
		
		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (identity.birthDateString ?? "")
		let formattedAssessmentDate: String = event.vaccinationAssessment?.dateTimeString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayNameDayNumericMonthWithTime.string) ?? (event.vaccinationAssessment?.dateTimeString ?? "")

		let country = mappingManager.getDisplayCountry(event.vaccinationAssessment?.country ?? "")
		
		var list: [EventDetails] = [
				EventDetails(field: EventDetailsVaccinationAssessment.subtitle, value: nil),
				EventDetails(field: EventDetailsVaccinationAssessment.name, value: identity.fullName),
				EventDetails(field: EventDetailsVaccinationAssessment.dateOfBirth, value: formattedBirthDate),
				EventDetails(field: EventDetailsVaccinationAssessment.date, value: formattedAssessmentDate)
		]
		if country != "" {
			list.append(EventDetails(field: EventDetailsVaccinationAssessment.country, value: country))
		}
		list.append(EventDetails(field: EventDetailsVaccinationAssessment.uniqueIdentifer, value: event.unique))
		return list
	}
}

class RecoveryDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, event: EventFlow.Event) -> [EventDetails] {

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (identity.birthDateString ?? "")
		let formattedShortTestDate: String = event.recovery?.sampleDate
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (event.recovery?.sampleDate ?? "")
		let formattedShortValidFromDate: String = event.recovery?.validFrom
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (event.recovery?.validFrom ?? "")
		let formattedShortValidUntilDate: String = event.recovery?.validUntil
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (event.recovery?.validUntil ?? "")

		return [
			EventDetails(field: EventDetailsRecovery.subtitle, value: nil),
			EventDetails(field: EventDetailsRecovery.name, value: identity.fullName),
			EventDetails(field: EventDetailsRecovery.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsRecovery.date, value: formattedShortTestDate),
			EventDetails(field: EventDetailsRecovery.validFrom, value: formattedShortValidFromDate),
			EventDetails(field: EventDetailsRecovery.validUntil, value: formattedShortValidUntilDate),
			EventDetails(field: EventDetailsRecovery.uniqueIdentifer, value: event.unique)
		]
	}
}

class DCCRecoveryDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, recovery: EuCredentialAttributes.RecoveryEntry) -> [EventDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (identity.birthDateString ?? "")
		let formattedFirstPostiveDate: String = Formatter.getDateFrom(dateString8601: recovery.firstPositiveTestDate)
			.map(DateFormatter.Format.dayMonthYear.string) ?? recovery.firstPositiveTestDate
		let formattedValidFromDate: String = Formatter.getDateFrom(dateString8601: recovery.validFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? recovery.validFrom
		let formattedValidUntilDate: String = Formatter.getDateFrom(dateString8601: recovery.expiresAt)
			.map(DateFormatter.Format.dayMonthYear.string) ?? recovery.expiresAt

		return [
			EventDetails(field: EventDetailsDCCRecovery.subtitle, value: nil),
			EventDetails(field: EventDetailsDCCRecovery.name, value: identity.fullName),
			EventDetails(field: EventDetailsDCCRecovery.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsDCCRecovery.date, value: formattedFirstPostiveDate),
			EventDetails(field: EventDetailsDCCRecovery.country, value: mappingManager.getDisplayCountry(recovery.country)),
			EventDetails(field: EventDetailsDCCRecovery.issuer, value: mappingManager.getDisplayIssuer(recovery.issuer, country: recovery.country)),
			EventDetails(field: EventDetailsDCCRecovery.validFrom, value: formattedValidFromDate),
			EventDetails(field: EventDetailsDCCRecovery.validUntil, value: formattedValidUntilDate),
			EventDetails(field: EventDetailsDCCRecovery.certificateIdentifier, value: recovery.certificateIdentifier)
		]
	}
}

private extension EventFlow.VaccinationEvent {

	/// Get a display version of the vaccination completion status
	var completionStatus: String? {

		// Neither statements are completed: Vaccination incomplete
		guard completedByMedicalStatement == true || completedByPersonalStatement == true else {
			return nil
		}

		// Vaccination completed: Optional clarification for completion
		switch completionReason {
			case .recovery:
				return L.holder_eventdetails_vaccinationStatus_recovery()
			case .firstVaccinationElsewhere:
				return L.holder_eventdetails_vaccinationStatus_firstVaccinationElsewhere()
			default:
				return L.holder_eventdetails_vaccinationStatus_complete()
		}
	}
}
