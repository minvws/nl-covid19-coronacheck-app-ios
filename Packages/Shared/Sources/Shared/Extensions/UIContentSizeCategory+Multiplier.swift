/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UIContentSizeCategory {
	
	public static var currentSizeMultiplier: CGFloat {
		return UIApplication.shared.preferredContentSizeCategory.sizeMultiplier
	}
	
	public var sizeMultiplier: CGFloat {
		let size = { (amount: CGFloat) -> CGFloat in
			let step = 0.075
			return 1 + step * amount
		}
		
		switch self {
			case .extraSmall,
					.small:
				return size(-2)
			case .medium:
				return size(-1)
			case .large:
				return size(0)
			case .extraLarge:
				return size(1)
			case .extraExtraLarge:
				return size(2)
			case .extraExtraExtraLarge:
				return size(3)
			case .accessibilityMedium,
					.accessibilityLarge,
					.accessibilityExtraLarge,
					.accessibilityExtraExtraLarge,
					.accessibilityExtraExtraExtraLarge:
				return size(4)
			default:
				return size(0)
		}
	}
}
