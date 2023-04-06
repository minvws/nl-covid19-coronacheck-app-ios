/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import Transport
import TestingShared

// MARK: ModelsTest

extension TestProvider {

	public static var fake: TestProvider {
		TestProvider(
			identifier: "xxx",
			name: "Fake Test Provider",
			resultURLString: "https://coronacheck.nl/test",
			cmsCertificates: [],
			tlsCertificates: [],
			usages: [.negativeTest]
		)
	}
}

extension EventFlow.EventProvider {

	static var vaccinationProvider: EventFlow.EventProvider {
		EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiUrl: URL(string: "https://coronacheck.nl"),
			eventUrl: URL(string: "https://coronacheck.nl"),
			cmsCertificates: [],
			tlsCertificates: [],
			accessToken: nil,
			eventInformationAvailable: nil,
			usages: [.vaccination],
			providerAuthentication: [.manyAuthenticationExchange, .patientAuthenticationProvider]
		)
	}

	static var positiveTestProvider: EventFlow.EventProvider {
		EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiUrl: URL(string: "https://coronacheck.nl"),
			eventUrl: URL(string: "https://coronacheck.nl"),
			cmsCertificates: [],
			tlsCertificates: [],
			accessToken: nil,
			eventInformationAvailable: nil,
			usages: [.positiveTest],
			providerAuthentication: [.manyAuthenticationExchange, .patientAuthenticationProvider]
		)
	}
}

extension EventFlow.EventResultWrapper {

	static var fakeComplete: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "",
			identity: EventFlow.Identity.fakeIdentity,
			status: .complete
		)
	}

	static var fakePending: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "",
			identity: EventFlow.Identity.fakeIdentity,
			status: .pending
		)
	}

	static var fakeBlocked: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "",
			identity: EventFlow.Identity.fakeIdentity,
			status: .blocked
		)
	}

	static var fakeVerificationRequired: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "",
			identity: EventFlow.Identity.fakeIdentity,
			status: .verificationRequired
		)
	}

	static var fakeInvalid: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "",
			identity: EventFlow.Identity.fakeIdentity,
			status: .invalid
		)
	}

	static var fakeUnknown: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "",
			identity: EventFlow.Identity.fakeIdentity,
			status: .unknown
		)
	}

	static var fakeVaccinationResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		events: [EventFlow.Event.vaccinationEvent]
	)

	static var fakeVaccinationResultWrapperOtherProvider = EventFlow.EventResultWrapper(
		providerIdentifier: "GGD",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		events: [EventFlow.Event.vaccinationEvent]
	)

	static var fakeBoosterResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		events: [EventFlow.Event.boosterEvent]
	)

	static var fakeMultipleVaccinationResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		events: [EventFlow.Event.vaccinationEvent, EventFlow.Event.boosterEvent]
	)

	static var fakeRecoveryResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		events: [EventFlow.Event.recoveryEvent]
	)

	static var fakePositiveTestResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		events: [EventFlow.Event.positiveTestEvent]
	)

	static var fakeExpiredPositiveTestResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		events: [EventFlow.Event.expiredPositiveTestEvent]
	)

	static var fakeNegativeTestResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		events: [EventFlow.Event.negativeTestEvent]
	)

	static var fakeNegativeTestGGDResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "GGD",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		events: [EventFlow.Event.negativeTestEvent]
	)

	static var fakePaperProofResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		events: [EventFlow.Event.paperProofEvent]
	)

	static var fakeVaccinationAssessmentResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		events: [EventFlow.Event.vaccinationAssessmentEvent]
	)

	static var fakeMultipleEventsResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		events: [
			EventFlow.Event.vaccinationAssessmentEvent,
			EventFlow.Event.vaccinationEvent,
			EventFlow.Event.negativeTestEvent,
			EventFlow.Event.expiredPositiveTestEvent,
			EventFlow.Event.recoveryEvent
		]
	)

	static var fakeWithV3Identity: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Test", lastName: "de Tester", birthDateString: "1990-12-12"),
			status: .complete
		)
	}

	static var fakeWithV3IdentityAlternative: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Rool", lastName: "Paap", birthDateString: "1970-05-27"),
			status: .complete
		)
	}

	static var fakeWithV3IdentityAlternativeLowerCase: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "rool", lastName: "paap", birthDateString: "1970-05-27"),
			status: .complete
		)
	}

	static var fakeWithV3IdentityAlternative2: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Henk", lastName: "Paap", birthDateString: "1970-05-27"),
			status: .complete
		)
	}

	static var fakeWithV3IdentityAlternative2LowerCase: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "henk", lastName: "paap", birthDateString: "1970-05-27"),
			status: .complete
		)
	}

	static var fakeWithV3IdentityFirstNameWithDiacritic: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Ådne", lastName: "Paap", birthDateString: "1970-05-27"),
			status: .complete
		)
	}

	static var fakeWithV3IdentityFirstNameWithDiacriticAlternative: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Ægir", lastName: "Paap", birthDateString: "1970-05-27"),
			status: .complete
		)
	}
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

