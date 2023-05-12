/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Gzip

public protocol DataExporterProtocol {
	
	func export(_ rawData: Data) throws -> [String]
}

public class DataExporter: DataExporterProtocol {
	
	private var maxPackageSize: Int
	
	private var version: String

	public init(maxPackageSize: Int, version: String) {
		
		self.maxPackageSize = maxPackageSize
		self.version = version
	}
	
	public func export(_ rawData: Data) throws -> [String] {
				
		let compressed = try compress(rawData)
		let compressedChunks = compressed.toChunks(by: maxPackageSize)
		
		var result: [String] = []
		compressedChunks.enumerated().forEach { index, data in
			let parcel = MigrationParcel(index: index, numberOfPackages: compressedChunks.count, payload: data, version: version)
			let encoder = JSONEncoder()
			if let encoded = try? encoder.encode(parcel) { // Convert to try and catch
				
				let enbase64 = encoded.base64EncodedString()
				
				result.append(enbase64)
			}
		}
		return result
	}
	
	private func compress(_ uncompressed: Data, level: CompressionLevel = .bestCompression) throws -> Data {
		
		do {
			let compressed: Data = try uncompressed.gzipped(level: level)
			return compressed
			
		} catch let error {
			
			logError("DataExporter: encounter error while compressing: \(error)")
			throw DataMigrationError.compressionError
		}
	}
}
