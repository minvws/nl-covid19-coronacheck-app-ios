/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// @mockable
protocol SignatureValidating {

	/// Validate a PKCS7 signature
	/// - Parameters:
	///   - signature: the signature to validate
	///   - content: the signed content
	/// - Returns: True if the signature is a valid PKCS7 Signature
	func validate(signature: Data, content: Data) -> Bool
}

final class SignatureValidator: SignatureValidating, Logging {

	/// The open ssl wrapper
	private let openssl = OpenSSL()

	/// Validate a PKCS7 signature
	/// - Parameters:
	///   - signature: the signature to validate
	///   - content: the signed content
	/// - Returns: True if the signature is a valid PKCS7 Signature
	func validate(signature: Data, content: Data) -> Bool {

		guard let rootCertificateData = validatedRootCertificateData() else {
            logError("validatedRootCertificateData is invalid")
			return false
		}

		guard openssl.validatePKCS7Signature(
				signature,
				contentData: content,
				certificateData: rootCertificateData,
				authorityKeyIdentifier: SignatureConfiguration.authorityKeyIdentifier,
				requiredCommonNameContent: SignatureConfiguration.commonNameContent,
				requiredCommonNameSuffix: SignatureConfiguration.commonNameSuffix) else {
			logError("PKCS7Signature is invalid")
			return false
		}

		return true
	}

	/// Validate the root certificate
	/// - Returns: True if the root certificate is valid
	private func validatedRootCertificateData() -> Data? {

		guard let certificateData = SignatureConfiguration.rootCertificateData else {
            logError("rootCertificateData is invalid")
			return nil
		}
        
   	guard openssl.validateSerialNumber(
				SignatureConfiguration.rootSerial,
				forCertificateData: certificateData) else {
        logError("validateSerialNumber(rootSerial) is invalid")
			return nil
		}

   guard openssl.validateSubjectKeyIdentifier(
				SignatureConfiguration.rootSubjectKeyIdentifier,
				forCertificateData: certificateData) else {
            logError("validateSubjectKeyIdentifier(rootSubjectKeyIdentifier) failed")
			return nil
		}

		return certificateData
	}
}