extension EventFlow.Identity {

	static var fakeIdentity: EventFlow.Identity {
		EventFlow.Identity(
			infix: "",
			firstName: "Corona",
			lastName: "Check",
			birthDateString: "1980-05-16"
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
				sampleDateString: "2021-07-01T13:42:54Z",
				negativeResult: true,
				positiveResult: nil,
				facility: "GGD XL Factory",
				type: "LP217198-3",
				name: "Antigen Test",
				manufacturer: "1213",
				country: "NL"
			),
			positiveTest: nil,
			recovery: nil,
			dccEvent: nil,
			vaccinationAssessment: nil
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
				sampleDateString: "2021-07-01T15:49Z",
				negativeResult: nil,
				positiveResult: true,
				facility: "GGD XL Factory",
				type: "LP217198-3",
				name: "Antigen Test",
				manufacturer: "1213",
				country: "NL"
			),
			recovery: nil,
			dccEvent: nil,
			vaccinationAssessment: nil
		)
	}

	static var expiredPositiveTestEvent: EventFlow.Event {
		EventFlow.Event(
			type: "test",
			unique: "1234",
			isSpecimen: true,
			vaccination: nil,
			negativeTest: nil,
			positiveTest: EventFlow.TestEvent(
				sampleDateString: "2020-07-01T15:49Z",
				negativeResult: nil,
				positiveResult: true,
				facility: "GGD XL Factory",
				type: "LP217198-3",
				name: "Antigen Test",
				manufacturer: "1213",
				country: "NL"
			),
			recovery: nil,
			dccEvent: nil,
			vaccinationAssessment: nil
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
			vaccinationAssessment: nil
		)
	}

	static var vaccinationEventWithHPKCode: EventFlow.Event {
		EventFlow.Event(
			type: "vaccination",
			unique: "1234",
			isSpecimen: true,
			vaccination: EventFlow.VaccinationEvent(
				dateString: "2021-05-16",
				hpkCode: "1234",
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
			vaccinationAssessment: nil
		)
	}

	static var boosterEvent: EventFlow.Event {
		EventFlow.Event(
			type: "vaccination",
			unique: "1234",
			isSpecimen: true,
			vaccination: EventFlow.VaccinationEvent(
				dateString: "2022-01-08",
				hpkCode: nil,
				type: nil,
				manufacturer: "ORG-100030215",
				brand: "EU/1/20/1528",
				doseNumber: 3,
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
			vaccinationAssessment: nil
		)
	}

	static var recoveryEvent: EventFlow.Event {
		EventFlow.Event(
			type: "recovery",
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
			vaccinationAssessment: nil
		)
	}

	static var paperProofEvent: EventFlow.Event {
		EventFlow.Event(
			type: "vaccination",
			unique: "1234",
			isSpecimen: true,
			vaccination: nil,
			negativeTest: nil,
			positiveTest: nil,
			recovery: nil,
			dccEvent: EventFlow.DccEvent(
				credential: "test",
				couplingCode: "test"
			),
			vaccinationAssessment: nil
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
			vaccinationAssessment: EventFlow.VaccinationAssessment(
				dateTimeString: "2022-01-05T12:42:42Z",
				country: "NLD",
				verified: true
			)
		)
	}

	static var vaccinationAssessmentEventWithoutCountry: EventFlow.Event {
		EventFlow.Event(
			type: "vaccinationassessment",
			unique: "1234",
			isSpecimen: true,
			vaccination: nil,
			negativeTest: nil,
			positiveTest: nil,
			recovery: nil,
			dccEvent: nil,
			vaccinationAssessment: EventFlow.VaccinationAssessment(
				dateTimeString: "2022-01-05T12:42:42Z",
				country: nil,
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
extension RemoteGreenCards.Response {

	static var emptyResponse: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			euGreenCards: [],
			blobExpireDates: [],
			hints: nil
		)
	}

	static var domesticAndInternationalVaccination: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
//			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
//				origins: [
//					RemoteGreenCards.Origin.fakeVaccinationOrigin
//				],
//				createCredentialMessages: "test"
//			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeVaccinationOrigin
					],
					credential: "test credential"
				)
			],
			blobExpireDates: [],
			hints: nil
		)
	}

	static var domesticAndInternationalVaccinationWithHint: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
