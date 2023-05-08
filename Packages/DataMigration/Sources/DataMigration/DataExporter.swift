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
		
		let base64 = compressed.base64EncodedString()
		logVerbose("Data export: size (raw) \(compressed.count) -> (b64) \(base64.count)")
		
		let compChunks = compressed.toChunks(by: maxPackageSize)
		logVerbose("Data export: \(compChunks.count) parcels")
		
		var result: [String] = []
		compChunks.enumerated().forEach { index, data in
			let parcel = MigrationParcel(index: index, numberOfPackages: compChunks.count, payload: data, version: version)
			let encoder = JSONEncoder()
			if let encoded = try? encoder.encode(parcel) { // Convert to try and catch
				
				let enbase64 = encoded.base64EncodedString()
				
				logVerbose("Parcel encodign: size (raw) \(encoded.count) -> (b64) \(enbase64.count)")
				
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

extension Data {
	
	func toChunks(by length: Int) -> [Data] {
		
		let dataLen = (self as NSData).length
		let fullChunks = Int(dataLen / length) // 1 Kbyte
		let totalChunks = fullChunks + (dataLen % length != 0 ? 1 : 0)
		
		var chunks: [Data] = [Data]()
		for chunkCounter in 0..<totalChunks {
			var chunk: Data
			let chunkBase = chunkCounter * length
			var diff = length
			if chunkCounter == totalChunks - 1 {
				diff = dataLen - chunkBase
			}
			
			let range: Range<Data.Index> = chunkBase..<(chunkBase + diff)
			chunk = self.subdata(in: range)
			
			chunks.append(chunk)
		}
		return chunks
	}
}
