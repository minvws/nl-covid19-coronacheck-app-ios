/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import UIKit
import Shared
import Transport

enum IdentitySelectionState {
	case selected
	case unselected
	case selectionError
	case warning(String)
}

class IdentityObject {
	 
	init(blobIds: [String], name: String, content: String, onShowDetails: @escaping () -> Void, onSelectIdentity: @escaping () -> Void, state: Observable<IdentitySelectionState>) {
		self.blobIds = blobIds
		self.name = name
		self.content = content
		self.onShowDetails = onShowDetails
		self.onSelectIdentity = onSelectIdentity
		self.state = state
	}
	
	var blobIds: [String]
	var name: String
	var content: String
	var onShowDetails: () -> Void
	var onSelectIdentity: () -> Void
	var state: Observable<IdentitySelectionState>
}

class IdentitySelectionViewModel {
	
	// Observable variables
	let title = Observable<String>(value: L.holder_identitySelection_title())
	let message = Observable<String>(value: L.holder_identitySelection_message())
	let whyTitle = Observable<String>(value: L.holder_identitySelection_why())
	let actionTitle = Observable<String>(value: L.holder_identitySelection_actionTitle())
	var errorMessage = Observable<String?>(value: nil)
	var objects = Observable<[IdentityObject]>(value: [])
	var alert: Observable<AlertContent?> = Observable(value: nil)
	
	private var selectedBlobIds = [String]()
	
	weak private var coordinatorDelegate: FuzzyMatchingCoordinatorDelegate?
	
	init(coordinatorDelegate: FuzzyMatchingCoordinatorDelegate, nestedBlobIds: [[String]]) {
		
		self.coordinatorDelegate = coordinatorDelegate
		self.populateIdentityObjects(nestedBlobIds: nestedBlobIds)
	}
	
	private func populateIdentityObjects(nestedBlobIds: [[String]]) {
		
		var identities = [IdentityObject]()
		
		let tuples = IdentitySelectionDataSource().populate(nestedBlobIds: nestedBlobIds)
		for identity in tuples {
			let object = IdentityObject(
				blobIds: identity.blobIds,
				name: identity.name,
				content: identity.content,
				onShowDetails: {
					logInfo("show details")
				},
				onSelectIdentity: {
					self.onSelectIdentity(identity.blobIds)
				},
				state: Observable<IdentitySelectionState>(value: .unselected)
			)
			identities.append(object)
		}
		objects.value = identities
	}
	
	private func onSelectIdentity(_ blobIds: [String]) {
		
		logInfo("onSelectIdentity: \(blobIds)")
		self.selectedBlobIds = blobIds
		objects.value.forEach {
			if $0.blobIds == blobIds {
				$0.state.value = .selected
			} else {
				$0.state.value = .warning(L.holder_identitySelection_error_willBeRemoved())
			}
		}
		
		errorMessage.value = nil
	}
	
	func userWishedToReadMore() {
		
		coordinatorDelegate?.userWishesMoreInfoAboutWhy()
	}
	
	func userWishesToSaveEvents() {
		
		logInfo("userWishesToSaveEvents")
		
		guard selectedBlobIds.isNotEmpty else {
		
			objects.value.forEach { $0.state.value = .selectionError }
			errorMessage.value = L.holder_identitySelection_error_makeAChoice()
			return
		}
		
		coordinatorDelegate?.userHasFinishedTheFlow()
	}
	
	func userWishesToSkip() {
		
		alert.value = AlertContent(
			title: L.holder_identitySelection_skipAlert_title(),
			subTitle: L.holder_identitySelection_skipAlert_body(),
			okAction: AlertContent.Action(title: L.holder_identitySelection_skipAlert_action(), action: { _ in
				self.coordinatorDelegate?.userHasFinishedTheFlow()
			}, isDestructive: true),
			cancelAction: AlertContent.Action(title: L.general_cancel())
		)
	}
}

/*

 general_vaccination [existing entry in lokalize]
 general_vaccinations
 general_testresult [existing entry in lokalize]
 general_testresults
 
 */

class IdentitySelectionDataSource {
	
	func populate(nestedBlobIds: [[String]]) -> [(blobIds: [String], name: String, content: String)] {
		
		var result = [(blobIds: [String], name: String, content: String)]()
		
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
					 content: getEventOverview(
						vaccinationCount: vaccinationCount,
						testCount: testCount,
						assessmentCount: assessmentCount)
					)
				)
			}
		}
		
		return result
	}
	
	func getIdentity(_ uniqueIdentifier: String) -> EventFlow.Identity? {
		
		var result: EventFlow.Identity?
		let eventGroups = Current.walletManager.listEventGroups()
		if let eventGroup = eventGroups.first(where: { $0.uniqueIdentifier == uniqueIdentifier }) {
			
			guard let jsonData = eventGroup.jsonData else {
				return result
			}
			
			if let object = try? JSONDecoder().decode(SignedResponse.self, from: jsonData),
			   let decodedPayloadData = Data(base64Encoded: object.payload),
			   let wrapper = try? JSONDecoder().decode(EventFlow.EventResultWrapper.self, from: decodedPayloadData) {
				
				result = wrapper.identity
			} else if let object = try? JSONDecoder().decode(EventFlow.DccEvent.self, from: jsonData) {
				guard let credentialData = object.credential.data(using: .utf8),
					  let euCredentialAttributes = Current.cryptoManager.readEuCredentials(credentialData) else {
					return result
				}
				result = euCredentialAttributes.identity
			}
		}
		return result
	}
	
	private func getEventCount(_ uniqueIdentifier: String) -> (vaccinationCount: Int, testCount: Int, assessmentCount: Int) {
		
		var vaccinationCount = 0
		var testCount = 0
		var assessmentCount = 0
		
		let eventGroups = Current.walletManager.listEventGroups()
		if let eventGroup = eventGroups.first(where: { $0.uniqueIdentifier == uniqueIdentifier }) {
			
			if let jsonData = eventGroup.jsonData {
				if let object = try? JSONDecoder().decode(SignedResponse.self, from: jsonData),
				   let decodedPayloadData = Data(base64Encoded: object.payload),
				   let wrapper = try? JSONDecoder().decode(EventFlow.EventResultWrapper.self, from: decodedPayloadData) {
					
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
				
				} else if let object = try? JSONDecoder().decode(EventFlow.DccEvent.self, from: jsonData),
						  let credentialData = object.credential.data(using: .utf8),
						  let euCredentialAttributes = Current.cryptoManager.readEuCredentials(credentialData) {
					
					euCredentialAttributes.digitalCovidCertificate.vaccinations?.forEach { _ in vaccinationCount += 1 }
					euCredentialAttributes.digitalCovidCertificate.recoveries?.forEach { _ in testCount += 1 }
					euCredentialAttributes.digitalCovidCertificate.tests?.forEach { _ in testCount += 1 }
				}
			}
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
