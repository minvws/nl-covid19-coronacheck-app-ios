/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

internal class TokenValidatorSpy: TokenValidatorProtocol {

	var invokedValidate = false
	var invokedValidateCount = 0
	var invokedValidateParameters: (token: String, Void)?
	var invokedValidateParametersList = [(token: String, Void)]()
	var stubbedValidateResult: Bool! = false

	func validate(_ token: String) -> Bool {
		invokedValidate = true
		invokedValidateCount += 1
		invokedValidateParameters = (token, ())
		invokedValidateParametersList.append((token, ()))
		return stubbedValidateResult
	}
}
