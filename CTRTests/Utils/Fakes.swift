/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR
import UIKit

extension ForcedInformationConsent {

    static var consentWithoutMandatoryConsent = ForcedInformationConsent(
        title: "test title without mandatory consent",
        highlight: "test highlight without mandatory consent",
        content: "test content without mandatory consent",
        consentMandatory: false
    )

    static var consentWithMandatoryConsent = ForcedInformationConsent(
        title: "test title with mandatory consent",
        highlight: "test highlight with mandatory consent",
        content: "test content with mandatory consent",
        consentMandatory: true
    )
}

extension TestProvider {

    static var fake: TestProvider {
        TestProvider(
			identifier: "xxx",
			name: "Fake Test Provider",
			resultURLString: "https://coronacheck.nl/test",
			publicKey: "",
			certificate: ""
		)
    }
}

extension EventFlow.EventProvider {

	static var vaccinationProvider: EventFlow.EventProvider {
		EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiURL: URL(string: "https://coronacheck.nl"),
			eventURL: URL(string: "https://coronacheck.nl"),
			cmsCertificate: "test",
			tlsCertificate: "test",
			accessToken: nil,
			eventInformationAvailable: nil,
			usages: [.vaccination]
		)
	}

	static var positiveTestProvider: EventFlow.EventProvider {
		EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiURL: URL(string: "https://coronacheck.nl"),
			eventURL: URL(string: "https://coronacheck.nl"),
			cmsCertificate: "test",
			tlsCertificate: "test",
			accessToken: nil,
			eventInformationAvailable: nil,
			usages: [.positiveTest]
		)
	}

	static var recoveryProvider: EventFlow.EventProvider {
		EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiURL: URL(string: "https://coronacheck.nl"),
			eventURL: URL(string: "https://coronacheck.nl"),
			cmsCertificate: "test",
			tlsCertificate: "test",
			accessToken: nil,
			eventInformationAvailable: nil,
			usages: [.recovery]
		)
	}

	static var negativeTestProvider: EventFlow.EventProvider {
		EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiURL: URL(string: "https://coronacheck.nl"),
			eventURL: URL(string: "https://coronacheck.nl"),
			cmsCertificate: "test",
			tlsCertificate: "test",
			accessToken: nil,
			eventInformationAvailable: nil,
			usages: [.negativeTest]
		)
	}
}

extension EventFlow.EventResultWrapper {
	
	static var fakeComplete: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "",
			identity: nil,
			status: .complete,
			result: nil
		)
	}
	
	static var fakePending: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "",
			identity: nil,
			status: .pending,
			result: nil
		)
	}
	
	static var fakeVerificationRequired: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "",
			identity: nil,
			status: .verificationRequired,
			result: nil
		)
	}
	
	static var fakeInvalid: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "",
			identity: nil,
			status: .invalid,
			result: nil
		)
	}
	
	static var fakeUnknown: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "",
			identity: nil,
			status: .unknown,
			result: nil
		)
	}

	static var fakeVaccinationResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		result: nil,
		events: [EventFlow.Event.vaccinationEvent]
	)

	static var fakeRecoveryResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		result: nil,
		events: [EventFlow.Event.recoveryEvent]
	)

	static var fakePositiveTestResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		result: nil,
		events: [EventFlow.Event.positiveTestEvent]
	)

	static var fakeNegativeTestResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		result: nil,
		events: [EventFlow.Event.negativeTestEvent]
	)
	
	static var fakeVaccinationAssessmentResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		result: nil,
		events: [EventFlow.Event.vaccinationAssessmentEvent]
	)
}

extension RequestToken {

    static var fake: RequestToken {
        return RequestToken(
            token: "BBBBBBBBBBBB",
            protocolVersion: "2",
            providerIdentifier: "XXX"
        )
    }
}

extension EuCredentialAttributes.DigitalCovidCertificate {

