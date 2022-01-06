/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct EventDetailsGenerator {

	static let printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "d MMMM yyyy"
		return dateFormatter
	}()

	static let printTestDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
		return dateFormatter
	}()

	static let printTestDateLongFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM yyyy HH:mm"
		return dateFormatter
	}()
}

class NegativeTestDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, event: EventFlow.Event) -> [EventDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (identity.birthDateString ?? "")
		let formattedTestLongDate: String = event.negativeTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printTestDateFormatter.string) ?? (event.negativeTest?.sampleDateString ?? "")

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
			EventDetails(field: EventDetailsTest.result, value: L.holderShowqrEuAboutTestNegative()),
			EventDetails(field: EventDetailsTest.facility, value: event.negativeTest?.facility),
			EventDetails(field: EventDetailsTest.manufacturer, value: manufacturer),
			EventDetails(field: EventDetailsTest.uniqueIdentifer, value: event.unique)
		]
	}
}

class NegativeTestV2DetailsGenerator {

	static func getDetails(testResult: TestResult) -> [EventDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		guard let sampleDate = Formatter.getDateFrom(dateString8601: testResult.sampleDate) else {
			return []
		}

		let printSampleLongDate: String = EventDetailsGenerator.printTestDateFormatter.string(from: sampleDate)
		let holderID = getDisplayIdentity(testResult.holder)

		return [
			EventDetails(field: EventDetailsTest.name, value: holderID),
			EventDetails(field: EventDetailsTest.testType, value: mappingManager.getNlTestType(testResult.testType) ?? testResult.testType),
			EventDetails(field: EventDetailsTest.date, value: printSampleLongDate),
			EventDetails(field: EventDetailsTest.result, value: L.holderShowqrEuAboutTestNegative()),
			EventDetails(field: EventDetailsTest.uniqueIdentifer, value: testResult.unique)
		]
	}

	/// Get a display version of the holder identity
	/// - Parameter holder: the holder identity
	/// - Returns: the display version
	static func getDisplayIdentity(_ holder: TestHolderIdentity?) -> String {

		guard let holder = holder else {
			return ""
		}

		let parts = holder.mapIdentity(months: String.shortMonths)
		var output = ""
		for part in parts {
			output.append(part)
			output.append(" ")
		}
		return output.trimmingCharacters(in: .whitespaces)
	}
}

class PositiveTestDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, event: EventFlow.Event) -> [EventDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (identity.birthDateString ?? "")
		let formattedTestLongDate: String = event.positiveTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printTestDateLongFormatter.string) ?? (event.positiveTest?.sampleDateString ?? "")

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
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (identity.birthDateString ?? "")

		let formattedTestDate: String = Formatter.getDateFrom(dateString8601: test.sampleDate)
			.map(EventDetailsGenerator.printTestDateFormatter.string) ?? test.sampleDate

		let testType = mappingManager.getTestType(test.typeOfTest) ?? (test.typeOfTest)
		let manufacturer = mappingManager.getTestManufacturer(test.marketingAuthorizationHolder) ?? (test.marketingAuthorizationHolder ?? "")

		let testResult: String
		switch test.testResult {
			case "260415000": testResult = L.holderShowqrEuAboutTestNegative()
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
			EventDetails(field: EventDetailsDCCTest.issuer, value: mappingManager.getDisplayIssuer(test.issuer)),
			EventDetails(field: EventDetailsDCCTest.certificateIdentifier, value: test.certificateIdentifier)
		]
	}
}

class VaccinationDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, event: EventFlow.Event, providerIdentifier: String) -> [EventDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (identity.birthDateString ?? "")
		let formattedShotDate: String = event.vaccination?.dateString
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (event.vaccination?.dateString ?? "")
		let provider: String = mappingManager.getProviderIdentifierMapping(providerIdentifier) ?? providerIdentifier

		var vaccinName: String?
		var vaccineType: String?
		var vaccineManufacturer: String?
		if let hpkCode = event.vaccination?.hpkCode, !hpkCode.isEmpty {
			let hpkData = mappingManager.getHpkData(hpkCode)
			vaccinName = mappingManager.getVaccinationBrand(hpkData?.mp)
			vaccineType = mappingManager.getVaccinationType(hpkData?.vp)
			vaccineManufacturer = mappingManager.getVaccinationManufacturer(hpkData?.ma)
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

		return [
			EventDetails(field: EventDetailsVaccination.subtitle(provider: provider), value: nil),
			EventDetails(field: EventDetailsVaccination.name, value: identity.fullName),
			EventDetails(field: EventDetailsVaccination.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsVaccination.pathogen, value: L.holderEventAboutVaccinationPathogenvalue()),
			EventDetails(field: EventDetailsVaccination.vaccineBrand, value: vaccinName),
			EventDetails(field: EventDetailsVaccination.vaccineType, value: vaccineType),
			EventDetails(field: EventDetailsVaccination.vaccineManufacturer, value: vaccineManufacturer),
			EventDetails(field: EventDetailsVaccination.dosage, value: dosage),
			EventDetails(field: EventDetailsVaccination.completionReason, value: event.vaccination?.completionStatus),
			EventDetails(field: EventDetailsVaccination.date, value: formattedShotDate),
			EventDetails(field: EventDetailsVaccination.country, value: country),
			EventDetails(field: EventDetailsVaccination.uniqueIdentifer, value: event.unique)
		]
	}
}

class DCCVaccinationDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, vaccination: EuCredentialAttributes.Vaccination) -> [EventDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (identity.birthDateString ?? "")

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
			.map(EventDetailsGenerator.printDateFormatter.string) ?? vaccination.dateOfVaccination

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
			EventDetails(field: EventDetailsDCCVaccination.issuer, value: mappingManager.getDisplayIssuer(vaccination.issuer)),
			EventDetails(field: EventDetailsDCCVaccination.certificateIdentifier, value: vaccination.certificateIdentifier)
		]
	}
}

class VaccinationAssessementDetailsGenerator {
	
	static func getDetails(identity: EventFlow.Identity, event: EventFlow.Event) -> [EventDetails] {
		
		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (identity.birthDateString ?? "")
		let formattedAssessmentDate: String = event.vaccinationAssessment?.dateTimeString
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printTestDateFormatter.string) ?? (event.vaccinationAssessment?.dateTimeString ?? "")

		return [
			EventDetails(field: EventDetailsVaccinationAssessment.subtitle, value: nil),
			EventDetails(field: EventDetailsVaccinationAssessment.name, value: identity.fullName),
			EventDetails(field: EventDetailsVaccinationAssessment.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsVaccinationAssessment.date, value: formattedAssessmentDate),
			EventDetails(field: EventDetailsVaccinationAssessment.uniqueIdentifer, value: event.unique)
		]
	}
}

class RecoveryDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, event: EventFlow.Event) -> [EventDetails] {

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (identity.birthDateString ?? "")
		let formattedShortTestDate: String = event.recovery?.sampleDate
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (event.recovery?.sampleDate ?? "")
		let formattedShortValidFromDate: String = event.recovery?.validFrom
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (event.recovery?.validFrom ?? "")
		let formattedShortValidUntilDate: String = event.recovery?.validUntil
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (event.recovery?.validUntil ?? "")

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
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (identity.birthDateString ?? "")
		let formattedFirstPostiveDate: String = Formatter.getDateFrom(dateString8601: recovery.firstPositiveTestDate)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? recovery.firstPositiveTestDate
		let formattedValidFromDate: String = Formatter.getDateFrom(dateString8601: recovery.validFrom)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? recovery.validFrom
		let formattedValidUntilDate: String = Formatter.getDateFrom(dateString8601: recovery.expiresAt)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? recovery.expiresAt

		return [
			EventDetails(field: EventDetailsDCCRecovery.subtitle, value: nil),
			EventDetails(field: EventDetailsDCCRecovery.name, value: identity.fullName),
			EventDetails(field: EventDetailsDCCRecovery.dateOfBirth, value: formattedBirthDate),
			EventDetails(field: EventDetailsDCCRecovery.date, value: formattedFirstPostiveDate),
			EventDetails(field: EventDetailsDCCRecovery.country, value: mappingManager.getDisplayCountry(recovery.country)),
			EventDetails(field: EventDetailsDCCRecovery.issuer, value: mappingManager.getDisplayIssuer(recovery.issuer)),
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
				return L.holderVaccinationStatusCompleteRecovery()
			case .priorEvent:
				return L.holderVaccinationStatusCompletePriorevent()
			default:
				return L.holderVaccinationStatusComplete()
		}
	}
}
