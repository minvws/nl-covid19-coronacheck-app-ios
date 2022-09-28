/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

// swiftlint:disable disable_print

import Foundation

private enum LoggingLevel: String, Comparable {
	
	static func < (lhs: LoggingLevel, rhs: LoggingLevel) -> Bool {
		return lhs.numericLevel < rhs.numericLevel
	}
	
	case verbose
	case debug
	case info
	case warning
	case error
	case off
	
	var numericLevel: Int {
		switch self {
			case .verbose:
				return 5
			case .debug:
				return 4
			case .info:
				return 3
			case .warning:
				return 2
			case .error:
				return 1
			case .off:
				return 0
		}
	}
}

private let loggingLevel: LoggingLevel = {
	guard !ProcessInfo.processInfo.isTesting else { return .off }
	guard let string = Bundle.main.infoDictionary?["LOG_LEVEL"] as? String else { return .off }
	return LoggingLevel(rawValue: string) ?? .off
}()

/// Log for verbose purpose
/// - Parameters:
///   - message: the message to log
public func logVerbose(_ message: String, _ values: Any...) {
	guard loggingLevel >= LoggingLevel.verbose else { return }
	log(icon: "💤", message: message, values)
}

/// Log for debug purpose
/// - Parameters:
///   - message: the message to log
public func logDebug(_ message: String, _ values: Any...) {
	guard loggingLevel >= LoggingLevel.debug else { return }
	log(icon: "🐞", message: message, values)
}

/// Log for information purpose
/// - Parameters:
///   - message: the message to log
public func logInfo(_ message: String, _ values: Any...) {
	guard loggingLevel >= LoggingLevel.info else { return }
	log(icon: "📋", message: message, values)
}

/// Log for warning purpose
/// - Parameters:
///   - message: the message to log
public func logWarning(_ message: String, _ values: Any...) {
	guard loggingLevel >= LoggingLevel.warning else { return }
	log(icon: "❗️", message: message, values)
}

/// Log for error purpose
/// - Parameters:
///   - message: the message to log
public func logError(_ message: String, _ values: Any...) {
	guard loggingLevel >= LoggingLevel.error else { return }
	log(icon: "🔥", message: message, values)
}

private func log(icon: String, message: String, _ values: Any...) {
	if values.count == 1, let valuesDict = values[0] as? [String: Any] {
		print("\(icon) \(message):", valuesDict)
	} else if values.count == 1 {
		print("\(icon) \(message): \(values[0])")
	} else if values.isNotEmpty {
		print("\(icon) \(message):", values)
	} else {
		print("\(icon) \(message)")
	}
}
