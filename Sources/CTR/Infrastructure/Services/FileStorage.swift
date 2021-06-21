/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class FileStorage: Logging {
	
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
		try data.write(to: fileUrl)
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
}
