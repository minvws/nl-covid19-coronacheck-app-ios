//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

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
        TestProvider(identifier: "xxx", name: "Fake Test Provider", resultURL: nil, publicKey: "", certificate: "")
    }
}

extension TestResultWrapper {

    static var fakeComplete: TestResultWrapper {
        TestResultWrapper(providerIdentifier: "", protocolVersion: "", result: nil, status: .complete)
    }

    static var fakePending: TestResultWrapper {
        TestResultWrapper(providerIdentifier: "", protocolVersion: "", result: nil, status: .pending)
    }

    static var fakeVerificationRequired: TestResultWrapper {
        TestResultWrapper(providerIdentifier: "", protocolVersion: "", result: nil, status: .verificationRequired)
    }

    static var fakeInvalid: TestResultWrapper {
        TestResultWrapper(providerIdentifier: "", protocolVersion: "", result: nil, status: .invalid)
    }

    static var fakeUnknown: TestResultWrapper {
        TestResultWrapper(providerIdentifier: "", protocolVersion: "", result: nil, status: .unknown)
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
