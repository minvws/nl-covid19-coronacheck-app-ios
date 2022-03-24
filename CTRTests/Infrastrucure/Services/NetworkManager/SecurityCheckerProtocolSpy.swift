/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import CTR

class SecurityCheckerProtocolSpy: SecurityCheckerProtocol {

	var invokedCheckSSL = false
	var invokedCheckSSLCount = 0

	func checkSSL() {
		invokedCheckSSL = true
		invokedCheckSSLCount += 1
	}

	var invokedValidate = false
	var invokedValidateCount = 0
	var invokedValidateParameters: (signature: Data, content: Data)?
	var invokedValidateParametersList = [(signature: Data, content: Data)]()
	var stubbedValidateResult: Bool! = false

	func validate(signature: Data, content: Data) -> Bool {
		invokedValidate = true
		invokedValidateCount += 1
		invokedValidateParameters = (signature, content)
		invokedValidateParametersList.append((signature, content))
		return stubbedValidateResult
	}
}
