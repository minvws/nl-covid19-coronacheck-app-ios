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
			resultURLString: "",
			publicKey: "",
			certificate: ""
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

