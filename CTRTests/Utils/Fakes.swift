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
					country: "NLS",
					diseaseAgentTargeted: "test",
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

extension RemoteGreenCards.Response {

	static var domesticAndInternationalVaccination: RemoteGreenCards.Response {
		RemoteGreenCards.Response(
			domesticGreenCard: RemoteGreenCards.DomesticGreenCard(
				origins: [
					RemoteGreenCards.Origin(
						type: "vaccination",
						eventTime: Date(),
						expirationTime: Date(),
						validFrom: Date(),
						doseNumber: 1
					)
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin(
							type: "vaccination",
							eventTime: Date(),
							expirationTime: Date(),
							validFrom: Date(),
							doseNumber: nil
						)
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
						RemoteGreenCards.Origin(
							type: "vaccination",
							eventTime: Date(),
							expirationTime: Date(),
							validFrom: Date(),
							doseNumber: nil
						)
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
					RemoteGreenCards.Origin(
						type: "vaccination",
						eventTime: Date(),
						expirationTime: Date(),
						validFrom: Date(),
						doseNumber: 2
					)
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin(
							type: "vaccination",
							eventTime: Date(),
							expirationTime: Date(),
							validFrom: Date(),
							doseNumber: nil
						)
					],
					credential: "test credential1"
				),
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin(
							type: "vaccination",
							eventTime: Date(),
							expirationTime: Date(),
							validFrom: Date(),
							doseNumber: nil
						)
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
					RemoteGreenCards.Origin(
						type: "vaccination",
						eventTime: Date(),
						expirationTime: Date().addingTimeInterval(30 * days),
						validFrom: Date(),
						doseNumber: 1
					),
					RemoteGreenCards.Origin(
						type: "recovery",
						eventTime: Date(),
						expirationTime: Date().addingTimeInterval(30 * days),
						validFrom: Date(),
						doseNumber: nil
					)
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin(
							type: "vaccination",
							eventTime: Date(),
							expirationTime: Date().addingTimeInterval(30 * days),
							validFrom: Date(),
							doseNumber: nil
						)
					],
					credential: "test credential"
				),
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin(
							type: "recovery",
							eventTime: Date(),
							expirationTime: Date().addingTimeInterval(30 * days),
							validFrom: Date(),
							doseNumber: nil
						)
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
					RemoteGreenCards.Origin(
						type: "recovery",
						eventTime: Date(),
						expirationTime: Date().addingTimeInterval(30 * days),
						validFrom: Date(),
						doseNumber: nil
					)
				],
				createCredentialMessages: "test"
			),
			euGreenCards: [
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin(
							type: "recovery",
							eventTime: Date(),
							expirationTime: Date().addingTimeInterval(30 * days),
							validFrom: Date(),
							doseNumber: nil
						)
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
						RemoteGreenCards.Origin(
							type: "recovery",
							eventTime: Date(),
							expirationTime: Date().addingTimeInterval(30 * days),
							validFrom: Date(),
							doseNumber: nil
						)
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
					RemoteGreenCards.Origin(
						type: "vaccination",
						eventTime: Date(),
						expirationTime: Date().addingTimeInterval(30 * days),
						validFrom: Date(),
						doseNumber: 1
					),
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
						RemoteGreenCards.Origin(
							type: "vaccination",
							eventTime: Date(),
							expirationTime: Date().addingTimeInterval(30 * days),
							validFrom: Date(),
							doseNumber: nil
						)
					],
					credential: "test credential"
				),
				RemoteGreenCards.EuGreenCard(
					origins: [
						RemoteGreenCards.Origin(
							type: "recovery",
							eventTime: Date(),
							expirationTime: Date().addingTimeInterval(30 * days),
							validFrom: Date(),
							doseNumber: nil
						)
					],
					credential: "test credential"
				)
			]
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
