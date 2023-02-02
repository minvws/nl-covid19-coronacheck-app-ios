/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

open class ContentView: ScolledStackContentBaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
	}

	public let secondaryButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()

	override open func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
	}

	override open func setupViewHierarchy() {

		super.setupViewHierarchy()
		stackView.addArrangedSubview(secondaryButton)
	}

	@objc func secondaryButtonTapped() {

		secondaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The title
	public var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}

	/// The message
	public var message: String? {
		didSet {
			contentTextView.applyHTML(message)
		}
	}

	public var secondaryButtonTappedCommand: (() -> Void)?

	/// The title for the secondary white/blue button
	public var secondaryButtonTitle: String? {
		didSet {
			secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
			secondaryButton.isHidden = secondaryButtonTitle?.isEmpty ?? true
		}
	}
}
