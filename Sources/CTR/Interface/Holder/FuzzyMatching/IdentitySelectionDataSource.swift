/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Transport
import Shared
import ReusableViews
import Models
import Resources

protocol IdentitySelectionDataSourceProtocol {
	
	func getIdentity(_ uniqueIdentifier: String) -> EventFlow.Identity?
	
	func getIdentityInformation(matchingBlobIds: [[String]]) -> [(blobIds: [String], name: String, eventCountInformation: String)]
	
	func getEventOveriew(blobIds: [String]) -> [[String]]
	
	func getEventResultWrapper(_ uniqueIdentifier: String) -> EventFlow.EventResultWrapper?
	
	func getEUCreditialAttributes(_ uniqueIdentifier: String) -> EuCredentialAttributes?
}

class IdentitySelectionDataSource: IdentitySelectionDataSourceProtocol {

	internal struct EventSummary: Equatable {
		let event: EventFlow.Event?
		let dateString: String
		let provider: String?
		let paperProof: Bool
		let type: String
		
		init(event: EventFlow.Event? = nil, dateString: String, provider: String? = nil, paperProof: Bool = false, type: String) {
			self.event = event
			self.dateString = dateString
			self.provider = provider
			self.paperProof = paperProof
			self.type = type
		}
	}
	
	var cache: EventGroupCacheProtocol
	
	init(cache: EventGroupCacheProtocol) {
		self.cache = cache
	}
		
	// MARK: - Identity Information
	
	func getIdentity(_ uniqueIdentifier: String) -> EventFlow.Identity? {
		
		var result: EventFlow.Identity?
		
		if let wrapper = cache.getEventResultWrapper(uniqueIdentifier) {
			result = wrapper.identity
		} else if let euCredentialAttributes = cache.getEUCreditialAttributes(uniqueIdentifier) {
			result = euCredentialAttributes.identity
		}
		return result
	}
	
