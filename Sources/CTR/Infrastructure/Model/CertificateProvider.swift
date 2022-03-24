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
	
	func getCMSCertificates() -> [Data]
}

extension CertificateProvider {
	
	func getTLSCertificates() -> [Data] {
		
		return convertCertificates(tlsCertificates)
	}
	
	func getCMSCertificates() -> [Data] {
		
		return convertCertificates(cmsCertificates)
	}
	
	fileprivate func convertCertificates(_ certificates: [String]) -> [Data] {
		
		var result = [Data]()
		certificates.forEach { certificate in
			if let decoded = certificate.base64Decoded() {
				result.append(Data(decoded.utf8))
			}
		}
		return result
	}
}