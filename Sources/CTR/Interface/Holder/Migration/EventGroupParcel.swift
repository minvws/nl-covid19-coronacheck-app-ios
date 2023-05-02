/*
* Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public struct EventGroupParcel: Codable {
	
	public let expiryDate: Double?
		
	public let jsonData: Data
	
	public let providerIdentifier: String
	
	public let type: String
	
	enum CodingKeys: String, CodingKey {
		
		case expiryDate = "e"
		
		case jsonData = "d"
		
		case providerIdentifier = "p"
		
		case type = "t"
	}
}
