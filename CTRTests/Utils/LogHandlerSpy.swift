/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class LogHandlerSpy: Logging {

	var invokedLogVerbose = false
	var invokedLogVerboseCount = 0
	var invokedLogVerboseParameters: (message: String, Void)?
	var invokedLogVerboseParametersList = [(message: String, Void)]()

	func logVerbose(_ message: String) {
		invokedLogVerbose = true
		invokedLogVerboseCount += 1
		invokedLogVerboseParameters = (message, ())
		invokedLogVerboseParametersList.append((message, ()))
	}

	var invokedLogDebug = false
	var invokedLogDebugCount = 0
	var invokedLogDebugParameters: (message: String, Void)?
	var invokedLogDebugParametersList = [(message: String, Void)]()

	func logDebug(_ message: String) {
		invokedLogDebug = true
		invokedLogDebugCount += 1
		invokedLogDebugParameters = (message, ())
		invokedLogDebugParametersList.append((message, ()))
	}

	var invokedLogInfo = false
	var invokedLogInfoCount = 0
	var invokedLogInfoParameters: (message: String, Void)?
	var invokedLogInfoParametersList = [(message: String, Void)]()

	func logInfo(_ message: String) {
		invokedLogInfo = true
		invokedLogInfoCount += 1
		invokedLogInfoParameters = (message, ())
		invokedLogInfoParametersList.append((message, ()))
	}

	var invokedLogWarning = false
	var invokedLogWarningCount = 0
	var invokedLogWarningParameters: (message: String, Void)?
	var invokedLogWarningParametersList = [(message: String, Void)]()

	func logWarning(_ message: String) {
		invokedLogWarning = true
		invokedLogWarningCount += 1
		invokedLogWarningParameters = (message, ())
		invokedLogWarningParametersList.append((message, ()))
	}

	var invokedLogError = false
	var invokedLogErrorCount = 0
	var invokedLogErrorParameters: (message: String, Void)?
	var invokedLogErrorParametersList = [(message: String, Void)]()

	func logError(_ message: String) {
		invokedLogError = true
		invokedLogErrorCount += 1
		invokedLogErrorParameters = (message, ())
		invokedLogErrorParametersList.append((message, ()))
	}

	var invokedSetup = false
	var invokedSetupCount = 0

	func setup() {
		invokedSetup = true
		invokedSetupCount += 1
	}
}
