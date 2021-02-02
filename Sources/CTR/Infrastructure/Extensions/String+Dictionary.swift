/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension String {

	func convertToDictionary() -> [String: AnyObject]? {

		if let data = self.data(using: .utf8) {
			do {
				return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
			} catch {
				print(error.localizedDescription)
			}
		}
		return nil
	}
}
