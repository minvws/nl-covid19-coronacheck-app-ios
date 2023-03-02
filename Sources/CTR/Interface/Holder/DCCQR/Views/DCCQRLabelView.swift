/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Resources

final class DCCQRLabelView: BaseView, DCCQRLabelViewable {
	
	/// The display constants
	private enum ViewTraits {
		static let spacing: CGFloat = 1
		static let lineHeight: CGFloat = 22
		static let kerning: CGFloat = -0.41
	}
	
	/// The field label
	private let fieldLabel: Label = {
		return Label(subhead: "").multiline()
	}()
	
	/// The value label
	private let valueLabel: Label = {
		return Label(bodyBold: "").multiline()
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
		fieldLabel.isSelectable = false
		valueLabel.isSelectable = false
		
		// Make this dual label view selectable
		self.isUserInteractionEnabled = true
		addGestureRecognizer(
			longPressGestureRecognizer
		)
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(fieldLabel)
		addSubview(valueLabel)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			fieldLabel.topAnchor.constraint(equalTo: topAnchor),
			fieldLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			fieldLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			
			valueLabel.topAnchor.constraint(equalTo: fieldLabel.bottomAnchor, constant: ViewTraits.spacing),
			valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	// MARK: Public Access
	
	/// The dcc field
	var field: String? {
		didSet {
			fieldLabel.attributedText = field?.setLineHeight(
				ViewTraits.lineHeight,
				kerning: ViewTraits.kerning
			)
		}
	}
	
	/// The dcc value
	var value: String? {
		didSet {
			valueLabel.attributedText = value?.setLineHeight(
				ViewTraits.lineHeight,
				kerning: ViewTraits.kerning
			)
		}
	}
	
	/// Set up labels to support SwitchControl accessibility
	func updateAccessibilityStatus() {
		
		guard let field = field, let value = value else { return }
		
		fieldLabel.setupForVoiceAndSwitchControlAccessibility()
		valueLabel.setupForVoiceAndSwitchControlAccessibility()
		
		if UIAccessibility.isVoiceOverRunning || showAccessibilityLabelsForUITests {
			// Show labels for VoiceOver
			accessibilityLabel = [field, value].joined(separator: ",")
		} else {
			// Hide labels for VoiceControl
			accessibilityLabel = nil
		}
		
		// Disabled as interactive element for SwitchControl
		isAccessibilityElement = !UIAccessibility.isSwitchControlRunning
	}
	
	// MARK: - Selectable
	
	override var canBecomeFirstResponder: Bool {
		true
	}
	
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		action == #selector(copy(_:))
	}

	// MARK: - UIResponderStandardEditActions
	
	override func copy(_ sender: Any?) {
		UIPasteboard.general.string = "\(field ?? "") \(value ?? "")"
	}
	
	// MARK: - Long-press Handler

	private lazy var longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
	
	@objc func handleLongPress(_ recognizer: UIGestureRecognizer) {
		guard recognizer.state == .began, let recognizerView = recognizer.view else { return }
		recognizerView.becomeFirstResponder()
		
		UIMenuController.shared.setTargetRect(recognizerView.bounds, in: self)
		UIMenuController.shared.setMenuVisible(true, animated: true)
	}
}
