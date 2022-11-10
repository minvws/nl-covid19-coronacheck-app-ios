/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Security
import Shared
import HTTPSecurity

public protocol SignatureValidationFactoryProtocol {
	
	func getSignatureValidator(_ strategy: SecurityStrategy) -> SignatureValidation
}

public struct SignatureValidationFactory: SignatureValidationFactoryProtocol {
	
	public init() {}
	public func getSignatureValidator(_ strategy: SecurityStrategy) -> SignatureValidation {
#if DEBUG
		if case SecurityStrategy.none = strategy {
			return AlwaysAllowSignatureValidator()
		}
#endif
		// Default for .config
		var trustedSigners = [TrustConfiguration.sdNEVRootCACertificate, TrustConfiguration.sdNRootCAG3Certificate, TrustConfiguration.sdNPrivateRootCertificate]
		
		if case SecurityStrategy.data = strategy {
			trustedSigners = []
		}
		
		if case let .provider(provider) = strategy {
			trustedSigners = []
			let helper = CMSCertificateHelper()
			for cmsCertificate in provider.getCMSCertificates() {
				if let commonName = helper.getCommonName(for: cmsCertificate),
				   let authKey = helper.getAuthorityKeyIdentifier(for: cmsCertificate) {
					for trustedCert in [TrustConfiguration.sdNEVRootCACertificate, TrustConfiguration.sdNRootCAG3Certificate, TrustConfiguration.sdNPrivateRootCertificate] {
						var copy = trustedCert
						copy.authorityKeyIdentifier = authKey
						copy.commonName = commonName
						trustedSigners.append(copy)
					}
				}
			}
		}
		return CMSSignatureValidator( trustedSigners: trustedSigners)
	}
}
