/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/*
 Button with larger tap area (44x44 points). It is for small icon-sized buttons.
 */
open class TappableButton: UIButton {
	
	private enum ViewTraits {
		
		static let minimumHitArea = CGSize(width: 44, height: 44)
	}
 
	override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		guard !self.isHidden, self.isUserInteractionEnabled, self.alpha > 0.01 else { return false }
		
		var hitRect = bounds
		let xInset = min(0, bounds.width - ViewTraits.minimumHitArea.width)
		let yInset = min(0, bounds.height - ViewTraits.minimumHitArea.height)
		hitRect = hitRect.insetBy(dx: xInset, dy: yInset)
		return hitRect.contains(point)
	}
}
