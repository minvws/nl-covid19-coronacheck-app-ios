/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public struct EventGroupParcel: Codable {
	
	public let jsonData: Data
	
	enum CodingKeys: String, CodingKey {
		
		case jsonData = "d"
	}
}
