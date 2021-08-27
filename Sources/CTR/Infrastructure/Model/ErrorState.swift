/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct ErrorCode: CustomStringConvertible {

	struct Flow {
		var value: String
	}

	struct Step {
		var value: String
	}

	struct ClientCode {
		var value: String
	}

	var flow: String
	var step: String
	var provider: String?
	var errorCode: String
	var detailedCode: Int?

	init(flow: Flow, step: Step, provider: String? = nil, errorCode: String, detailedCode: Int? = nil) {
		self.flow = flow.value
		self.step = step.value
		self.provider = provider
		self.errorCode = errorCode
		self.detailedCode = detailedCode
	}

	init(flow: Flow, step: Step, provider: String? = nil, clientCode: ClientCode, detailedCode: Int? = nil) {
		self.flow = flow.value
		self.step = step.value
		self.provider = provider
		self.errorCode = clientCode.value
		self.detailedCode = detailedCode
	}

	var description: String {
		// s/xyy/ppp/hhh/bbbbbb (system / flow.step / provider / errorcode / detailederrorcode)
		var result = "i \(flow)\(step)"
		result += " \(provider ?? "000")"
		result += " \(errorCode)"
		if let detailedCode = detailedCode {
			result += " \(detailedCode)"
		}
		return result
	}
}

// The values are documented in the coordination repo:
// https://github.com/minvws/nl-covid19-coronacheck-app-coordination/blob/main/docs/error-handling.md

// MARK: ErrorCode.Flow

extension ErrorCode.Flow {

	static let onboarding = ErrorCode.Flow(value: "0")
	static let commercialTest = ErrorCode.Flow(value: "1")
	static let vaccination = ErrorCode.Flow(value: "2")
	static let recovery = ErrorCode.Flow(value: "3")
	static let ggdTest = ErrorCode.Flow(value: "4")
	static let hkvi = ErrorCode.Flow(value: "5")
}

// MARK: ErrorCode.Step (Startup)

extension ErrorCode.Step {

	static let configuration = ErrorCode.Step(value: "10")
	static let publicKeys = ErrorCode.Step(value: "20")
}

// MARK: ErrorCode.Step (Common between test / vaccination flows)

extension ErrorCode.Step {

	static let providers = ErrorCode.Step(value: "20")
	static let storingEvents = ErrorCode.Step(value: "60")
	static let nonce = ErrorCode.Step(value: "70")
	static let signer = ErrorCode.Step(value: "80")
	static let storingCredentials = ErrorCode.Step(value: "90")
}

// MARK: ErrorCode.Step (Commercial Test)

extension ErrorCode.Step {

	static let testResult = ErrorCode.Step(value: "50")
}

// MARK: ErrorCode.Step (Vaccination / Recovery / GGD Test)

extension ErrorCode.Step {

	static let tvs = ErrorCode.Step(value: "10")
	static let accessTokens = ErrorCode.Step(value: "30")
	static let unomi = ErrorCode.Step(value: "40")
	static let event = ErrorCode.Step(value: "50")
}

// MARK: ErrorCode.Step (Paper flow)

extension ErrorCode.Step {

	static let coupling = ErrorCode.Step(value: "10")
}