	static func sampleWithVaccine(doseNumber: Int?, totalDose: Int?) -> EuCredentialAttributes.DigitalCovidCertificate {
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
					country: "Nederland / The Netherlands",
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

	static func sampleWithTest() -> EuCredentialAttributes.DigitalCovidCertificate {
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
					country: "NL",
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
}

extension RemoteGreenCards.Origin {
	
	static var fakeVaccinationOrigin: RemoteGreenCards.Origin {
		RemoteGreenCards.Origin(
			type: "vaccination",
			eventTime: Date(),
			expirationTime: Date(),
			validFrom: Date(),
			doseNumber: 1
		)
	}
	
	static var fakeVaccinationOriginExpiringIn30Days: RemoteGreenCards.Origin {
		RemoteGreenCards.Origin(
			type: "vaccination",
			eventTime: Date(),
			expirationTime: Date().addingTimeInterval(30 * days),
			validFrom: Date(),
			doseNumber: 1
		)
	}
	
	static var fakeRecoveryOriginExpiringIn30Days: RemoteGreenCards.Origin {
		RemoteGreenCards.Origin(
			type: "recovery",
			eventTime: Date(),
			expirationTime: Date().addingTimeInterval(30 * days),
			validFrom: Date(),
			doseNumber: nil
		)
	}
	
	static var fakeVaccinationAssessmentOriginExpiringIn14Days: RemoteGreenCards.Origin {
		RemoteGreenCards.Origin(
			type: "vaccinationassessment",
			eventTime: Date(),
			expirationTime: Date().addingTimeInterval(14 * days),
			validFrom: Date(),
			doseNumber: nil
		)
	}
}

extension RemoteGreenCards.Response {

	static var domesticAndInternationalVaccination: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeVaccinationOrigin
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeVaccinationOrigin
					],
					credential: "test credential"
				)
			]
		)
	}

	static var internationalOnly: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: nil,
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeVaccinationOrigin
					],
					credential: "test credential"
				)
			]
		)
	}

	static var multipleDCC: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeVaccinationOrigin
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeVaccinationOrigin
					],
					credential: "test credential1"
				),
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeVaccinationOrigin
					],
					credential: "test credential2"
				)
			]
		)
	}

	static var noOrigins: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [],
					credential: "test credential"
				)
			]
		)
	}

	static var domesticAndInternationalVaccinationAndRecovery: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeVaccinationOriginExpiringIn30Days,
					RemoteGreenCards.Origin.fakeRecoveryOriginExpiringIn30Days
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeVaccinationOriginExpiringIn30Days
					],
					credential: "test credential"
				),
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeRecoveryOriginExpiringIn30Days
					],
					credential: "test credential"
				)
			]
		)
	}
	
	static var domesticVaccinationAssessment: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeVaccinationAssessmentOriginExpiringIn14Days,
				],
				createCredentialMessages: "test"
			),
			euGreenCards: []
		)
	}

	static var domesticAndInternationalRecovery: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeRecoveryOriginExpiringIn30Days
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeRecoveryOriginExpiringIn30Days
					],
					credential: "test credential"
				)
			]
		)
	}

	static var domesticAndInternationalExpiredRecovery: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin(
						type: "recovery",
						eventTime: Date().addingTimeInterval(400 * days * ago),
						expirationTime: Date().addingTimeInterval(30 * days * ago),
						validFrom: Date().addingTimeInterval(400 * days * ago),
						doseNumber: nil
					)
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeRecoveryOriginExpiringIn30Days
					],
					credential: "test credential"
				)
			]
		)
	}

	static var domesticAndInternationalExpiredRecoveryValidVaccination: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeVaccinationOriginExpiringIn30Days,
					RemoteGreenCards.Origin(
						type: "recovery",
						eventTime: Date().addingTimeInterval(400 * days * ago),
						expirationTime: Date().addingTimeInterval(30 * days * ago),
						validFrom: Date().addingTimeInterval(400 * days * ago),
						doseNumber: nil
					)
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeVaccinationOriginExpiringIn30Days
					],
					credential: "test credential"
				),
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeRecoveryOriginExpiringIn30Days
					],
					credential: "test credential"
				)
			]
		)
	}
}

extension RemoteGreenCards.DomesticGreenCard {
	
	static var fakeVaccinationGreenCardExpiresIn30Days: RemoteGreenCards.DomesticGreenCard {
		RemoteGreenCards.DomesticGreenCard(
			origins: [
				RemoteGreenCards.Origin.fakeVaccinationOriginExpiringIn30Days
			],
			createCredentialMessages: "test"
		)
	}
	
	static var fakeRecoveryGreenCardExpiresIn30Days: RemoteGreenCards.DomesticGreenCard {
		RemoteGreenCards.DomesticGreenCard(
			origins: [
				RemoteGreenCards.Origin.fakeRecoveryOriginExpiringIn30Days
			],
			createCredentialMessages: "test"
		)
	}
}

extension EventFlow.Identity {

	static var fakeIdentity: EventFlow.Identity {
		EventFlow.Identity(
			infix: "",
			firstName: "Corona",
			lastName: "Check",
			birthDateString: "2021-05-16"
		)
	}
}

extension EventFlow.Event {

	static var negativeTestEvent: EventFlow.Event {
		EventFlow.Event(
			type: "test",
			unique: "1234",
			isSpecimen: true,
			vaccination: nil,
			negativeTest: EventFlow.TestEvent(
				sampleDateString: "2021-07-01",
				negativeResult: true,
				positiveResult: nil,
				facility: "GGD XL Factory",
				type: "LP217198-3",
				name: "Antigen Test",
				manufacturer: "1213"
			),
			positiveTest: nil,
			recovery: nil,
			dccEvent: nil,
			assessment: nil
		)
	}

