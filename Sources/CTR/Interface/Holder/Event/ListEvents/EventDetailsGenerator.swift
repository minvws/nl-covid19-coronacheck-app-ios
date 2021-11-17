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
}

class NegativeTestDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, event: EventFlow.Event) -> [EventDetails] {

		let mappingManager: MappingManaging = Services.mappingManager

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
			testName = mappingManager.getTestName(event.negativeTest?.name) ?? event.negativeTest?.name
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

class PositiveTestDetailsGenerator {

	static func getDetails(identity: EventFlow.Identity, event: EventFlow.Event) -> [EventDetails] {

		let mappingManager: MappingManaging = Services.mappingManager

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printDateFormatter.string) ?? (identity.birthDateString ?? "")
		let formattedTestLongDate: String = event.positiveTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(EventDetailsGenerator.printTestDateFormatter.string) ?? (event.positiveTest?.sampleDateString ?? "")

		// Type
		let testType = mappingManager.getTestType(event.positiveTest?.type) ?? (event.positiveTest?.type ?? "")

		// Manufacturer
		let manufacturer = mappingManager.getTestManufacturer(event.positiveTest?.manufacturer) ?? (event.negativeTest?.manufacturer ?? "")

		// Test name
		var testName: String? = event.positiveTest?.name
		if mappingManager.isRatTest(event.positiveTest?.type) {
			testName = mappingManager.getTestName(event.negativeTest?.name) ?? event.positiveTest?.name
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

		let mappingManager: MappingManaging = Services.mappingManager

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

		let mappingManager: MappingManaging = Services.mappingManager

		let formattedBirthDate: String = identity.birthDateString
			.flatMap(Formatter.getDateFrom)
			.map(ListEventsViewModel.printDateFormatter.string) ?? (identity.birthDateString ?? "")
		let formattedShotDate: String = event.vaccination?.dateString
			.flatMap(Formatter.getDateFrom)
			.map(ListEventsViewModel.printDateFormatter.string) ?? (event.vaccination?.dateString ?? "")
		let provider: String = mappingManager.getProviderIdentifierMapping(providerIdentifier) ?? providerIdentifier

		var vaccinName: String?
		var vaccineType: String?
		var vaccineManufacturer: String?
		if let hpkCode = event.vaccination?.hpkCode, !hpkCode.isEmpty {
			let hpkData = mappingManager.getHpkData(hpkCode)
			vaccinName = mappingManager.getVaccinationBrand(hpkData?.mp)
			vaccineType = mappingManager.getVaccinationType(hpkData?.vp)
			vaccineManufacturer = mappingManager.getVaccinationManufacturerMapping(hpkData?.ma)
		}

		if vaccinName == nil, let brand = event.vaccination?.brand {
			vaccinName = mappingManager.getVaccinationBrand(brand)
		}
		if vaccineType == nil {
			vaccineType = mappingManager.getVaccinationType(event.vaccination?.type) ?? event.vaccination?.type
		}
		if vaccineManufacturer == nil {
			vaccineManufacturer = mappingManager.getVaccinationManufacturerMapping(event.vaccination?.manufacturer)
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
