/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ErrorStateView: ScrolledStackWithButtonView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let messageLineHeight: CGFloat = 22
	}

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()

	let contentTextView: TextView = {

		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let secondaryButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(contentTextView)
		stackView.addArrangedSubview(secondaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		// disable the bottom constraint of the scroll view, add our own
		bottomScrollViewConstraint?.isActive = false

		NSLayoutConstraint.activate([

			// Scroll View
			scrollView.bottomAnchor.constraint(equalTo: footerBackground.topAnchor)
		])
		
		setupPrimaryButton()
	}

	@objc func secondaryButtonTapped() {

		secondaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}

	/// The message
	var message: String? {
		didSet {
			contentTextView.html(message)
		}
	}

	var secondaryButtonTappedCommand: (() -> Void)?

	/// The title for the secondary white/blue button
	var secondaryButtonTitle: String? {
		didSet {
			secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
			secondaryButton.isHidden = secondaryButtonTitle?.isEmpty ?? true
		}
	}
}
