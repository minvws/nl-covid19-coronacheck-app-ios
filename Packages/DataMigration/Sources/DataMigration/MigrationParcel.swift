/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public struct MigrationParcel: Codable {
	
	public let index: Int
	
	public let numberOfPackages: Int
	
	public let payload: Data
	
	public let version: String
	
	enum CodingKeys: String, CodingKey {
		
		case index = "i"
		case numberOfPackages = "n"
		case payload = "p"
		case version = "v"
	}
}
