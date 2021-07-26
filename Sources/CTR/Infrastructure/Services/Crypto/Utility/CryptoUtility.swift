/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
}
