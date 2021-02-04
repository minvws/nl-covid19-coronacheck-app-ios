/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

enum EncodingTarget {
    case api
    case internalStorage
    case unknown
    
    static let infoKey = CodingUserInfoKey(rawValue: "EncodingTarget")!
}

enum DecodingSource {
    case api
    case internalStorage
    case unknown
    
    static let infoKey = CodingUserInfoKey(rawValue: "DecodingSource")!
}

extension Encoder {
    var target: EncodingTarget {
        (userInfo[EncodingTarget.infoKey] as? EncodingTarget) ?? .unknown
    }
}

extension Decoder {
    var source: DecodingSource {
        (userInfo[DecodingSource.infoKey] as? DecodingSource) ?? .unknown
    }
}

extension JSONEncoder {
    var target: EncodingTarget {
        get { (userInfo[EncodingTarget.infoKey] as? EncodingTarget) ?? .unknown }
        set { userInfo[EncodingTarget.infoKey] = newValue }
    }
}

extension JSONDecoder {
    var source: DecodingSource {
        get { (userInfo[DecodingSource.infoKey] as? DecodingSource) ?? .unknown }
        set { userInfo[DecodingSource.infoKey] = newValue }
    }
}
