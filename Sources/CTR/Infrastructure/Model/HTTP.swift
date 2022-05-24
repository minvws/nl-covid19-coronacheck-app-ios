/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// HTTP Header
enum HTTPHeaderField: String {

	/// Accept-Encoding
	case acceptEncoding = "Accept-Encoding"

	/// Authorization
	case authorization = "Authorization"

	/// Content-Type
	case contentType = "Content-Type"

}

/// Content type
enum ContentType: String {

	/// application/json
	case json = "application/json"

	/// text/plain;charset=UTF-8
	case text = "text/plain;charset=UTF-8"
}
