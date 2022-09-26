/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import Transport

class SignatureValidationFactorySpy: SignatureValidationFactoryProtocol {

	var invokedGetSignatureValidator = false
	var invokedGetSignatureValidatorCount = 0
	var invokedGetSignatureValidatorParameters: (strategy: SecurityStrategy, Void)?
	var invokedGetSignatureValidatorParametersList = [(strategy: SecurityStrategy, Void)]()
	var stubbedGetSignatureValidatorResult: SignatureValidation!

	func getSignatureValidator(_ strategy: SecurityStrategy) -> SignatureValidation {
		invokedGetSignatureValidator = true
		invokedGetSignatureValidatorCount += 1
		invokedGetSignatureValidatorParameters = (strategy, ())
		invokedGetSignatureValidatorParametersList.append((strategy, ()))
		return stubbedGetSignatureValidatorResult
	}
}
