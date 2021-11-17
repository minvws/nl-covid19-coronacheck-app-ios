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

		var testResult = test.testResult
		if test.testResult == "260415000" {
			testResult = L.holderShowqrEuAboutTestNegative()
		}
		if test.testResult == "260373001" {
			testResult = L.holderShowqrEuAboutTestPostive()
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
