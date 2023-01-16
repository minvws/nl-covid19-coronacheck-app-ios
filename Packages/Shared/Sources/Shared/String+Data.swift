/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import CommonCrypto

public extension String {
	
	var sha256: String {
		
		let str = cString(using: .utf8)
		let strLen = CUnsignedInt(lengthOfBytes(using: .utf8))
		let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
		let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
		
		CC_SHA256(str, strLen, result)
		
		let hash = NSMutableString()
		
		for index in 0 ..< digestLen {
			hash.appendFormat("%02x", result[index])
		}
		
		result.deallocate()
		
		return String(format: hash as String)
	}
}

public extension String {
	
	func base64Decoded() -> String? {
		
		var st = self
		if self.count % 4 <= 2 {
			st += String(repeating: "=", count: (self.count % 4))
		}
		guard let data = Data(base64Encoded: st) else { return nil }
		return String(data: data, encoding: .utf8)
	}
}

public extension Data {
	
	var sha256: Data {
		
		var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
		
		withUnsafeBytes {
			_ = CC_SHA256($0.baseAddress, CC_LONG(count), &hash)
		}
		
		return Data(hash)
	}
}

public extension String {
	
	var bytes: [UInt8] { return [UInt8](self.utf8) }
}
