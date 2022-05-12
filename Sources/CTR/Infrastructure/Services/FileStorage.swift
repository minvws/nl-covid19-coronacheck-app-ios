/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol FileStorageProtocol: AnyObject {
	func store(_ data: Data, as fileName: String) throws
	func read(fileName: String) -> Data?
	func debugLogItems()
	func fileExists(_ fileName: String) -> Bool
	func remove(_ fileName: String)
}

final class FileStorage: FileStorageProtocol, Logging {
	
	private let fileManager: FileManager
	
	init(fileManager: FileManager = FileManager.default) {
		self.fileManager = fileManager
	}

	/// Get url to documents directory
	var documentsURL: URL? {
		return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
	}

	/// Store data in documents directory
	/// - Parameters:
	///   - data: Store data
	///   - fileName: Name of file
	/// - Throws
	func store(_ data: Data, as fileName: String) throws {
		guard let url = documentsURL else {
			logError("Failed to load documents directory")
			return
		}
		let fileUrl = url.appendingPathComponent(fileName, isDirectory: false)
		
		try fileManager.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
		try data.write(to: fileUrl, options: .atomic)
	}
	
	func read(fileName: String) -> Data? {
		
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

	/// Log items on disk for debug mode
	func debugLogItems() {
		guard let path = documentsURL?.path else { return }

		do {
			let items = try fileManager.contentsOfDirectory(atPath: path)

			for item in items {
				logDebug("Found \(item)")
			}
		} catch {
			logError("Failed to read directory \(error)")
		}
	}

	/// Check if a file exists
	/// - Parameter fileName: the name of the file
	/// - Returns: True if it does.
	func fileExists(_ fileName: String) -> Bool {

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
	func remove(_ fileName: String) {

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

}
