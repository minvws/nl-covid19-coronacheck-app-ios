/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// A grey full width button with a title and a disclosure icon
class DisclosureButton: DisclosureSubTitleButton {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let singleLabelMargin: CGFloat = 26.0
		static let leadingMargin: CGFloat = 16.0
	}

	override func setupViews() {

		super.setupViews()
		subTitleLabel.isHidden = true
	}

	override func setupViewConstraints() {

		// No super.setupViewConstraints(), override only

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.singleLabelMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.leadingMargin
			),
			titleLabel.trailingAnchor.constraint(equalTo: disclosureView.leadingAnchor),
			titleLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.singleLabelMargin
			)
		])

		setupDisclosureViewConstraints()
	}

	override func setAccessibilityLabel() {

		button.accessibilityLabel = title
	}
}
