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

enum EventType: String {
	case vaccination = "Vaccinatie"
	case positive = "Positieve testuitslag"
	case negative = "Negatieve testuitslag"
}

enum TestCertificateType: String {
	case pcr = "PCR (NAAT)"
	case rat = "Sneltest (RAT)"
}

enum DisclosureMode: String {
	case mode0G = "-disclosurePolicyMode0G"
	case mode3G = "-disclosurePolicyMode3G"
	case mode1G = "-disclosurePolicyMode1G"
	case mode1GWith3G = "-disclosurePolicyMode1GWith3G"
}
