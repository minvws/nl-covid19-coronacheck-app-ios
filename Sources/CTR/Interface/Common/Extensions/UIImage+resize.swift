/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UIImage {
	
	func resizedImage(toSize imageSize: CGSize) -> UIImage? {
		
		let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: imageSize.width, height: imageSize.height))
		UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
		self.draw(in: frame)
		let resizedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.withRenderingMode(.alwaysOriginal)
		return resizedImage
	}
}
