/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import ReusableViews

protocol EventDetailsViewable {
	
	var stackView: UIStackView { get }
	
	func loadDetails(_ details: [(detail: String, hasExtraPrecedingLineBreak: Bool, hasExtraFollowingLineBreak: Bool, isSeparator: Bool)], spacing: CGFloat)
	
	func updateAccessibilityStatus()
}

extension EventDetailsViewable {
	
	func createLabel(for text: String) -> AccessibleBodyLabelView {
		
		let view = AccessibleBodyLabelView()
		view.label.attributedText = NSAttributedString.makeFromHtml(text: text, style: .bodyDark)
		return view
	}
	
	func createLineView() -> UIView {
		
		let view = UIView()
		view.backgroundColor = C.grey2()
		return view
	}
	
	func loadDetails(_ details: [(detail: String, hasExtraPrecedingLineBreak: Bool, hasExtraFollowingLineBreak: Bool, isSeparator: Bool)], spacing: CGFloat) {
		
		var previousLabel: AccessibleBodyLabelView?
		
		details.forEach {
			if $0.isSeparator {
				let spaceView = UIView()
				let lineView = createLineView()
				stackView.addArrangedSubview(spaceView)
				stackView.setCustomSpacing(spacing, after: spaceView)
				stackView.addArrangedSubview(lineView)
				NSLayoutConstraint.activate([
					// Set height to 1, else it will default to 0.
					lineView.heightAnchor.constraint(equalToConstant: 1.0)
				])
				stackView.setCustomSpacing(spacing, after: lineView)
			} else {
				let label = createLabel(for: $0.detail)

				if $0.hasExtraPrecedingLineBreak, let previousLabel {
					stackView.setCustomSpacing(spacing, after: previousLabel)
				}
				
				stackView.addArrangedSubview(label)
				
				if $0.hasExtraFollowingLineBreak {
					stackView.setCustomSpacing(spacing, after: label)
				}
				
				previousLabel = label
			}
		}
	}
	
	/// Hide voice over labels when VoiceControl or SwitchControl are enabled. Setting it to none allows it to scroll for VoiceControl and SwitchControl
	func updateAccessibilityStatus() {
		
		stackView.subviews.forEach { view in
			guard let label = view as? AccessibleBodyLabelView else { return }
			label.updateAccessibilityStatus()
		}
	}
}
