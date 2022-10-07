/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Shared
import Transport

protocol IdentitySelectionDataSourceProtocol {
	
	func getIdentityInformation(nestedBlobIds: [[String]]) -> [(blobIds: [String], name: String, eventCountInformation: String)]
	
	func getEventOveriew(blobIds: [String]) -> [[String]]
}

class IdentitySelectionDataSource: IdentitySelectionDataSourceProtocol {
	
	// MARK: - Cache
	
	private var wrapperCache: [String: EventFlow.EventResultWrapper] = [:]
	private var euCredentialAttributesCache: [String: EuCredentialAttributes] = [:]
	
	private func getCachedEventResultWrapper(_ uniqueIdentifier: String) -> EventFlow.EventResultWrapper? {
		
		if let wrapper = wrapperCache[uniqueIdentifier] {
			return wrapper
		}
		
		let eventGroups = Current.walletManager.listEventGroups()
		if let eventGroup = eventGroups.first(where: { $0.uniqueIdentifier == uniqueIdentifier }) {
			
			guard let jsonData = eventGroup.jsonData else {
				return nil
			}
			
			if let object = try? JSONDecoder().decode(SignedResponse.self, from: jsonData),
			   let decodedPayloadData = Data(base64Encoded: object.payload),
			   let wrapper = try? JSONDecoder().decode(EventFlow.EventResultWrapper.self, from: decodedPayloadData) {
				
				wrapperCache[uniqueIdentifier] = wrapper
				return wrapper
			}
		}
		return nil
	}
	
	private func getCachedEUCreditialAttributes(_ uniqueIdentifier: String) -> EuCredentialAttributes? {
		
		if let attributes = euCredentialAttributesCache[uniqueIdentifier] {
			return attributes
		}
		
		let eventGroups = Current.walletManager.listEventGroups()
		if let eventGroup = eventGroups.first(where: { $0.uniqueIdentifier == uniqueIdentifier }) {
			
			guard let jsonData = eventGroup.jsonData else {
				return nil
			}
			
			if let object = try? JSONDecoder().decode(EventFlow.DccEvent.self, from: jsonData),
			   let credentialData = object.credential.data(using: .utf8),
			   let euCredentialAttributes = Current.cryptoManager.readEuCredentials(credentialData) {
				euCredentialAttributesCache[uniqueIdentifier] = euCredentialAttributes
				return euCredentialAttributes
			}
		}
		return nil
	}
	
	// MARK: - Populate
	
	func getIdentityInformation(nestedBlobIds: [[String]]) -> [(blobIds: [String], name: String, eventCountInformation: String)] {
		
		var result = [(blobIds: [String], name: String, eventCountInformation: String)]()
		
		nestedBlobIds.forEach { blobIds in
			
			var fullName: String?
			var vaccinationCount = 0
			var testCount = 0
			var assessmentCount = 0
			
			if let primaryId = blobIds.first, let identity = getIdentity(primaryId) {
				fullName = identity.fullName
				logInfo("Name: \(identity.fullName)")
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
	
	func getEventOveriew(blobIds: [String]) -> [[String]] {
		
		var result = [[String]]()
		
//		result.append(
//			[
//				"Vaccinatie",
//				"Opgehaald bij RIVM",
//				"11 januari 2022"
//			]
//		)
//		result.append(
//			[
//				"Negatieve Test",
//				"Opgehaald bij TEST BOER BV",
//				"31 januari 2022"
//			]
//		)
		
		blobIds.forEach { blobId in
			if let wrapper = getCachedEventResultWrapper(blobId) {
				
			} else if let euCredentialAttributes = getCachedEUCreditialAttributes(blobId) {
				
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
		
		if let wrapper = getCachedEventResultWrapper(uniqueIdentifier) {
			result = wrapper.identity
		} else if let euCredentialAttributes = getCachedEUCreditialAttributes(uniqueIdentifier) {
			result = euCredentialAttributes.identity
		}
		return result
	}
	
	private func getEventCount(_ uniqueIdentifier: String) -> (vaccinationCount: Int, testCount: Int, assessmentCount: Int) {
		
		var vaccinationCount = 0
		var testCount = 0
		var assessmentCount = 0
		
		if let wrapper = getCachedEventResultWrapper(uniqueIdentifier) {
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
				if event.hasPaperCertificate {
					logWarning("Help rolus!")
				}
			}
		} else if let euCredentialAttributes = getCachedEUCreditialAttributes(uniqueIdentifier) {
			
			euCredentialAttributes.digitalCovidCertificate.vaccinations?.forEach { _ in vaccinationCount += 1 }
			euCredentialAttributes.digitalCovidCertificate.recoveries?.forEach { _ in testCount += 1 }
			euCredentialAttributes.digitalCovidCertificate.tests?.forEach { _ in testCount += 1 }
		}
		return (vaccinationCount: vaccinationCount, testCount: testCount, assessmentCount: assessmentCount)
	}
	
	private func getEventOverview(vaccinationCount: Int, testCount: Int, assessmentCount: Int) -> String {
		
		var result = ""
		if vaccinationCount > 1 {
			result += "\(vaccinationCount) \(L.general_vaccinations())"
		} else if vaccinationCount == 1 {
			result += "\(vaccinationCount) \(L.general_vaccination())"
		}
		if testCount > 0 {
			if result.isNotEmpty {
				result += " \(L.general_and()) "
			}
			if testCount > 1 {
				result += "\(testCount) \(L.general_testresults())"
			} else {
				result += "\(testCount) \(L.general_testresult())"
			}
		}
		if assessmentCount > 0 {
			if result.isNotEmpty {
				result += " \(L.general_and()) "
			}
			if assessmentCount > 1 {
				result += "\(assessmentCount) \(L.general_vaccinationAssessments())"
			} else {
				result += "\(assessmentCount) \(L.general_vaccinationAssessment())"
			}
		}
		return result
	}
}
