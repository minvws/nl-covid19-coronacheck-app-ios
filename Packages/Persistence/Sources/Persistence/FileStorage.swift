/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

public protocol FileStorageProtocol: AnyObject {
	func store(_ data: Data, as fileName: String) throws
	func read(fileName: String) -> Data?
	func fileExists(_ fileName: String) -> Bool
	func remove(_ fileName: String)
	func removeDatabase()

	var documentsURL: URL? { get }
}

final public class FileStorage: FileStorageProtocol {
	
	private let fileManager: FileManager
	
	public init(fileManager: FileManager = FileManager.default) {
		self.fileManager = fileManager
	}

	/// Get url to documents directory
	public var documentsURL: URL? {
		return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
	}

	/// Store data in documents directory
	/// - Parameters:
	///   - data: Store data
	///   - fileName: Name of file
	/// - Throws
	public func store(_ data: Data, as fileName: String) throws {
		guard let url = documentsURL else {
			logError("Failed to load documents directory")
			return
		}
		let fileUrl = url.appendingPathComponent(fileName, isDirectory: false)
		
		try fileManager.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
		try data.write(to: fileUrl, options: .atomic)
	}
	
	public func read(fileName: String) -> Data? {
		
		guard let url = documentsURL else {
			logError("Failed to load documents directory")
			return nil
		}
		let fileUrl = url.appendingPathComponent(fileName, isDirectory: false)
		
		guard fileManager.fileExists(atPath: fileUrl.path) else {
			return nil
		}
		
		do {
			let data = try Data(contentsOf: fileUrl)
			return data
		} catch {
			return nil
		}
	}

	/// Check if a file exists
	/// - Parameter fileName: the name of the file
	/// - Returns: True if it does.
	public func fileExists(_ fileName: String) -> Bool {

		guard let url = documentsURL else {
			logError("Failed to load documents directory")
			return false
		}

		let fileUrl = url.appendingPathComponent(fileName, isDirectory: false)
		return fileManager.fileExists(atPath: fileUrl.path)
	}

	/// Check if a file exists
	/// - Parameter fileName: the name of the file
	/// - Returns: True if it does.
	public func remove(_ fileName: String) {

		guard let url = documentsURL else {
			logError("Failed to load documents directory")
			return
		}

		let fileUrl = url.appendingPathComponent(fileName, isDirectory: false)
		do {
			try fileManager.removeItem(atPath: fileUrl.path)
		} catch {
			logError("Failed to read directory \(error)")
		}
	}

	public func removeDatabase() {
		
		if let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
			for fileName in ["CoronaCheck.sqlite", "CoronaCheck.sqlite-shm", "CoronaCheck.sqlite-wal"] {
				let fileUrl = applicationSupport.appendingPathComponent(fileName, isDirectory: false)
				if fileManager.fileExists(atPath: fileUrl.path) {
					do {
						try fileManager.removeItem(atPath: fileUrl.path)
					} catch {
						logError("Failed to read directory \(error)")
					}
				}
			}
		}
	}
}
