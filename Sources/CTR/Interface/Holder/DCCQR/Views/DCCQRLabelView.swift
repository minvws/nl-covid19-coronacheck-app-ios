/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DCCQRLabelView: BaseView {
	
	private enum ViewTraits {
		static let spacing: CGFloat = 1
	}
	
	private let fieldLabel: Label = {
		let label = Label(subhead: "").multiline()
		label.textColor = Theme.colors.dark
		return label
	}()
	
	private let valueLabel: Label = {
		let label = Label(bodyBold: "").multiline()
		label.textColor = Theme.colors.dark
		return label
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
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
			fieldLabel.leftAnchor.constraint(equalTo: leftAnchor),
			fieldLabel.rightAnchor.constraint(equalTo: rightAnchor),
			
			valueLabel.topAnchor.constraint(equalTo: fieldLabel.bottomAnchor, constant: ViewTraits.spacing),
			valueLabel.leftAnchor.constraint(equalTo: leftAnchor),
			valueLabel.rightAnchor.constraint(equalTo: rightAnchor),
			valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	// MARK: Public Access
	
	var field: String? {
		didSet {
			fieldLabel.text = field
		}
	}
	
	var value: String? {
		didSet {
			valueLabel.text = value
		}
	}
}
