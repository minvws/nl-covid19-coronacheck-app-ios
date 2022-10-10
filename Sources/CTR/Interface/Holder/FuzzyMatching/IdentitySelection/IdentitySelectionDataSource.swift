/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Transport

protocol IdentitySelectionDataSourceProtocol {
	
	func getIdentityInformation(nestedBlobIds: [[String]]) -> [(blobIds: [String], name: String, eventCountInformation: String)]
	
	func getEventOveriew(blobIds: [String]) -> [[String]]
}

class IdentitySelectionDataSource: IdentitySelectionDataSourceProtocol {
	
	// MARK: - Cache
	
	private var cache = EventGroupCache()
		
	// MARK: - Identity Information
	
	func getIdentityInformation(nestedBlobIds: [[String]]) -> [(blobIds: [String], name: String, eventCountInformation: String)] {
		
		var result = [(blobIds: [String], name: String, eventCountInformation: String)]()
		
		nestedBlobIds.forEach { blobIds in
			
			var fullName: String?
			var vaccinationCount = 0
			var testCount = 0
			var assessmentCount = 0
			
			if let primaryId = blobIds.first, let identity = getIdentity(primaryId) {
				fullName = identity.fullName
			}
			
			blobIds.forEach { blobId in
				let count = getEventCount(blobId)
				vaccinationCount += count.vaccinationCount
				testCount += count.testCount
				assessmentCount += count.assessmentCount
			}
			
			if let fullName {
				result.append(
					(blobIds: blobIds,
					 name: fullName,
					 eventCountInformation: getEventOverview(
						vaccinationCount: vaccinationCount,
						testCount: testCount,
						assessmentCount: assessmentCount)
					)
				)
			}
		}
		
		return result
	}
	
	// MARK: Event Overview
	
	func getEventOveriew(blobIds: [String]) -> [[String]] {
		
		var result = [[String]]()
		
		blobIds.forEach { blobId in
			if let wrapper = cache.getEventResultWrapper(blobId) {
				wrapper.events?.forEach { event in
					
					let providerName = Current.mappingManager.getProviderIdentifierMapping(wrapper.providerIdentifier) ?? wrapper.providerIdentifier
					
					if event.hasNegativeTest {
						result.append(getRowFromNegativeTestEvent(event, providerName: providerName))
					} else if event.hasPositiveTest {
						result.append(getRowFromPositiveTestEvent(event, providerName: providerName))
					} else if event.hasRecovery {
						result.append(getRowFromRecoveryEvent(event, providerName: providerName))
					} else if event.hasVaccination {
						result.append(getRowFromVaccinationEvent(event, providerName: providerName))
					} else if event.hasVaccinationAssessment {
						result.append(getRowFromAssessementEvent(event))
					}
				}
			} else if let euCredentialAttributes = cache.getEUCreditialAttributes(blobId) {
				
				euCredentialAttributes.digitalCovidCertificate.vaccinations?.forEach { vaccination in
					result.append(getDetailsFromVaccinationDCC(vaccination))
				}
				euCredentialAttributes.digitalCovidCertificate.recoveries?.forEach { recovery in
					result.append(getDetailsFromRecoveryDCC(recovery))
				}
				euCredentialAttributes.digitalCovidCertificate.tests?.forEach { test in
					result.append(getDetailsFromNegativeTestDCC(test))
				}
			}
		}
		return result
	}
	
	// MARK: - Details From Event

	private func getRowFromNegativeTestEvent(_ event: EventFlow.Event, providerName: String) -> [String] {
		
		let formattedDate: String = event.negativeTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (event.negativeTest?.sampleDateString ?? "")
		
		return [
			L.general_negativeTest().capitalizingFirstLetter(),
			L.holder_identitySelection_details_fetchedFromProvider(providerName),
			formattedDate
		]
	}
	
	private func getRowFromPositiveTestEvent(_ event: EventFlow.Event, providerName: String) -> [String] {
		
		let formattedDate: String = event.positiveTest?.sampleDateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (event.positiveTest?.sampleDateString ?? "")
		
		return [
			L.general_positiveTest().capitalizingFirstLetter(),
			L.holder_identitySelection_details_fetchedFromProvider(providerName),
			formattedDate
		]
	}
	
	private func getRowFromRecoveryEvent(_ event: EventFlow.Event, providerName: String) -> [String] {
		
		let formattedDate: String = event.recovery?.sampleDate
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (event.recovery?.sampleDate ?? "")
		
		return [
			L.general_recoverycertificate().capitalizingFirstLetter(),
			L.holder_identitySelection_details_fetchedFromProvider(providerName),
			formattedDate
		]
	}
	
	private func getRowFromVaccinationEvent(_ event: EventFlow.Event, providerName: String) -> [String] {
		
		let formattedDate: String = event.vaccination?.dateString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (event.vaccination?.dateString ?? "")
		
		return [
			L.general_vaccination().capitalizingFirstLetter(),
			L.holder_identitySelection_details_fetchedFromProvider(providerName),
			formattedDate
		]
	}
	
