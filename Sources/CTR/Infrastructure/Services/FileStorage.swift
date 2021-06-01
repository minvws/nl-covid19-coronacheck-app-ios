//
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
	
	var documentsURL: URL? {
		return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
	}
	
	func store<T>(_ object: T, as fileName: String) where T: Encodable {
		guard let url = documentsURL else {
			logError("Failed to load documents directory")
			return
		}
		let fileUrl = url.appendingPathComponent(fileName, isDirectory: false)
		
		do {
			try fileManager.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
		} catch {
			logError("Failed to create directory")
			return
		}
		
		let data: Data
		do {
			data = try JSONEncoder().encode(object)
		} catch {
			logError("Failed to encode \(fileName)")
			return
		}
		
		do {
			try data.write(to: fileUrl)
		} catch {
			logError("Failed to write to \(fileName)")
		}
	}
}