//			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
//				origins: [
//					RemoteGreenCards.Origin.fakeVaccinationOrigin
//				],
//				createCredentialMessages: "test"
//			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeVaccinationOrigin
					],
					credential: "test credential"
				)
			],
			blobExpireDates: [],
			hints: ["some_test_hint_key"]
		)
	}

	static var internationalVaccination: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
//			domesticGreenCard: nil,
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeVaccinationOrigin
					],
					credential: "test credential"
				)
			],
			blobExpireDates: [
				RemoteGreenCards.BlobExpiry(
					identifier: "12345",
					expirationDate: Formatter.getDateFrom(dateString8601: "2024-07-06:12:00:00+00:00")!,
					reason: ""
				)
			],
			hints: nil
		)
	}

	static func internationalBlockedVaccination(blockedIdentifier: String) -> RemoteGreenCards.Response {
		RemoteGreenCards.Response(
//			domesticGreenCard: nil,
			euGreenCards: [],
			blobExpireDates: [
				RemoteGreenCards.BlobExpiry(
					identifier: blockedIdentifier,
					expirationDate: Date.distantPast,
					reason: "event_blocked"
				)
			],
			hints: [
				"event_blocked",
				"domestic_vaccination_rejected",
				"international_vaccination_rejected"
			]
		)
	}

	static func internationalBlockedExistingVaccinationWhilstAddingVaccination(blockedIdentifierForExistingVaccination: String) -> RemoteGreenCards.Response {
		RemoteGreenCards.Response(
//			domesticGreenCard: nil,
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeVaccinationOrigin
					],
					credential: "test credential"
				)
			],
			blobExpireDates: [
				RemoteGreenCards.BlobExpiry(
					identifier: blockedIdentifierForExistingVaccination,
					expirationDate: Date.distantPast,
					reason: "event_blocked"
				)
			],
			hints: [
				"event_blocked",
				"domestic_vaccination_created",
				"international_vaccination_created"
			]
		)
	}

	static func internationalBlockedExistingVaccinationWhilstAddingVaccination(blockedIdentifierForExistingVaccination: String, blockedIdentifierForNewVaccination: String) -> RemoteGreenCards.Response {
		RemoteGreenCards.Response(
//			domesticGreenCard: nil,
			euGreenCards: [],
			blobExpireDates: [
				RemoteGreenCards.BlobExpiry(
					identifier: blockedIdentifierForExistingVaccination,
					expirationDate: Date.distantPast,
					reason: "event_blocked"
				),
				RemoteGreenCards.BlobExpiry(
					identifier: blockedIdentifierForNewVaccination,
					expirationDate: Date.distantPast,
					reason: "event_blocked"
				)
			],
			hints: [
				"event_blocked",
				"domestic_vaccination_rejected",
				"international_vaccination_rejected"
			]
		)
	}

	static var multipleDCC: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
//			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
//				origins: [
//					RemoteGreenCards.Origin.fakeVaccinationOrigin
//				],
//				createCredentialMessages: "test"
//			),
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
			],
			blobExpireDates: [],
			hints: nil
		)
	}
}

extension RemoteGreenCards.Origin {

	static var fakeVaccinationOrigin: RemoteGreenCards.Origin {
		RemoteGreenCards.Origin(
			type: "vaccination",
			eventTime: now,
			expirationTime: now.addingTimeInterval(300 * days),
			validFrom: now,
			doseNumber: 1,
			hints: ["fakeVaccinationOrigin"]
		)
	}

	static var fakeVaccinationOriginExpiringIn30Days: RemoteGreenCards.Origin {
		RemoteGreenCards.Origin(
			type: "vaccination",
			eventTime: now,
			expirationTime: now.addingTimeInterval(30 * days),
			validFrom: now,
			doseNumber: 1,
			hints: ["fakeVaccinationOriginExpiringIn30Days"]
		)
	}

	static var fakeRecoveryOriginExpiringIn30Days: RemoteGreenCards.Origin {
		RemoteGreenCards.Origin(
			type: "recovery",
			eventTime: now,
			expirationTime: now.addingTimeInterval(30 * days),
			validFrom: now,
			doseNumber: nil,
			hints: []
		)
	}
}
