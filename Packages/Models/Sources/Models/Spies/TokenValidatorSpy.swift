/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public class TokenValidatorSpy: TokenValidatorProtocol {

	public init() {}
	
	public var invokedValidate = false
	public var invokedValidateCount = 0
	public var invokedValidateParameters: (token: String, Void)?
	public var invokedValidateParametersList = [(token: String, Void)]()
	public var stubbedValidateResult: Bool! = false

	public func validate(_ token: String) -> Bool {
		invokedValidate = true
		invokedValidateCount += 1
		invokedValidateParameters = (token, ())
		invokedValidateParametersList.append((token, ()))
		return stubbedValidateResult
	}
}