	static var positiveTestEvent: EventFlow.Event {
		EventFlow.Event(
			type: "test",
			unique: "1234",
			isSpecimen: true,
			vaccination: nil,
			negativeTest: nil,
			positiveTest: EventFlow.TestEvent(
				sampleDateString: "2021-07-01",
				negativeResult: nil,
				positiveResult: true,
				facility: "GGD XL Factory",
				type: "LP217198-3",
				name: "Antigen Test",
				manufacturer: "1213"
			),
			recovery: nil,
			dccEvent: nil,
			assessment: nil
		)
	}

	static var vaccinationEvent: EventFlow.Event {
		EventFlow.Event(
			type: "vaccination",
			unique: "1234",
			isSpecimen: true,
			vaccination: EventFlow.VaccinationEvent(
				dateString: "2021-05-16",
				hpkCode: nil,
				type: nil,
				manufacturer: "ORG-100030215",
				brand: "EU/1/20/1528",
				doseNumber: 1,
				totalDoses: 2,
				country: "NLD",
				completedByMedicalStatement: nil,
				completedByPersonalStatement: nil,
				completionReason: nil
			),
			negativeTest: nil,
			positiveTest: nil,
			recovery: nil,
			dccEvent: nil,
			assessment: nil
		)
	}

	static var recoveryEvent: EventFlow.Event {
		EventFlow.Event(
			type: "vaccination",
			unique: "1234",
			isSpecimen: true,
			vaccination: nil,
			negativeTest: nil,
			positiveTest: nil,
			recovery: EventFlow.RecoveryEvent(
				sampleDate: "2021-07-01",
				validFrom: "2021-07-12",
				validUntil: "2022-12-31"
			),
			dccEvent: nil,
			assessment: nil
		)
	}
	
	static var vaccinationAssessmentEvent: EventFlow.Event {
		EventFlow.Event(
			type: "vaccinationassessment",
			unique: "1234",
			isSpecimen: true,
			vaccination: nil,
			negativeTest: nil,
			positiveTest: nil,
			recovery: nil,
			dccEvent: nil,
			assessment: EventFlow.VaccinationAssessment(
				dateTimeString: "2022-01-05T12:42:42Z",
				country: "NLD",
				verified: true
			)
		)
	}
}

extension SignedResponse {
	static var fakeResponse: SignedResponse {
		SignedResponse(
			payload: "payload",
			signature: "signature"
		)
	}
}

extension TestResult {

	static var negativeResult: TestResult {
		TestResult(
			unique: "test",
			sampleDate: "2021-01-01T12:00:00",
			testType: "PCR",
			negativeResult: true,
			holder: TestHolderIdentity(
				firstNameInitial: "T",
				lastNameInitial: "D",
				birthDay: "12",
				birthMonth: "12"
			)
		)
	}
}

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

extension UIImage {

	static func withColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
		let format = UIGraphicsImageRendererFormat()
		format.scale = 1
		let image = UIGraphicsImageRenderer(size: size, format: format).image { rendererContext in
			color.setFill()
			rendererContext.fill(CGRect(origin: .zero, size: size))
		}
		return image
	}
}

extension TVSAuthorizationToken {
	
	static var test: TVSAuthorizationToken = .init(idTokenString: "test", expiration: now.addingTimeInterval(5 * minutes * fromNow))
}

extension EventFlow.EventInformationAvailable {
	static var fakeInformationIsAvailable: EventFlow.EventInformationAvailable {
		EventFlow.EventInformationAvailable(
			providerIdentifier: "CC",
			protocolVersion: "3.0",
			informationAvailable: true
		)
	}
}

extension EventFlow.AccessToken {
	static var fakeTestToken: EventFlow.AccessToken {
		EventFlow.AccessToken(
			providerIdentifier: "CC",
			unomiAccessToken: "unomi test",
			eventAccessToken: "event test"
		)
	}
}

extension EuCredentialAttributes {
	static func fake(dcc: EuCredentialAttributes.DigitalCovidCertificate) -> EuCredentialAttributes {
		EuCredentialAttributes(
			credentialVersion: 1,
			digitalCovidCertificate: dcc,
			expirationTime: Date().timeIntervalSince1970 + 3600,
			issuedAt: Date().timeIntervalSince1970,
			issuer: "NL"
		)
	}
	static func fakeVaccination(dcc: EuCredentialAttributes.DigitalCovidCertificate = .sampleWithVaccine(doseNumber: 1, totalDose: 2)) -> EuCredentialAttributes {
		fake(dcc: dcc)
	}
}
