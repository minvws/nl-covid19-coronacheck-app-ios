/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class SmokeEncoding: BaseTest {
	
	func test_encodingLatinDiacritic() {
		addVaccinationCertificate(for: TestData.encodingLatinDiacritic)
		addRetrievedCertificateToApp(for: TestData.encodingLatinDiacritic)
	}
}