	func getIdentityInformation(matchingBlobIds: [[String]]) -> [(blobIds: [String], name: String, eventCountInformation: String)] {
		
		var result = [(blobIds: [String], name: String, eventCountInformation: String)]()
		
		matchingBlobIds.forEach { blobIds in
			
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
		
		var summaries = [EventSummary]()
		
		blobIds.forEach { blobId in
			if let wrapper = cache.getEventResultWrapper(blobId) {
				wrapper.events?.forEach { event in
					
					let providerName = Current.mappingManager.getProviderIdentifierMapping(wrapper.providerIdentifier) ?? wrapper.providerIdentifier
					
					if event.hasNegativeTest {
						summaries.append(getRowFromNegativeTestEvent(event, providerName: providerName))
					} else if event.hasPositiveTest {
						summaries.append(getRowFromPositiveTestEvent(event, providerName: providerName))
					} else if event.hasRecovery {
						summaries.append(getRowFromRecoveryEvent(event, providerName: providerName))
					} else if event.hasVaccination {
						summaries.append(getRowFromVaccinationEvent(event, providerName: providerName))
					} else if event.hasVaccinationAssessment {
						summaries.append(getRowFromAssessementEvent(event))
					}
				}
			} else if let euCredentialAttributes = cache.getEUCreditialAttributes(blobId) {
				
				euCredentialAttributes.digitalCovidCertificate.vaccinations?.forEach { vaccination in
					summaries.append(getDetailsFromVaccinationDCC(vaccination))
				}
				euCredentialAttributes.digitalCovidCertificate.recoveries?.forEach { recovery in
					summaries.append(getDetailsFromRecoveryDCC(recovery))
				}
				euCredentialAttributes.digitalCovidCertificate.tests?.forEach { test in
					summaries.append(getDetailsFromNegativeTestDCC(test))
				}
			}
		}
		
		return transformEventSummaries(summaries)
	}
	
	private func transformEventSummaries(_ summaries: [EventSummary]) -> [[String]] {
		
		// Bucket for event summaries that are already processed.
		var processedSummaries: [EventSummary] = []
		
		let result: [[String]?] = summaries
			// Sort them by date
			.sorted(by: { $0.dateString > $1.dateString })
			// Map to an array of strings (title/type, info, date)
			.map { summary in
				
				// Process only once, prevents duplication of combined events (Opghaald bij RIVM en GDD)
				guard !processedSummaries.contains(summary) else {
					return nil
				}
				
				var info: String = ""
				if summary.paperProof {
					// Paper proof has a different information message
					info = L.holder_identitySelection_details_scannedPaperProof()
				} else if let providerName = summary.provider {
					// Show the provider (Opgehaald bij RIVM etc)
					info = L.holder_identitySelection_details_fetchedFromProvider(providerName)
					
					// if we are a vaccination
					if let summaryVaccination = summary.event?.vaccination {
						// Loop over all summaries, check if we can combine them
						summaries.forEach { vaccination in
							if let combinedWithVaccination = vaccination.event?.vaccination,
							   let cominedProvider = vaccination.provider,
							   // Actual matching is same date, same (hpkCode or manufacturer)
							   summaryVaccination.doesMatchEvent(combinedWithVaccination),
							   // Exclude ourself from the match.
							   summaryVaccination != combinedWithVaccination {
								// We can combine this summary! Append the provider, mark as processed.
								info += " \(L.general_and()) \(cominedProvider)"
								processedSummaries.append(vaccination)
							}
						}
					}
				}
				processedSummaries.append(summary)
				return [
					summary.type,
					info,
					Formatter.getDateFrom(dateString8601: summary.dateString).map(DateFormatter.Format.dayMonthYear.string) ?? summary.dateString
				]
			}
		return result.compactMap { $0 }
	}
	
	// MARK: - Cache proxy
	
	func getEventResultWrapper(_ uniqueIdentifier: String) -> EventFlow.EventResultWrapper? {
		return cache.getEventResultWrapper(uniqueIdentifier)
	}
	
	func getEUCreditialAttributes(_ uniqueIdentifier: String) -> EuCredentialAttributes? {
		return cache.getEUCreditialAttributes(uniqueIdentifier)
	}
	
	// MARK: - Details From Event

	private func getRowFromNegativeTestEvent(_ event: EventFlow.Event, providerName: String) -> EventSummary {
		
		return EventSummary(
			event: event,
			dateString: event.negativeTest?.sampleDateString ?? "",
			provider: providerName,
			type: L.general_negativeTest().capitalizingFirstLetter()
		)
	}
	
	private func getRowFromPositiveTestEvent(_ event: EventFlow.Event, providerName: String) -> EventSummary {
		
		return EventSummary(
			event: event,
			dateString: event.positiveTest?.sampleDateString ?? "",
			provider: providerName,
			type: L.general_positiveTest().capitalizingFirstLetter()
		)
	}
	
	private func getRowFromRecoveryEvent(_ event: EventFlow.Event, providerName: String) -> EventSummary {
		
		return EventSummary(
			event: event,
			dateString: event.recovery?.sampleDate ?? "",
			provider: providerName,
			type: L.general_recoverycertificate().capitalizingFirstLetter()
		)
	}
	
	private func getRowFromVaccinationEvent(_ event: EventFlow.Event, providerName: String) -> EventSummary {
		
		return EventSummary(
			event: event,
			dateString: event.vaccination?.dateString ?? "",
			provider: providerName,
			type: L.general_vaccination().capitalizingFirstLetter()
		)
	}
	
	private func getRowFromAssessementEvent(_ event: EventFlow.Event) -> EventSummary {
		
		return EventSummary(
			event: event,
			dateString: event.vaccinationAssessment?.dateTimeString ?? "",
			provider: nil,
			type: L.general_vaccinationAssessment().capitalizingFirstLetter()
		)
	}
	
	// MARK: - Details From DCC
	
	private func getDetailsFromVaccinationDCC(_ vaccination: EuCredentialAttributes.Vaccination) -> EventSummary {
		
		var dosage: String = ""
		if let doseNumber = vaccination.doseNumber,
		   let totalDose = vaccination.totalDose {
			dosage = "\(L.generalDose()) \(doseNumber)/\(totalDose)"
		}
		
		return EventSummary(
			dateString: vaccination.dateOfVaccination,
			paperProof: true,
			type: "\(L.general_vaccination().capitalizingFirstLetter()) \(dosage)".trimmingCharacters(in: .whitespaces)
		)
	}
	
	private func getDetailsFromRecoveryDCC(_ recovery: EuCredentialAttributes.RecoveryEntry) -> EventSummary {

		return EventSummary(
			dateString: recovery.firstPositiveTestDate,
			paperProof: true,
			type: L.general_recoverycertificate().capitalizingFirstLetter()
		)
	}

	private func getDetailsFromNegativeTestDCC(_ test: EuCredentialAttributes.TestEntry) -> EventSummary {

		return EventSummary(
			dateString: test.sampleDate,
			paperProof: true,
			type: L.general_negativeTest().capitalizingFirstLetter()
		)
	}
	
	// MARK: - helpers
	
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
