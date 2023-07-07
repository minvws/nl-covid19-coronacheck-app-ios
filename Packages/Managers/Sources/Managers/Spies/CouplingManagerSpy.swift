/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport

public class CouplingManagerSpy: CouplingManaging {
	
	public init() {}

	public var invokedConvert = false
	public var invokedConvertCount = 0
	public var invokedConvertParameters: (dcc: String, couplingCode: String?)?
	public var invokedConvertParametersList = [(dcc: String, couplingCode: String?)]()
	public var stubbedConvertResult: EventFlow.EventResultWrapper!

	public func convert(_ dcc: String, couplingCode: String?) -> EventFlow.EventResultWrapper? {
		invokedConvert = true
		invokedConvertCount += 1
		invokedConvertParameters = (dcc, couplingCode)
		invokedConvertParametersList.append((dcc, couplingCode))
		return stubbedConvertResult
	}

	public var invokedCheckCouplingStatus = false
	public var invokedCheckCouplingStatusCount = 0
	public var invokedCheckCouplingStatusParameters: (dcc: String, couplingCode: String)?
	public var invokedCheckCouplingStatusParametersList = [(dcc: String, couplingCode: String)]()
	public var stubbedCheckCouplingStatusOnCompletionResult: (Result<DccCoupling.CouplingResponse, ServerError>, Void)?

	public func checkCouplingStatus(
		dcc: String,
		couplingCode: String,
		onCompletion: @escaping (Result<DccCoupling.CouplingResponse, ServerError>) -> Void) {
		invokedCheckCouplingStatus = true
		invokedCheckCouplingStatusCount += 1
		invokedCheckCouplingStatusParameters = (dcc, couplingCode)
		invokedCheckCouplingStatusParametersList.append((dcc, couplingCode))
		if let result = stubbedCheckCouplingStatusOnCompletionResult {
			onCompletion(result.0)
		}
	}
}
