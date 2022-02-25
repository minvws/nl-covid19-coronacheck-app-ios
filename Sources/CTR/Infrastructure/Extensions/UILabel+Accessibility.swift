/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UILabel {
	
	/// Set up when VoiceControl and SwitchControl scrolling issue occur. Setting it to none allows it to scroll for VoiceControl and SwitchControl.
	/// It also hides VoiceControl labels when VoiceControl is enabled.
	func setupForVoiceAndSwitchControlAccessibility() {
		
		accessibilityTraits = !UIAccessibility.isVoiceOverRunning ? .none : .staticText
		isAccessibilityElement = UIAccessibility.isVoiceOverRunning || UIAccessibility.isSwitchControlRunning
	}
}
