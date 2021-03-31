/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AboutView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let messageLineHeight: CGFloat = 22
		static let messageLineKerning: CGFloat = -0.41
		static let versionLineHeight: CGFloat = 18
		static let versionLineKerning: CGFloat = -0.24
	}

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The link label
	let versionLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		versionLabel.textColor = Theme.colors.launchGray
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(messageLabel)
		stackView.addArrangedSubview(versionLabel)
	}

	// MARK: Public Access

	/// The message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(
				ViewTraits.messageLineHeight,
				kerning: ViewTraits.messageLineKerning
			)
		}
	}

	/// The version
	var version: String? {
		didSet {
			versionLabel.attributedText = version?.setLineHeight(
				ViewTraits.versionLineHeight,
				kerning: ViewTraits.versionLineKerning
			)
		}
	}
}
