/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CocoaLumberjack
import CocoaLumberjackSwift
import Foundation

protocol Logging {

	/// Log for verbose purpose
	/// - Parameters:
	///   - message: the message to log
	func logVerbose(_ message: String)

	/// Log for debug purpose
	/// - Parameters:
	///   - message: the message to log
	func logDebug(_ message: String)

	/// Log for information purpose
	/// - Parameters:
	///   - message: the message to log
	func logInfo(_ message: String)

	/// Log for warning purpose
	/// - Parameters:
	///   - message: the message to log
	func logWarning(_ message: String)

	/// Log for error purpose
	/// - Parameters:
	///   - message: the message to log
	func logError(_ message: String)
}

final class LogHandler: Logging {

	private var isSetup = false
	
	init() {
		if !ProcessInfo.processInfo.isTesting {
			setup()
		}
	}

	/// Can be called multiple times, will only setup once
	func setup() {
		
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
	
	// MARK: Logging
	
	/// The category with which the class that conforms to the `Logging`-protocol is logging.
	private let loggingCategory = "CoronaCheck"

	/// Log for verbose purpose
	/// - Parameters:
	///   - message: the message to log
	func logVerbose(_ message: String) {
		DDLogVerbose("💤 \(message)", tag: loggingCategory)
	}

	/// Log for debug purpose
	/// - Parameters:
	///   - message: the message to log
	func logDebug(_ message: String) {
		DDLogDebug("🐞 \(message)", tag: loggingCategory)
	}

	/// Log for information purpose
	/// - Parameters:
	///   - message: the message to log
	func logInfo(_ message: String) {
		DDLogInfo("📋 \(message)", tag: loggingCategory)
	}

	/// Log for warning purpose
	/// - Parameters:
	///   - message: the message to log
	func logWarning(_ message: String) {
		DDLogWarn("❗️ \(message)", tag: loggingCategory)
	}

	/// Log for error purpose
	/// - Parameters:
	///   - message: the message to log
	func logError(_ message: String) {
		DDLogError("🔥 \(message)", tag: loggingCategory)
	}
}
