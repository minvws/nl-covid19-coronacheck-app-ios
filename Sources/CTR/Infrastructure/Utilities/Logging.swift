/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CocoaLumberjack
import CocoaLumberjackSwift
import Foundation

public protocol Logging {

	/// The category with which the class that conforms to the `Logging`-protocol is logging.
	var loggingCategory: String { get }

	/// Log for verbose purpose
	/// - Parameters:
	///   - message: the message to log
	///   - function: the function in which the the method is called
	///   - file: the file in which the method is called
	///   - line: the line on wicht the method is called
	func logVerbose(_ message: String, function: StaticString, file: StaticString, line: UInt)

	/// Log for debug purpose
	/// - Parameters:
	///   - message: the message to log
	///   - function: the function in which the the method is called
	///   - file: the file in which the method is called
	///   - line: the line on wicht the method is called
	func logDebug(_ message: String, function: StaticString, file: StaticString, line: UInt)

	/// Log for information purpose
	/// - Parameters:
	///   - message: the message to log
	///   - function: the function in which the the method is called
	///   - file: the file in which the method is called
	///   - line: the line on wicht the method is called
	func logInfo(_ message: String, function: StaticString, file: StaticString, line: UInt)

	/// Log for warning purpose
	/// - Parameters:
	///   - message: the message to log
	///   - function: the function in which the the method is called
	///   - file: the file in which the method is called
	///   - line: the line on wicht the method is called
	func logWarning(_ message: String, function: StaticString, file: StaticString, line: UInt)

	/// Log for error purpose
	/// - Parameters:
	///   - message: the message to log
	///   - function: the function in which the the method is called
	///   - file: the file in which the method is called
	///   - line: the line on wicht the method is called
	func logError(_ message: String, function: StaticString, file: StaticString, line: UInt)
}

public extension Logging {

	/// The category with which the class that conforms to the `Logging`-protocol is logging.
	var loggingCategory: String {
		return "CoronaTester"
	}

	/// Log for verbose purpose
	/// - Parameters:
	///   - message: the message to log
	///   - function: the function in which the the method is called
	///   - file: the file in which the method is called
	///   - line: the line on wicht the method is called
	func logVerbose(
		_ message: String,
		function: StaticString = #function,
		file: StaticString = #file,
		line: UInt = #line) {

		DDLogVerbose("💤 \(message)", file: file, function: function, line: line, tag: loggingCategory)
	}

	/// Log for debug purpose
	/// - Parameters:
	///   - message: the message to log
	///   - function: the function in which the the method is called
	///   - file: the file in which the method is called
	///   - line: the line on wicht the method is called
	func logDebug(
		_ message: String,
		function: StaticString = #function,
		file: StaticString = #file,
		line: UInt = #line) {
		DDLogDebug("🐞 \(message)", file: file, function: function, line: line, tag: loggingCategory)
	}

	/// Log for information purpose
	/// - Parameters:
	///   - message: the message to log
	///   - function: the function in which the the method is called
	///   - file: the file in which the method is called
	///   - line: the line on wicht the method is called
	func logInfo(
		_ message: String,
		function: StaticString = #function,
		file: StaticString = #file,
		line: UInt = #line) {
		DDLogInfo("📋 \(message)", file: file, function: function, line: line, tag: loggingCategory)
	}

	/// Log for warning purpose
	/// - Parameters:
	///   - message: the message to log
	///   - function: the function in which the the method is called
	///   - file: the file in which the method is called
	///   - line: the line on wicht the method is called
	func logWarning(
		_ message: String,
		function: StaticString = #function,
		file: StaticString = #file,
		line: UInt = #line) {
		DDLogWarn("❗️ \(message)", file: file, function: function, line: line, tag: loggingCategory)
	}

	/// Log for error purpose
	/// - Parameters:
	///   - message: the message to log
	///   - function: the function in which the the method is called
	///   - file: the file in which the method is called
	///   - line: the line on wicht the method is called
	func logError(
		_ message: String,
		function: StaticString = #function,
		file: StaticString = #file,
		line: UInt = #line) {
		DDLogError("🔥 \(message)", file: file, function: function, line: line, tag: loggingCategory)
	}
}

public final class LogHandler: Logging {

	public static var isSetup = false

	/// Can be called multiple times, will only setup once
	public static func setup() {
		
		guard !isSetup else {
			DDLogDebug(
				"🐞 Logging has already been setup before",
				file: #file,
				function: #function,
				line: #line,
				tag: "default"
			)

			return
		}

		isSetup = true

		let level = Bundle.main.infoDictionary?["LOG_LEVEL"] as? String ?? "error"

		switch level {
			case "verbose":
				dynamicLogLevel = .verbose
			case "debug":
				dynamicLogLevel = .debug
			case "info":
				dynamicLogLevel = .info
			case "warn":
				dynamicLogLevel = .warning
			case "error":
				dynamicLogLevel = .error
			case "none":
				dynamicLogLevel = .off
			default:
				dynamicLogLevel = .off
		}

		DDLog.add(DDOSLogger.sharedInstance) // Uses os_log

		let fileLogger: DDFileLogger = DDFileLogger() // File Logger
		fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
		fileLogger.logFileManager.maximumNumberOfLogFiles = 7
		DDLog.add(fileLogger)

		DDLogDebug("🐞 Logging has been setup", file: #file, function: #function, line: #line, tag: "default")
	}

	public static func logFiles() -> [URL] {

		guard let fileLogger = DDLog.allLoggers.first(where: { $0 is DDFileLogger }) as? DDFileLogger else {
			#if DEBUG
			assertionFailure("File Logger Not Found")
			#endif
			print("File Logger not Found")
			return []
		}
		return fileLogger.logFileManager.sortedLogFilePaths.compactMap { URL(fileURLWithPath: $0) }
	}
}
