/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct QRDetailsGenerator {

	static let printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "dd-MM-yyyy"
		return dateFormatter
	}()

	static let printDateTimeFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
		return dateFormatter
	}()
}

class NegativeTestQRDetailsGenerator {

	static func getDetails(euCredentialAttributes: EuCredentialAttributes, test: EuCredentialAttributes.TestEntry) -> [DCCQRDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		let name = "\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)"
		let formattedBirthDate = euCredentialAttributes.dateOfBirth(QRDetailsGenerator.printDateFormatter)

		let formattedTestDate: String = Formatter.getDateFrom(dateString8601: test.sampleDate)
			.map(QRDetailsGenerator.printDateTimeFormatter.string) ?? test.sampleDate

		let testType = mappingManager.getTestType(test.typeOfTest) ?? test.typeOfTest

		let manufacturer = mappingManager.getTestManufacturer(test.marketingAuthorizationHolder) ?? (test.marketingAuthorizationHolder ?? "")

		var testResult = test.testResult
		if test.testResult == "260415000" {
			testResult = L.holderShowqrEuAboutTestNegative()
		}
		if test.testResult == "260373001" {
			testResult = L.holderShowqrEuAboutTestPostive()
		}

		// Test name
		var testName: String? = test.name
		if mappingManager.isRatTest(test.typeOfTest) {
			testName = mappingManager.getTestName(test.marketingAuthorizationHolder) ?? test.name
		}

		return [
			DCCQRDetails(field: DCCQRDetailsTest.name, value: name),
			DCCQRDetails(field: DCCQRDetailsTest.dateOfBirth, value: formattedBirthDate),
			DCCQRDetails(field: DCCQRDetailsTest.pathogen, value: L.holderShowqrEuAboutTestPathogenvalue()),
			DCCQRDetails(field: DCCQRDetailsTest.testType, value: testType),
			DCCQRDetails(field: DCCQRDetailsTest.testName, value: testName),
			DCCQRDetails(field: DCCQRDetailsTest.date, value: formattedTestDate),
			DCCQRDetails(field: DCCQRDetailsTest.result, value: testResult),
			DCCQRDetails(field: DCCQRDetailsTest.facility, value: mappingManager.getDisplayFacility(test.testCenter)),
			DCCQRDetails(field: DCCQRDetailsTest.manufacturer, value: manufacturer),
			DCCQRDetails(field: DCCQRDetailsTest.country, value: mappingManager.getBiLingualDisplayCountry(test.country)),
			DCCQRDetails(field: DCCQRDetailsTest.issuer, value: mappingManager.getDisplayIssuer(test.issuer)),
			DCCQRDetails(field: DCCQRDetailsTest.uniqueIdentifer, value: test.certificateIdentifier)
		]
	}
}

class VaccinationQRDetailsGenerator {

	static func getDetails(euCredentialAttributes: EuCredentialAttributes, vaccination: EuCredentialAttributes.Vaccination) -> [DCCQRDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		var dosage: String?
		if let doseNumber = vaccination.doseNumber, let totalDose = vaccination.totalDose, doseNumber > 0, totalDose > 0 {
			dosage = "\(doseNumber) / \(totalDose)"
		}

		let vaccineType = mappingManager.getVaccinationType(vaccination.vaccineOrProphylaxis) ?? vaccination.vaccineOrProphylaxis
		let vaccineBrand = mappingManager.getVaccinationBrand(vaccination.medicalProduct) ?? vaccination.medicalProduct
		let vaccineManufacturer = mappingManager.getVaccinationManufacturer(vaccination.marketingAuthorizationHolder) ?? vaccination.marketingAuthorizationHolder

		let name = "\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)"
		let formattedBirthDate = euCredentialAttributes.dateOfBirth(QRDetailsGenerator.printDateFormatter)

		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: vaccination.dateOfVaccination)
			.map(QRDetailsGenerator.printDateFormatter.string) ?? vaccination.dateOfVaccination

		return [
			DCCQRDetails(field: DCCQRDetailsVaccination.name, value: name),
			DCCQRDetails(field: DCCQRDetailsVaccination.dateOfBirth, value: formattedBirthDate),
			DCCQRDetails(field: DCCQRDetailsVaccination.pathogen, value: L.holderShowqrEuAboutVaccinationPathogenvalue()),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineBrand, value: vaccineBrand),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineType, value: vaccineType),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineManufacturer, value: vaccineManufacturer),
			DCCQRDetails(field: DCCQRDetailsVaccination.dosage, value: dosage),
			DCCQRDetails(field: DCCQRDetailsVaccination.date, value: formattedVaccinationDate),
			DCCQRDetails(field: DCCQRDetailsVaccination.country, value: mappingManager.getBiLingualDisplayCountry(vaccination.country)),
			DCCQRDetails(field: DCCQRDetailsVaccination.issuer, value: mappingManager.getDisplayIssuer(vaccination.issuer)),
			DCCQRDetails(field: DCCQRDetailsVaccination.uniqueIdentifer, value: vaccination.certificateIdentifier)
		]
	}
}

class RecoveryQRDetailsGenerator {

	static func getDetails(euCredentialAttributes: EuCredentialAttributes, recovery: EuCredentialAttributes.RecoveryEntry) -> [DCCQRDetails] {

		let mappingManager: MappingManaging = Current.mappingManager

		let name = "\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)"
		let formattedBirthDate = euCredentialAttributes.dateOfBirth(QRDetailsGenerator.printDateFormatter)

		let formattedFirstPostiveDate: String = Formatter.getDateFrom(dateString8601: recovery.firstPositiveTestDate)
			.map(QRDetailsGenerator.printDateFormatter.string) ?? recovery.firstPositiveTestDate
		let formattedValidFromDate: String = Formatter.getDateFrom(dateString8601: recovery.validFrom)
			.map(QRDetailsGenerator.printDateFormatter.string) ?? recovery.validFrom
		let formattedValidUntilDate: String = Formatter.getDateFrom(dateString8601: recovery.expiresAt)
			.map(QRDetailsGenerator.printDateFormatter.string) ?? recovery.expiresAt

		return [
			DCCQRDetails(field: DCCQRDetailsRecovery.name, value: name),
			DCCQRDetails(field: DCCQRDetailsRecovery.dateOfBirth, value: formattedBirthDate),
			DCCQRDetails(field: DCCQRDetailsRecovery.pathogen, value: L.holderShowqrEuAboutRecoveryPathogenvalue()),
			DCCQRDetails(field: DCCQRDetailsRecovery.date, value: formattedFirstPostiveDate),
			DCCQRDetails(field: DCCQRDetailsRecovery.country, value: mappingManager.getBiLingualDisplayCountry(recovery.country)),
			DCCQRDetails(field: DCCQRDetailsRecovery.issuer, value: mappingManager.getDisplayIssuer(recovery.issuer)),
			DCCQRDetails(field: DCCQRDetailsRecovery.validFrom, value: formattedValidFromDate),
			DCCQRDetails(field: DCCQRDetailsRecovery.validUntil, value: formattedValidUntilDate),
			DCCQRDetails(field: DCCQRDetailsRecovery.uniqueIdentifer, value: recovery.certificateIdentifier)
		]
	}
}

private extension EuCredentialAttributes {

	func dateOfBirth(_ dateFormatter: DateFormatter) -> String {
		return Formatter
			.getDateFrom(dateString8601: digitalCovidCertificate.dateOfBirth)
			.map(dateFormatter.string)
		?? digitalCovidCertificate.dateOfBirth
	}
}
