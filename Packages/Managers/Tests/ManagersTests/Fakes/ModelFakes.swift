//
//  File.swift
//  
//
//  Created by Ian Dundas on 10/02/2023.
//

import Foundation
import Transport
import Persistence
@testable import Models
import TestingShared

extension EuCredentialAttributes.TestEntry {

	static var negativeTest: EuCredentialAttributes.TestEntry {
		EuCredentialAttributes.TestEntry(
			certificateIdentifier: "1234",
			country: "NL",
			diseaseAgentTargeted: "840539006",
			issuer: "Ministry of Health Welfare and Sport",
			marketingAuthorizationHolder: "1213",
			name: "fake negativeTest",
			sampleDate: "2021-11-17T16:00:00+01:00",
			testResult: "260415000",
			testCenter: "Facility approved by the State of The Netherlands",
			typeOfTest: "LP217198-3"
		)
	}

	static var positiveTest: EuCredentialAttributes.TestEntry {
		EuCredentialAttributes.TestEntry(
			certificateIdentifier: "1234",
			country: "NL",
			diseaseAgentTargeted: "840539006",
			issuer: "Ministry of Health Welfare and Sport",
			marketingAuthorizationHolder: "1213",
			name: "fake positiveTest",
			sampleDate: "2021-11-17T16:00:00+01:00",
			testResult: "260373001",
			testCenter: "Facility approved by the State of The Netherlands",
			typeOfTest: "LP217198-3"
		)
	}
}

extension EuCredentialAttributes.Vaccination {

	static var vaccination: EuCredentialAttributes.Vaccination {
		EuCredentialAttributes.Vaccination(
			certificateIdentifier: "1234",
			country: "NLD",
			diseaseAgentTargeted: "840539006",
			doseNumber: 2,
			dateOfVaccination: "2021-06-01",
			issuer: "Test",
			marketingAuthorizationHolder: "Test",
			medicalProduct: "Test",
			totalDose: 2,
			vaccineOrProphylaxis: "test"
		)
	}
}

extension EuCredentialAttributes.RecoveryEntry {
	static var recovery: EuCredentialAttributes.RecoveryEntry {
		EuCredentialAttributes.RecoveryEntry(
			certificateIdentifier: "1234",
			country: "NL",
			diseaseAgentTargeted: "840539006",
			expiresAt: "2022-12-31",
			firstPositiveTestDate: "2021-07-01",
			issuer: "Facility approved by the State of The Netherlands",
			validFrom: "2021-07-12"
		)
	}
}

extension EuCredentialAttributes {

	static func fake(
		dcc: EuCredentialAttributes.DigitalCovidCertificate,
		issuer: String = "NL",
		expirationTime: TimeInterval = now.timeIntervalSince1970 + 3600) -> EuCredentialAttributes {
		EuCredentialAttributes(
			credentialVersion: 1,
			digitalCovidCertificate: dcc,
			expirationTime: expirationTime,
			issuedAt: now.timeIntervalSince1970,
			issuer: issuer
		)
	}
	
	static func fakeVaccination(dcc: EuCredentialAttributes.DigitalCovidCertificate = .sampleWithVaccine(doseNumber: 1, totalDose: 2)) -> EuCredentialAttributes {
		fake(dcc: dcc)
	}

	static func foreignFakeVaccination(dcc: EuCredentialAttributes.DigitalCovidCertificate = .sampleWithVaccine(doseNumber: 1, totalDose: 2)) -> EuCredentialAttributes {
		fake(dcc: dcc, issuer: "BE")
	}
	
	static func foreignExpiredFakeVaccination(dcc: EuCredentialAttributes.DigitalCovidCertificate = .sampleWithVaccine(doseNumber: 1, totalDose: 2)) -> EuCredentialAttributes {
		fake(dcc: dcc, issuer: "BE", expirationTime: now.timeIntervalSince1970 - 3600)
	}
	
	static var fakeTest: EuCredentialAttributes {
		EuCredentialAttributes(
			credentialVersion: 1,
			digitalCovidCertificate: .sampleWithTest(),
			expirationTime: now.timeIntervalSince1970 + 3600,
			issuedAt: now.timeIntervalSince1970,
			issuer: "NL"
		)
	}
	
