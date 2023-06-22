/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import Transport

class CertificateProviderSpy: CertificateProvider {

	var invokedCmsCertificatesGetter = false
	var invokedCmsCertificatesGetterCount = 0
	var stubbedCmsCertificates: [String]! = []

	var cmsCertificates: [String] {
		invokedCmsCertificatesGetter = true
		invokedCmsCertificatesGetterCount += 1
		return stubbedCmsCertificates
	}

	var invokedTlsCertificatesGetter = false
	var invokedTlsCertificatesGetterCount = 0
	var stubbedTlsCertificates: [String]! = []

	var tlsCertificates: [String] {
		invokedTlsCertificatesGetter = true
		invokedTlsCertificatesGetterCount += 1
		return stubbedTlsCertificates
	}

	var invokedGetTLSCertificates = false
	var invokedGetTLSCertificatesCount = 0
	var stubbedGetTLSCertificatesResult: [Data]! = []

	func getTLSCertificates() -> [Data] {
		invokedGetTLSCertificates = true
		invokedGetTLSCertificatesCount += 1
		return stubbedGetTLSCertificatesResult
	}

	var invokedGetCMSCertificates = false
	var invokedGetCMSCertificatesCount = 0
	var stubbedGetCMSCertificatesResult: [Data]! = []

	func getCMSCertificates() -> [Data] {
		invokedGetCMSCertificates = true
		invokedGetCMSCertificatesCount += 1
		return stubbedGetCMSCertificatesResult
	}
}
