/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// Hides VoiceControl labels for Label
final class AccessibleBodyLabelView: BaseView {
	
	let label: Label = {
		let label = Label(body: nil).multiline()
		label.textColor = C.black()
		return label
	}()
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		label.embed(in: self)
		label.setContentHuggingPriority(.required, for: .vertical)
	}
	
	override func setupAccessibility() {
		super.setupAccessibility()
		
		updateAccessibilityStatus()
	}
	
	func updateAccessibilityStatus() {
		label.setupForVoiceAndSwitchControlAccessibility()
		
		isAccessibilityElement = !UIAccessibility.isSwitchControlRunning
		
		let showAccessibilityLabels = UIAccessibility.isVoiceOverRunning || showAccessibilityLabelsForUITests
		accessibilityLabel = showAccessibilityLabels ? label.text : nil
	}
}