	static var fakeRecovery: EuCredentialAttributes {
		EuCredentialAttributes(
			credentialVersion: 1,
			digitalCovidCertificate: .sampleWithRecovery(),
			expirationTime: now.timeIntervalSince1970 + 3600,
			issuedAt: now.timeIntervalSince1970,
			issuer: "NL"
		)
	}
	
	static var fakeEmptyCertificate: EuCredentialAttributes {
		EuCredentialAttributes(
			credentialVersion: 1,
			digitalCovidCertificate: .sampleWithoutEvent(),
			expirationTime: now.timeIntervalSince1970 + 3600,
			issuedAt: now.timeIntervalSince1970,
			issuer: "NL"
		)
	}
}

// Can't extend RemoteEvent, so this struct will have to do.
struct FakeRemoteEvent {
	
	static var fakeRemoteEventVaccination: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
	}
	
	static var fakeRemoteEventVaccinationOtherProvider: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapperOtherProvider,
			signedResponse: SignedResponse.fakeResponse
		)
	}
	
	static var fakeRemoteEventBooster: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeBoosterResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
	}
	
	static var fakeRemoteEventRecovery: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeRecoveryResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
	}
	
	static var fakeRemoteEventPositiveTest: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakePositiveTestResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
	}
	
	static var fakeRemoteEventExpiredPositiveTest: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeExpiredPositiveTestResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
	}
	
	static var fakeRemoteEventNegativeTest: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeNegativeTestResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
	}
	
	static var fakeRemoteEventNegativeTestGGD: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeNegativeTestGGDResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
	}
	
	static var fakeRemoteEventVaccinationAssessment: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeVaccinationAssessmentResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
	}
	
	static var fakeRemoteEventPaperProof: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakePaperProofResultWrapper,
			signedResponse: SignedResponse.fakeResponse
		)
	}
}

extension EventGroup {
	
	static func fakeEventGroup(dataStoreManager: DataStoreManaging, type: EventMode, expiryDate: Date) throws -> EventGroup? {
		
		var eventGroup: EventGroup?
		let context = dataStoreManager.managedObjectContext()
		let jsonData = try JSONEncoder().encode(EventFlow.DccEvent(credential: "test", couplingCode: "test"))
		
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				eventGroup = EventGroup(
					type: type,
					providerIdentifier: "CoronaCheck",
					expiryDate: expiryDate,
					jsonData: jsonData,
					wallet: wallet,
					isDraft: true,
					managedContext: context
				)
			}
		}
		return eventGroup
	}

	static func createEventGroup(dataStoreManager: DataStoreManaging, wrapper: EventFlow.EventResultWrapper) -> EventGroup? {

		var eventGroup: EventGroup?
		if let payloadData = try? JSONEncoder().encode(wrapper) {
		   let base64String = payloadData.base64EncodedString()
			let signedResponse = SignedResponse(payload: base64String, signature: "does not matter for this test")
			let context = dataStoreManager.managedObjectContext()
			context.performAndWait {
				if let wallet = WalletModel.createTestWallet(managedContext: context),
				   let jsonData = try? JSONEncoder().encode(signedResponse) {
					eventGroup = EventGroup(
						type: EventMode.recovery,
						providerIdentifier: "CoronaCheck",
						expiryDate: nil,
						jsonData: jsonData,
						wallet: wallet,
						isDraft: true,
						managedContext: context
					)
				}
			}
		}
		return eventGroup
	}
	
	static func createDCCEventGroup(dataStoreManager: DataStoreManaging, credential: String, couplingCode: String? = nil) -> EventGroup? {

		var eventGroup: EventGroup?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context),
			   let jsonData = try? JSONEncoder().encode(EventFlow.DccEvent(credential: credential, couplingCode: couplingCode)) {
				eventGroup = EventGroup(
					type: EventMode.recovery,
					providerIdentifier: "DCC",
					expiryDate: nil,
					jsonData: jsonData,
					wallet: wallet,
					isDraft: true,
					managedContext: context
				)
			}
		}
		return eventGroup
	}
}
extension EuCredentialAttributes.DigitalCovidCertificate {

