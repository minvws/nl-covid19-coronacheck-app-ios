/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

enum CertificateType: String {
	case vaccination = "Vaccinatiebewijs"
	case recovery = "Herstelbewijs"
	case test = "Testbewijs"
}

enum TestCertificateType: String {
	case pcr = "PCR (NAAT)"
	case rat = "Sneltest (RAT)"
}
