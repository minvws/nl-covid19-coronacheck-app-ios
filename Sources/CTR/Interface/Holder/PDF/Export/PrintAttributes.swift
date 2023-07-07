/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation

struct PrintAttributes: Codable {
	
	public let european: [EUPrintAttributes]
	
	public enum CodingKeys: String, CodingKey {
		
		case european
	}
	
	init(european: [EUPrintAttributes]) {
		self.european = european
	}
}

struct EUPrintAttributes: Codable {
	
	public let digitalCovidCertificate: EuCredentialAttributes.DigitalCovidCertificate
	public let expirationTime: Date
	public let qr: String
	
	public enum CodingKeys: String, CodingKey {
		
		case digitalCovidCertificate = "dcc"
		case expirationTime
		case qr
	}
	
	init(digitalCovidCertificate: EuCredentialAttributes.DigitalCovidCertificate, expirationTime: Date, qr: String) {
		
		self.digitalCovidCertificate = digitalCovidCertificate
		self.expirationTime = expirationTime
		self.qr = qr
	}
}