	private func getRowFromAssessementEvent(_ event: EventFlow.Event) -> [String] {
		
		let formattedDate: String = event.vaccinationAssessment?.dateTimeString
			.flatMap(Formatter.getDateFrom)
			.map(DateFormatter.Format.dayMonthYear.string) ?? (event.vaccinationAssessment?.dateTimeString ?? "")
		
		return [
			L.general_vaccinationAssessment().capitalizingFirstLetter(),
			formattedDate
		]
	}
	
	// MARK: - Details From DCC
	
	private func getDetailsFromVaccinationDCC(_ vaccination: EuCredentialAttributes.Vaccination) -> [String] {
		
		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: vaccination.dateOfVaccination)
			.map(DateFormatter.Format.dayMonthYear.string) ?? vaccination.dateOfVaccination
		
		var dosage: String = ""
		if let doseNumber = vaccination.doseNumber,
		   let totalDose = vaccination.totalDose {
			dosage = "\(L.generalDose()) \(doseNumber)/\(totalDose)"
		}
		
		return [
			"\(L.general_vaccination().capitalizingFirstLetter()) \(dosage)".trimmingCharacters(in: .whitespaces),
			L.holder_identitySelection_details_scannedPaperProof(),
			formattedVaccinationDate
		]
	}
	
	private func getDetailsFromRecoveryDCC(_ recovery: EuCredentialAttributes.RecoveryEntry) -> [String] {

		let formattedTestDate: String = Formatter.getDateFrom(dateString8601: recovery.firstPositiveTestDate)
			.map(DateFormatter.Format.dayMonthYear.string) ?? recovery.firstPositiveTestDate

		return [
			L.general_recoverycertificate().capitalizingFirstLetter(),
			L.holder_identitySelection_details_scannedPaperProof(),
			formattedTestDate
		]
	}

	private func getDetailsFromNegativeTestDCC(_ test: EuCredentialAttributes.TestEntry) -> [String] {

		let formattedTestDate: String = Formatter.getDateFrom(dateString8601: test.sampleDate)
			.map(DateFormatter.Format.dayMonthYear.string) ?? test.sampleDate

		return [
			L.general_negativeTest().capitalizingFirstLetter(),
			L.holder_identitySelection_details_scannedPaperProof(),
			formattedTestDate
		]
	}
	
	// MARK: - helpers
	
	private func getIdentity(_ uniqueIdentifier: String) -> EventFlow.Identity? {
		
		var result: EventFlow.Identity?
		
		if let wrapper = cache.getEventResultWrapper(uniqueIdentifier) {
			result = wrapper.identity
		} else if let euCredentialAttributes = cache.getEUCreditialAttributes(uniqueIdentifier) {
			result = euCredentialAttributes.identity
		}
		return result
	}
	
	private func getEventCount(_ uniqueIdentifier: String) -> (vaccinationCount: Int, testCount: Int, assessmentCount: Int) {
		
		var vaccinationCount = 0
		var testCount = 0
		var assessmentCount = 0
		
		if let wrapper = cache.getEventResultWrapper(uniqueIdentifier) {
			wrapper.events?.forEach { event in
				if event.hasVaccination {
					vaccinationCount += 1
				}
				if event.hasRecovery || event.hasNegativeTest || event.hasPositiveTest {
					testCount += 1
				}
				if event.hasVaccinationAssessment {
					assessmentCount += 1
				}
			}
		} else if let euCredentialAttributes = cache.getEUCreditialAttributes(uniqueIdentifier) {
			
			euCredentialAttributes.digitalCovidCertificate.vaccinations?.forEach { _ in vaccinationCount += 1 }
			euCredentialAttributes.digitalCovidCertificate.recoveries?.forEach { _ in testCount += 1 }
			euCredentialAttributes.digitalCovidCertificate.tests?.forEach { _ in testCount += 1 }
		}
		return (vaccinationCount: vaccinationCount, testCount: testCount, assessmentCount: assessmentCount)
	}
	
	private func getEventOverview(vaccinationCount: Int, testCount: Int, assessmentCount: Int) -> String {
		
		var result = ""
		if vaccinationCount > 0 {
			result += "\(vaccinationCount) \(L.general_vaccinations(vaccinationCount))"
		}
		if testCount > 0 {
			if result.isNotEmpty {
				result += " \(L.general_and()) "
			}
			result += "\(testCount) \(L.general_testresults(testCount))"
		}
		if assessmentCount > 0 {
			if result.isNotEmpty {
				result += " \(L.general_and()) "
			}
			result += "\(assessmentCount) \(L.general_vaccinationAssessments(assessmentCount))"
		}
		return result
	}
}
