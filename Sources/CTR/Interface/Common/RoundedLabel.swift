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
	private let messageTextView: TextView = {

		return TextView()
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.emptyDashboardColor
		
		clipsToBounds = true
		layer.cornerRadius = ViewTraits.cornerRadius
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(messageTextView)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			messageTextView.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.margin),
			messageTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: ViewTraits.margin),
			messageTextView.rightAnchor.constraint(equalTo: rightAnchor, constant: -ViewTraits.margin),
			messageTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.margin)
		])
	}
	
	/// The message
	var message: String? {
		didSet {
			messageTextView.attributedText = .makeFromHtml(text: message,
														font: Theme.fonts.body,
														textColor: Theme.colors.dark)
		}
	}
}
