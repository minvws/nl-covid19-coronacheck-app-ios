/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DCCQRLabelView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		static let spacing: CGFloat = 1
		static let lineHeight: CGFloat = 22
		static let kerning: CGFloat = -0.41
	}
	
	/// The field label
	private let fieldLabel: Label = {
		let label = Label(subhead: "").multiline()
		label.textColor = Theme.colors.dark
		return label
	}()
	
	/// The value label
	private let valueLabel: Label = {
		let label = Label(bodyBold: "").multiline()
		label.textColor = Theme.colors.dark
		return label
	}()
	
	private let accessibleFieldLabel: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isAccessibilityElement = true
		return view
	}()
	
	private let accessibleValueLabel: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isAccessibilityElement = true
		return view
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(accessibleFieldLabel)
		addSubview(accessibleValueLabel)
		
		fieldLabel.embed(in: accessibleFieldLabel)
		valueLabel.embed(in: accessibleValueLabel)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			accessibleFieldLabel.topAnchor.constraint(equalTo: topAnchor),
			accessibleFieldLabel.leftAnchor.constraint(equalTo: leftAnchor),
			accessibleFieldLabel.rightAnchor.constraint(equalTo: rightAnchor),
			
			accessibleValueLabel.topAnchor.constraint(equalTo: accessibleFieldLabel.bottomAnchor, constant: ViewTraits.spacing),
			accessibleValueLabel.leftAnchor.constraint(equalTo: leftAnchor),
			accessibleValueLabel.rightAnchor.constraint(equalTo: rightAnchor),
			accessibleValueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	// MARK: Public Access
	
	/// The dcc field
	var field: String? {
		didSet {
			fieldLabel.attributedText = field?.setLineHeight(ViewTraits.lineHeight,
															 kerning: ViewTraits.kerning)
			if UIAccessibility.isVoiceOverRunning {
				accessibleFieldLabel.accessibilityLabel = field
			}
		}
	}
	
	/// The dcc value
	var value: String? {
		didSet {
			valueLabel.attributedText = value?.setLineHeight(ViewTraits.lineHeight,
															 kerning: ViewTraits.kerning)
			if UIAccessibility.isVoiceOverRunning {
				accessibleValueLabel.accessibilityLabel = value
			}
		}
	}
}
