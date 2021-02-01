/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol FileReaderProtocol {
	
	/// Initializer
	init(bundle: Bundle, fileName: String, fileType: String)
	
	/// Read the file and return the content as an optional string
	func read() -> String?
}

/// This class will read a file from disc and return the content as a string
public class FileReader: FileReaderProtocol {
	
	// The name of the file
	internal var fileName: String
	
	// The type of the file
	internal var fileType: String
	
	// The container holding the files
	internal var bundle: Bundle
	
	/// Initializer
	///
	/// - Parameters:
	///   - bundle: The bundle
	///   - fileName: the name of the file to read
	///   - fileType: the type of the file to read
	public required init(bundle: Bundle, fileName: String = "flow", fileType: String = "json") {
		self.bundle = bundle
		self.fileName = fileName
		self.fileType = fileType
	}
	
	/// Read the flow from a file
	///
	/// - Returns: optional string of the content of the file
	public func read() -> String? {
		// Dynamic for test purposes
		guard let filepath = self.bundle.path(forResource: fileName, ofType: fileType) else {
			return nil
		}
		let contents = try? String(contentsOfFile: filepath, encoding: .utf8)
		return contents
	}
}
