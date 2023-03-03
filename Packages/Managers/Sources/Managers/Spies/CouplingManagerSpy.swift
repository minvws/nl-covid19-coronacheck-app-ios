/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport

class CouplingManagerSpy: CouplingManaging {

	var invokedConvert = false
	var invokedConvertCount = 0
	var invokedConvertParameters: (dcc: String, couplingCode: String?)?
	var invokedConvertParametersList = [(dcc: String, couplingCode: String?)]()
	var stubbedConvertResult: EventFlow.EventResultWrapper!

	func convert(_ dcc: String, couplingCode: String?) -> EventFlow.EventResultWrapper? {
		invokedConvert = true
		invokedConvertCount += 1
		invokedConvertParameters = (dcc, couplingCode)
		invokedConvertParametersList.append((dcc, couplingCode))
		return stubbedConvertResult
	}

	var invokedCheckCouplingStatus = false
	var invokedCheckCouplingStatusCount = 0
	var invokedCheckCouplingStatusParameters: (dcc: String, couplingCode: String)?
	var invokedCheckCouplingStatusParametersList = [(dcc: String, couplingCode: String)]()
	var stubbedCheckCouplingStatusOnCompletionResult: (Result<DccCoupling.CouplingResponse, ServerError>, Void)?

	func checkCouplingStatus(
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
