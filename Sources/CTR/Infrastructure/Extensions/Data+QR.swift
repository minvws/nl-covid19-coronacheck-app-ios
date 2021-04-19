/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension Data {

	/// Generate a QR image
	/// - Returns: QR image of the data
	func generateQRCode() -> UIImage? {

		if let filter = CIFilter(name: "CIQRCodeGenerator") {
			filter.setValue(self, forKey: "inputMessage")
			let transform = CGAffineTransform(scaleX: 3, y: 3)

			if let output = filter.outputImage?.transformed(by: transform) {
				return UIImage(ciImage: output)
			}
		}
		return nil
	}
}
