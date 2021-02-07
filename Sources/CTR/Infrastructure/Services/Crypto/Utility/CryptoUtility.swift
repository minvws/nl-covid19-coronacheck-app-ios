/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CommonCrypto
import Foundation
import Security

/// @mockable
protocol CryptoUtilityProtocol {

	/// Validate a PKCS7 Signature
	/// - Parameters:
	///   - data: the signed content
	///   - signature: the PKCS7 Signature
	///   - completion: Completion handler
    func validate(data: Data, signature: Data, completion: @escaping (Bool) -> Void)

	/// Create a signature
	/// - Parameters:
	///   - data: the content
	///   - key: the key to sign with
	/// - Returns: the signature
	func signature(forData data: Data, key: Data) -> Data

	/// Create a sha256 string of data
	/// - Parameter data: the data to sha526
	/// - Returns: a sha256 string of data
	func sha256(data: Data) -> String?
}

/// Crypto Utility for validating and generating signatures
/// This is all work in progress as there are currently no
/// test samples available to validate the implementation
///
final class CryptoUtility: CryptoUtilityProtocol {

	// MARK: - Private

	/// The signature validator
	private let signatureValidator: SignatureValidating

	// MARK: - Initializer

	/// Initializer
	/// - Parameter signatureValidator: the validator
    init(signatureValidator: SignatureValidating) {

        self.signatureValidator = signatureValidator
    }

    // MARK: - CryptoUtilityProtocol

	/// Validate a PKCS7 Signature
	/// - Parameters:
	///   - data: the signed content
	///   - signature: the PKCS7 Signature
	///   - completion: Completion handler
    func validate(data: Data, signature: Data, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            let result = self.signatureValidator.validate(signature: signature, content: data)

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

	/// Create a signature
	/// - Parameters:
	///   - data: the content
	///   - key: the key to sign with
	/// - Returns: the signature
    func signature(forData data: Data, key: Data) -> Data {

        var digest = [CUnsignedChar](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        key.withUnsafeBytes { keyPtr in
            data.withUnsafeBytes { dataPtr in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyPtr.baseAddress, key.count, dataPtr.baseAddress, data.count, &digest)
            }
        }

        return Data(digest)
    }

	/// Create a sha256 string of data
	/// - Parameter data: the data to sha526
	/// - Returns: a sha256 string of data
    func sha256(data: Data) -> String? {

        let digest = data.sha256
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return "SHA256 digest: \(hexBytes.joined())"
    }
}
