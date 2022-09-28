/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Security
import OpenSSL
import Shared

public protocol SignatureValidationFactoryProtocol {
	
	func getSignatureValidator(_ strategy: SecurityStrategy) -> SignatureValidation
}

public struct SignatureValidationFactory: SignatureValidationFactoryProtocol {
	
	public init() {}
	public func getSignatureValidator(_ strategy: SecurityStrategy) -> SignatureValidation {
#if DEBUG
		if case SecurityStrategy.none = strategy {
			return SignatureValidatorAlwaysAllow()
		}
#endif
		// Default for .config
		var trustedSigners = [TrustConfiguration.sdNEVRootCACertificate, TrustConfiguration.sdNRootCAG3Certificate, TrustConfiguration.sdNPrivateRootCertificate]
		
		if case SecurityStrategy.data = strategy {
			trustedSigners = []
		}
		
		if case let .provider(provider) = strategy {
			trustedSigners = []
			let openSSL = OpenSSL()
			for cmsCertificate in provider.getCMSCertificates() {
				if let commonName = openSSL.getCommonName(forCertificate: cmsCertificate),
				   let authKey = openSSL.getAuthorityKeyIdentifier(forCertificate: cmsCertificate) {
					for trustedCert in [TrustConfiguration.sdNEVRootCACertificate, TrustConfiguration.sdNRootCAG3Certificate, TrustConfiguration.sdNPrivateRootCertificate] {
						var copy = trustedCert
						copy.authorityKeyIdentifier = authKey
						copy.commonName = commonName
						trustedSigners.append(copy)
					}
				}
			}
		}
		return SignatureValidator( trustedSigners: trustedSigners)
	}
}

public protocol SignatureValidation {
	
	/// Validate a PKCS7 signature
	/// - Parameters:
	///   - signature: the signature to validate
	///   - content: the signed content
	/// - Returns: True if the signature is a valid PKCS7 Signature
	func validate(signature: Data, content: Data) -> Bool
}

extension SignatureValidation {
	
	/// Validate a PKCS7 Signature
	/// - Parameters:
	///   - data: the signed content
	///   - signature: the PKCS7 Signature
	///   - completion: Completion handler
	func validate(data: Data, signature: Data, completion: @escaping (Bool) -> Void) {
		DispatchQueue.global().async {
			let result = validate(signature: signature, content: data)
			
			DispatchQueue.main.async {
				completion(result)
			}
		}
	}
}

#if DEBUG
/// Check nothing. Allow every connection. Used for testing.
class SignatureValidatorAlwaysAllow: SignatureValidator {
	
	/// Validate a PKCS7 signature
	/// - Parameters:
	///   - signature: the signature to validate
	///   - content: the signed content
	/// - Returns: True if the signature is a valid PKCS7 Signature
	override func validate(signature: Data, content: Data) -> Bool {
		
		return true
	}
}
#endif

/// Security check for backend communication
class SignatureValidator: SignatureValidation {
	
	var trustedSigners: [SigningCertificate]
	let openssl = OpenSSL()
	
	init(trustedSigners: [SigningCertificate] = []) {
		
		self.trustedSigners = trustedSigners
	}
	
	/// Validate a PKCS7 signature
	/// - Parameters:
	///   - signature: the signature to validate
	///   - content: the signed content
	/// - Returns: True if the signature is a valid PKCS7 Signature
	func validate(signature: Data, content: Data) -> Bool {
		
		for signer in trustedSigners {
			
			let certificateData = signer.getCertificateData()
			
			if let subjectKeyIdentifier = signer.subjectKeyIdentifier,
			   !openssl.validateSubjectKeyIdentifier(subjectKeyIdentifier, forCertificateData: certificateData) {
				logError("validateSubjectKeyIdentifier(subjectKeyIdentifier) failed")
				return false
			}
			
			if let serial = signer.rootSerial,
			   !openssl.validateSerialNumber( serial, forCertificateData: certificateData) {
				logError("validateSerialNumber(serial) is invalid")
				return false
			}
			
			if openssl.validatePKCS7Signature(
				signature,
				contentData: content,
				certificateData: certificateData,
				authorityKeyIdentifier: signer.authorityKeyIdentifier,
				requiredCommonNameContent: signer.commonName ?? "") {
				return true
			}
		}
		return false
	}
}
