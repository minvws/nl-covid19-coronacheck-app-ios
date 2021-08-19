/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct ErrorCode: CustomStringConvertible {

	struct Flow: RawRepresentable {
		var rawValue: String
		static let unknown = Flow(rawValue: "-")
	}

	struct Step: RawRepresentable {
		var rawValue: String
		static let unknown = Step(rawValue: "--")
	}

	var flow: String
	var step: String
	var provider: String?
	var errorCode: String
	var detailedCode: Int?

	init(flow: Flow, step: Step, provider: String? = nil, errorCode: String, detailedCode: Int? = nil) {
		self.flow = flow.rawValue
		self.step = step.rawValue
		self.provider = provider
		self.errorCode = errorCode
		self.detailedCode = detailedCode
	}

	var description: String {
		// s/xyy/ppp/hhh/bbbbbb (flow.step / provider / errorcode / detailederrorcode)
		var result = "i/\(flow)\(step)/\(provider ?? "000")/\(errorCode)"
		if let detailedCode = detailedCode {
			result += "/\(detailedCode)"
		}
		return result
	}
}

// The values are documented in the coordination repo:
// https://github.com/minvws/nl-covid19-coronacheck-app-coordination/blob/main/docs/error-handling.md

// MARK: ErrorCode.Flow

extension ErrorCode.Flow {

	static let onboarding = ErrorCode.Flow(rawValue: "0")
	static let commercialTest = ErrorCode.Flow(rawValue: "1")
	static let vaccination = ErrorCode.Flow(rawValue: "2")
	static let recovery = ErrorCode.Flow(rawValue: "3")
	static let ggdTest = ErrorCode.Flow(rawValue: "4")
	static let hkvi = ErrorCode.Flow(rawValue: "5")
}

// MARK: ErrorCode.Step (Startup)

extension ErrorCode.Step {

	static let configuration = ErrorCode.Step(rawValue: "10")
	static let publicKeys = ErrorCode.Step(rawValue: "20")
}

// MARK: ErrorCode.Step (Common between test / vaccination flows)

extension ErrorCode.Step {

	static let providers = ErrorCode.Step(rawValue: "20")
	static let storingEvents = ErrorCode.Step(rawValue: "60")
	static let nonce = ErrorCode.Step(rawValue: "70")
	static let signer = ErrorCode.Step(rawValue: "80")
	static let storingCredentials = ErrorCode.Step(rawValue: "90")
}

// MARK: ErrorCode.Step (Commercial Test)

extension ErrorCode.Step {

	static let testResult = ErrorCode.Step(rawValue: "50")
}

// MARK: ErrorCode.Step (Vaccination / Recovery / GGD Test)

extension ErrorCode.Step {

	static let tvs = ErrorCode.Step(rawValue: "10")
	static let accessTokens = ErrorCode.Step(rawValue: "30")
	static let unomi = ErrorCode.Step(rawValue: "40")
	static let event = ErrorCode.Step(rawValue: "50")
}

// MARK: ErrorCode.Step (Paper flow)

extension ErrorCode.Step {

	static let coupling = ErrorCode.Step(rawValue: "10")
}
