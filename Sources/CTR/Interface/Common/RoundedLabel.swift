/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RoundedLabel: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		static let margin: CGFloat = 24
		static let cornerRadius: CGFloat = 15
	}
	
	/// The message label
	private let messageLabel: Label = {

        return Label(body: nil).multiline()
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.primaryBlue5()
		
		clipsToBounds = true
		layer.cornerRadius = ViewTraits.cornerRadius
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(messageLabel)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.margin),
			messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: ViewTraits.margin),
			messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -ViewTraits.margin),
			messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.margin)
		])
	}
	
	/// The message
	var message: String? {
		didSet {
			messageLabel.attributedText = .makeFromHtml(text: message, style: .bodyDark)
		}
	}
}
