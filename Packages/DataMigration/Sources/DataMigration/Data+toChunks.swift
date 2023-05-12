/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension Data {
	
	/// Split data into several chunks of lenght length.
	/// (this is all in memory, so do not try to chunk very large pieces of data)
	/// - Parameter length: the max length of each chunk
	/// - Returns: an array of chunks of data.
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
