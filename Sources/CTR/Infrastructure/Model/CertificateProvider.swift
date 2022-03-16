/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Security

protocol CertificateProvider {
	
	/// The public key of the provider
	var cmsCertificates: [String] { get }
	
	/// The ssl certificate of the provider
	var tlsCertificates: [String] { get }

	func getHostNames() -> [String]
	
	func getTLSCertificates() -> [Data]
	
	func getCMSCertificates() -> [SigningCertificate]
}

extension CertificateProvider {
	
	func getTLSCertificates() -> [Data] {
		
		var result = [Data]()
		tlsCertificates.forEach { tlsCertificate in
			if let decoded = tlsCertificate.base64Decoded() {
				result.append(Data(decoded.utf8))
			}
		}
		return result
	}
	
	func getCMSCertificates() -> [SigningCertificate] {
		
		var result = [SigningCertificate]()
		cmsCertificates.forEach { tlsCertificate in
			if let decoded = tlsCertificate.base64Decoded() {
				result.append(
					SigningCertificate(
						name: "TestProvider",
						certificate: decoded,
						commonName: nil,
						authorityKeyIdentifier: nil,
						subjectKeyIdentifier: nil,
						rootSerial: nil
					)
				)
			}
		}
		return result
	}
}
