/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class LogHandlerSpy: Logging {

	var invokedLoggingCategoryGetter = false
	var invokedLoggingCategoryGetterCount = 0
	var stubbedLoggingCategory: String! = ""

	var loggingCategory: String {
		invokedLoggingCategoryGetter = true
		invokedLoggingCategoryGetterCount += 1
		return stubbedLoggingCategory
	}

	var invokedLogVerbose = false
	var invokedLogVerboseCount = 0
	var invokedLogVerboseParameters: (message: String, function: StaticString, file: StaticString, line: UInt)?
	var invokedLogVerboseParametersList = [(message: String, function: StaticString, file: StaticString, line: UInt)]()

	func logVerbose(_ message: String, function: StaticString, file: StaticString, line: UInt) {
		invokedLogVerbose = true
		invokedLogVerboseCount += 1
		invokedLogVerboseParameters = (message, function, file, line)
		invokedLogVerboseParametersList.append((message, function, file, line))
	}

	var invokedLogDebug = false
	var invokedLogDebugCount = 0
	var invokedLogDebugParameters: (message: String, function: StaticString, file: StaticString, line: UInt)?
	var invokedLogDebugParametersList = [(message: String, function: StaticString, file: StaticString, line: UInt)]()

	func logDebug(_ message: String, function: StaticString, file: StaticString, line: UInt) {
		invokedLogDebug = true
		invokedLogDebugCount += 1
		invokedLogDebugParameters = (message, function, file, line)
		invokedLogDebugParametersList.append((message, function, file, line))
	}

	var invokedLogInfo = false
	var invokedLogInfoCount = 0
	var invokedLogInfoParameters: (message: String, function: StaticString, file: StaticString, line: UInt)?
	var invokedLogInfoParametersList = [(message: String, function: StaticString, file: StaticString, line: UInt)]()

	func logInfo(_ message: String, function: StaticString, file: StaticString, line: UInt) {
		invokedLogInfo = true
		invokedLogInfoCount += 1
		invokedLogInfoParameters = (message, function, file, line)
		invokedLogInfoParametersList.append((message, function, file, line))
	}

	var invokedLogWarning = false
	var invokedLogWarningCount = 0
	var invokedLogWarningParameters: (message: String, function: StaticString, file: StaticString, line: UInt)?
	var invokedLogWarningParametersList = [(message: String, function: StaticString, file: StaticString, line: UInt)]()

	func logWarning(_ message: String, function: StaticString, file: StaticString, line: UInt) {
		invokedLogWarning = true
		invokedLogWarningCount += 1
		invokedLogWarningParameters = (message, function, file, line)
		invokedLogWarningParametersList.append((message, function, file, line))
	}

	var invokedLogError = false
	var invokedLogErrorCount = 0
	var invokedLogErrorParameters: (message: String, function: StaticString, file: StaticString, line: UInt)?
	var invokedLogErrorParametersList = [(message: String, function: StaticString, file: StaticString, line: UInt)]()

	func logError(_ message: String, function: StaticString, file: StaticString, line: UInt) {
		invokedLogError = true
		invokedLogErrorCount += 1
		invokedLogErrorParameters = (message, function, file, line)
		invokedLogErrorParametersList.append((message, function, file, line))
	}

	var invokedSetup = false
	var invokedSetupCount = 0

	func setup() {
		invokedSetup = true
		invokedSetupCount += 1
	}
}
