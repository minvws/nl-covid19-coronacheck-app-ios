/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public struct ErrorCode: CustomStringConvertible {

	public struct Flow {
		public init(value: String) {
			self.value = value
		}
		
		var value: String
	}

	public struct Step {
		public init(value: String) {
			self.value = value
		}
		
		var value: String
	}

	public struct ClientCode: Equatable {
		public init(value: String) {
			self.value = value
		}
		
		var value: String
	}

	public var flow: String
	public var step: String
	public var provider: String?
	public var errorCode: String
	public var detailedCode: Int?

	public init(flow: Flow, step: Step, provider: String? = nil, errorCode: String, detailedCode: Int? = nil) {
		self.flow = flow.value
		self.step = step.value
		self.provider = provider
		self.errorCode = errorCode
		self.detailedCode = detailedCode
	}

	public init(flow: Flow, step: Step, provider: String? = nil, clientCode: ClientCode, detailedCode: Int? = nil) {
		self.flow = flow.value
		self.step = step.value
		self.provider = provider
		self.errorCode = clientCode.value
		self.detailedCode = detailedCode
	}

	public var description: String {
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
// https://github.com/minvws/nl-covid19-coronacheck-app-coordination/blob/main/docs/Error%20Handling.md

// MARK: ErrorCode.Flow

public extension ErrorCode.Flow {

	static let onboarding = ErrorCode.Flow(value: "0")
	static let commercialTest = ErrorCode.Flow(value: "1")
	static let vaccination = ErrorCode.Flow(value: "2")
	static let recovery = ErrorCode.Flow(value: "3")
	static let ggdTest = ErrorCode.Flow(value: "4")
	static let paperproof = ErrorCode.Flow(value: "5")
	static let qr = ErrorCode.Flow(value: "6")
	static let vaccinationAndPositiveTest = ErrorCode.Flow(value: "8")
	static let visitorPass = ErrorCode.Flow(value: "9")
}

// MARK: ErrorCode.Step (Startup)

public extension ErrorCode.Step {

	static let configuration = ErrorCode.Step(value: "10")
	static let publicKeys = ErrorCode.Step(value: "20")
}

// MARK: ErrorCode.Step (Common between test / vaccination flows)

public extension ErrorCode.Step {

	static let providers = ErrorCode.Step(value: "20")
	static let storingEvents = ErrorCode.Step(value: "60")
	static let nonce = ErrorCode.Step(value: "70")
	static let signer = ErrorCode.Step(value: "80")
	static let storingCredentials = ErrorCode.Step(value: "90")
}

// MARK: ErrorCode.Step (Commercial Test)

public extension ErrorCode.Step {

	static let testResult = ErrorCode.Step(value: "50")
}

// MARK: ErrorCode.Step (Vaccination / Recovery / GGD Test)

public extension ErrorCode.Step {

	static let max = ErrorCode.Step(value: "10")
	static let pap = ErrorCode.Step(value: "15")
	static let accessTokens = ErrorCode.Step(value: "30")
	static let unomi = ErrorCode.Step(value: "40")
	static let event = ErrorCode.Step(value: "50")
}

// MARK: ErrorCode.Step (Paper flow)

public extension ErrorCode.Step {

	static let coupling = ErrorCode.Step(value: "10")
	static let scan = ErrorCode.Step(value: "20")
}

// MARK: ErrorCode.Step (QR flow)

public extension ErrorCode.Step {

	static let showQR = ErrorCode.Step(value: "10")
}
