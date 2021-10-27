/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// A grey full width button with a title and a disclosure icon
class DisclosureButton: DisclosureSubtitleButton {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let topMargin: CGFloat = 18.0
		static let bottomMargin: CGFloat = 22
		static let leadingMargin: CGFloat = 16.0
	}

	override func setupViews() {

		super.setupViews()
		subtitleLabel.isHidden = true
	}

	override func setupViewConstraints() {

		// No super.setupViewConstraints(), override only

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.topMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.leadingMargin
			),
			titleLabel.trailingAnchor.constraint(equalTo: disclosureView.leadingAnchor),
			titleLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.bottomMargin
			)
		])

		setupDisclosureViewConstraints()
	}

	override func setAccessibilityLabel() {

		button.accessibilityLabel = title
	}
}