	static func sampleWithVaccine(doseNumber: Int?, totalDose: Int?, country: String = "NL") -> EuCredentialAttributes.DigitalCovidCertificate {
		EuCredentialAttributes.DigitalCovidCertificate(
			dateOfBirth: "2021-06-01",
			name: EuCredentialAttributes.Name(
				familyName: "Corona",
				standardisedFamilyName: "CORONA",
				givenName: "Check",
				standardisedGivenName: "CHECK"
			),
			schemaVersion: "1.0.0",
			vaccinations: [
				EuCredentialAttributes.Vaccination(
					certificateIdentifier: "test",
					country: country,
					diseaseAgentTargeted: "1234",
					doseNumber: doseNumber,
					dateOfVaccination: "2021-06-01",
					issuer: "Test",
					marketingAuthorizationHolder: "Test",
					medicalProduct: "Test",
					totalDose: totalDose,
					vaccineOrProphylaxis: "test"
				)
			]
		)
	}

	static func sampleWithTest(country: String = "NL") -> EuCredentialAttributes.DigitalCovidCertificate {
		EuCredentialAttributes.DigitalCovidCertificate(
			dateOfBirth: "2021-06-01",
			name: EuCredentialAttributes.Name(
				familyName: "Corona",
				standardisedFamilyName: "CORONA",
				givenName: "Check",
				standardisedGivenName: "CHECK"
			),
			schemaVersion: "1.0.0",
			tests: [
				EuCredentialAttributes.TestEntry(
					certificateIdentifier: "URN:UCI:01:NL:WMZBJR3MJRHSPGBCNROM42#M",
					country: country,
					diseaseAgentTargeted: "840539006",
					issuer: "Ministry of Health Welfare and Sport",
					marketingAuthorizationHolder: "",
					name: "",
					sampleDate: "2021-07-31T09:50:00+00:00",
					testResult: "260415000",
					testCenter: "Facility approved by the State of The Netherlands",
					typeOfTest: "LP6464-4"
				)
			]
		)
	}
	
	static func sampleWithRecovery(country: String = "NL") -> EuCredentialAttributes.DigitalCovidCertificate {
		EuCredentialAttributes.DigitalCovidCertificate(
			dateOfBirth: "2021-06-01",
			name: EuCredentialAttributes.Name(
				familyName: "Corona",
				standardisedFamilyName: "CORONA",
				givenName: "Check",
				standardisedGivenName: "CHECK"
			),
			schemaVersion: "1.0.0",
			recoveries: [
				EuCredentialAttributes.RecoveryEntry(
					certificateIdentifier: "URN:UCI:01:NL:WMZBJR3MJRHSPGBCNROM42#M",
					country: country,
					diseaseAgentTargeted: "840539006",
					expiresAt: "2022-07-31T09:50:00+00:00",
					firstPositiveTestDate: "2021-07-31T09:50:00+00:00",
					issuer: "test",
					validFrom: "2021-08-11T09:50:00+00:00"
				)
			]
		)
	}
	
	static func sampleWithoutEvent(country: String = "NL") -> EuCredentialAttributes.DigitalCovidCertificate {
		EuCredentialAttributes.DigitalCovidCertificate(
			dateOfBirth: "2021-06-01",
			name: EuCredentialAttributes.Name(
				familyName: "Corona",
				standardisedFamilyName: "CORONA",
				givenName: "Check",
				standardisedGivenName: "CHECK"
			),
			schemaVersion: "1.0.0"
		)
	}
}

extension DomesticCredentialAttributes {
	
	static func sample(category: String?) -> DomesticCredentialAttributes {
		DomesticCredentialAttributes(
			birthDay: "30",
			birthMonth: "5",
			firstNameInitial: "R",
			lastNameInitial: "P",
			credentialVersion: "2",
			category: category ?? "",
			specimen: "0",
			paperProof: "0",
			validFrom: "\(Date().timeIntervalSince1970)",
			validForHours: "24"
		)
	}
}
