/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

// Remove this - see QRCard.Region
public enum QRCodeValidityRegion: String, Codable, Equatable {

	case europeanUnion

	public init?(rawValue: String) {
		switch rawValue {
			case "europeanUnion", "eu": self = .europeanUnion
			default: return nil
		}
	}
}
