/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable file_length

import Foundation
@testable import CTR
import UIKit

extension NewFeatureConsent {

    static var consentWithoutMandatoryConsent = NewFeatureConsent(
        title: "test title without mandatory consent",
        highlight: "test highlight without mandatory consent",
        content: "test content without mandatory consent",
        consentMandatory: false
    )

    static var consentWithMandatoryConsent = NewFeatureConsent(
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
			usages: [.vaccination]
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
			usages: [.positiveTest]
		)
	}

	static var recoveryProvider: EventFlow.EventProvider {
		EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiUrl: URL(string: "https://coronacheck.nl"),
			eventUrl: URL(string: "https://coronacheck.nl"),
			cmsCertificates: [],
			tlsCertificates: [],
			accessToken: nil,
			eventInformationAvailable: nil,
			usages: [.recovery]
		)
	}

	static var negativeTestProvider: EventFlow.EventProvider {
		EventFlow.EventProvider(
			identifier: "CC",
			name: "CoronaCheck",
			unomiUrl: URL(string: "https://coronacheck.nl"),
			eventUrl: URL(string: "https://coronacheck.nl"),
			cmsCertificates: [],
			tlsCertificates: [],
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
	
	static var fakePendingV2: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "2.0",
			identity: nil,
			status: .pending,
			result: nil
		)
	}

	static var fakeBlocked: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "",
			protocolVersion: "",
			identity: nil,
			status: .blocked,
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
	
	static var fakeBoosterResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		result: nil,
		events: [EventFlow.Event.boosterEvent]
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
	
	static var fakeExpiredPositiveTestResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		result: nil,
		events: [EventFlow.Event.expiredPositiveTestEvent]
	)

	static var fakeNegativeTestResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		result: nil,
		events: [EventFlow.Event.negativeTestEvent]
	)
	
	static var fakePaperProofResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		result: nil,
		events: [EventFlow.Event.paperProofEvent]
	)
	
	static var fakeVaccinationAssessmentResultWrapper = EventFlow.EventResultWrapper(
		providerIdentifier: "CC",
		protocolVersion: "3.0",
		identity: EventFlow.Identity.fakeIdentity,
		status: .complete,
		result: nil,
		events: [EventFlow.Event.vaccinationAssessmentEvent]
	)
	
	static var fakeWithV3Identity: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Test", lastName: "de Tester", birthDateString: "1990-12-12"),
			status: .complete,
			result: nil
		)
	}
	
	static var fakeWithV3IdentityAlternative: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Rool", lastName: "Paap", birthDateString: "1970-05-27"),
			status: .complete,
			result: nil
		)
	}
	
	static var fakeWithV3IdentityAlternativeLowerCase: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "rool", lastName: "paap", birthDateString: "1970-05-27"),
			status: .complete,
			result: nil
		)
	}
	
	static var fakeWithV3IdentityAlternative2: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Henk", lastName: "Paap", birthDateString: "1970-05-27"),
			status: .complete,
			result: nil
		)
	}
	
	static var fakeWithV3IdentityAlternative2LowerCase: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "henk", lastName: "paap", birthDateString: "1970-05-27"),
			status: .complete,
			result: nil
		)
	}
	
	static var fakeWithV3IdentityFirstNameWithDiacritic: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Ådne", lastName: "Paap", birthDateString: "1970-05-27"),
			status: .complete,
			result: nil
		)
	}
	
	static var fakeWithV3IdentityFirstNameWithDiacriticAlternative: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "3,0",
			identity: EventFlow.Identity(infix: nil, firstName: "Ægir", lastName: "Paap", birthDateString: "1970-05-27"),
			status: .complete,
			result: nil
		)
	}
	
	static var fakeWithV2Identity: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "2.0",
			identity: nil,
			status: .complete,
			result: TestResult(
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
		)
	}
	
	static var fakeWithV2IdentityAlternative: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "2.0",
			identity: nil,
			status: .complete,
			result: TestResult(
				unique: "test",
				sampleDate: "2021-01-01T12:00:00",
				testType: "PCR",
				negativeResult: true,
				holder: TestHolderIdentity(
					firstNameInitial: "H",
					lastNameInitial: "P",
					birthDay: "27",
					birthMonth: "5"
				)
			)
		)
	}
	
	static var fakeWithV2IdentityAlternativeLowerCase: EventFlow.EventResultWrapper {
		EventFlow.EventResultWrapper(
			providerIdentifier: "CoronaCheck",
			protocolVersion: "2.0",
			identity: nil,
			status: .complete,
			result: TestResult(
				unique: "test",
				sampleDate: "2021-01-01T12:00:00",
				testType: "PCR",
				negativeResult: true,
				holder: TestHolderIdentity(
					firstNameInitial: "h",
					lastNameInitial: "p",
					birthDay: "27",
					birthMonth: "5"
				)
			)
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
	
	static func sampleWithRecovery() -> EuCredentialAttributes.DigitalCovidCertificate {
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
					country: "NL",
					diseaseAgentTargeted: "840539006",
					expiresAt: "2022-07-31T09:50:00+00:00",
					firstPositiveTestDate: "2021-07-31T09:50:00+00:00",
					issuer: "test",
					validFrom: "2021-08-11T09:50:00+00:00"
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
	
	static var fakeRecoveryOriginExpiringIn30DaysEvent30DaysAgo: RemoteGreenCards.Origin {
		RemoteGreenCards.Origin(
			type: "recovery",
			eventTime: Date().addingTimeInterval(30 * days * ago),
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
	
	static var fakeTesttOriginExpiringIn1Day: RemoteGreenCards.Origin {
		RemoteGreenCards.Origin(
			type: "test",
			eventTime: Date(),
			expirationTime: Date().addingTimeInterval(1 * days),
			validFrom: Date(),
			doseNumber: nil
		)
	}
}

extension RemoteGreenCards.Response {
	
	static var emptyResponse: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: nil,
			euGreenCards: []
		)
	}

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
	
	static var internationalVaccination: RemoteGreenCards.Response {
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
	
	static var domesticAndInternationalVaccinationAndRecoveryBeforeVaccination: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeVaccinationOriginExpiringIn30Days,
					RemoteGreenCards.Origin.fakeRecoveryOriginExpiringIn30DaysEvent30DaysAgo
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
						RemoteGreenCards.Origin.fakeRecoveryOriginExpiringIn30DaysEvent30DaysAgo
					],
					credential: "test credential"
				)
			]
		)
	}
	
	static var internationalVaccinationAndRecovery: RemoteGreenCards.Response {
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
	
	static var domesticAndInternationalVaccinationAndDomesticRecovery: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeVaccinationOriginExpiringIn30Days,
					RemoteGreenCards.Origin.fakeRecoveryOriginExpiringIn30DaysEvent30DaysAgo
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeVaccinationOriginExpiringIn30Days
					],
					credential: "test credential"
				)
			]
		)
	}
	
	static var internationalRecovery: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: nil,
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
	
	static var domesticRecovery: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeRecoveryOriginExpiringIn30Days
				],
				createCredentialMessages: "test"
			),
			euGreenCards: []
		)
	}
	
	static var domesticVaccinationAssessment: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeVaccinationAssessmentOriginExpiringIn14Days
				],
				createCredentialMessages: "test"
			),
			euGreenCards: []
		)
	}
	
	static var domesticVaccinationAssessmentAndNegativeTest: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeVaccinationAssessmentOriginExpiringIn14Days,
					RemoteGreenCards.Origin.fakeTesttOriginExpiringIn1Day
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeTesttOriginExpiringIn1Day
					],
					credential: "test credential"
				)
			]
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
	
	static var domesticAndInternationalTest: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeTesttOriginExpiringIn1Day
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin.fakeTesttOriginExpiringIn1Day
					],
					credential: "test credential"
				)
			]
		)
	}
	
	static var domesticlTestV2: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin.fakeTesttOriginExpiringIn1Day
				],
				createCredentialMessages: "test"
			),
			euGreenCards: []
		)
	}

	static var domesticAndInternationalExpiredRecovery: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin(
						type: "recovery",
						eventTime: Date().addingTimeInterval(400 * days * ago),
						expirationTime: Date().addingTimeInterval(300 * days * ago),
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
						eventTime: Current.now().addingTimeInterval(400 * days * ago),
						expirationTime: Current.now().addingTimeInterval(30 * days * ago),
						validFrom: Current.now().addingTimeInterval(400 * days * ago),
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
					credential: "vaccination credential"
				),
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin(
							type: "recovery",
							eventTime: Current.now().addingTimeInterval(400 * days * ago),
							expirationTime: Current.now().addingTimeInterval(30 * days * ago),
							validFrom: Current.now().addingTimeInterval(400 * days * ago),
							doseNumber: nil
						)
					],
					credential: "recovery credential"
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
	
	static var fakeVaccinationAssessmentGreenCardExpiresIn14Days: RemoteGreenCards.DomesticGreenCard {
		RemoteGreenCards.DomesticGreenCard(
			origins: [
				RemoteGreenCards.Origin.fakeVaccinationAssessmentOriginExpiringIn14Days
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
				sampleDateString: "2021-07-01T13:42:54Z",
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
				manufacturer: "1213"
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
				manufacturer: "1213"
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

extension EventGroup {
	
	static func fakeEventGroup(dataStoreManager: DataStoreManaging, type: EventMode, maxIssuedAt: Date) -> EventGroup? {
		
		var eventGroup: EventGroup?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.createTestWallet(managedContext: context) {
				eventGroup = EventGroupModel.create(
					type: type,
					providerIdentifier: "CoronaCheck",
					maxIssuedAt: maxIssuedAt,
					jsonData: Data(),
					wallet: wallet,
					managedContext: context
				)
			}
		}
		return eventGroup
	}
}

// Can't extend RemoteEvent, so this struct will have to do.
struct FakeRemoteEvent {
	
	static var fakeRemoteEventNegativeTestV2: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeWithV2Identity,
			signedResponse: SignedResponse.fakeResponse
		)
	}
	
	static var fakeRemoteEventPendingV2: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakePendingV2,
			signedResponse: SignedResponse.fakeResponse
		)
	}
	
	static var fakeRemoteEventVaccination: RemoteEvent {
		RemoteEvent(
			wrapper: EventFlow.EventResultWrapper.fakeVaccinationResultWrapper,
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
