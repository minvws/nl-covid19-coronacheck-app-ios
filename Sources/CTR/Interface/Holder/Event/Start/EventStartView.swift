/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class EventStartView: ScrolledStackWithButtonView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let messageLineHeight: CGFloat = 22
		static let buttonHeight: CGFloat = 52

		// Margins
		static let margin: CGFloat = 20.0
		static let buttonMargin: CGFloat = 36.0
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

		let button = Button(title: "", style: .tertiary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .center
		return button
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		stackView.distribution = .equalSpacing
		showLineView = false
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(contentTextView)
		footerBackground.addSubview(secondaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		setupPrimaryButton(useFullWidth: true)

		bottomButtonConstraint?.isActive = false

		NSLayoutConstraint.activate([

			// Primary button
			primaryButton.bottomAnchor.constraint(
				equalTo: secondaryButton.topAnchor,
				constant: -ViewTraits.margin
			),

			// Secondary button
			secondaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight),
			secondaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),

			secondaryButton.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.buttonMargin
			),
			secondaryButton.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.buttonMargin
			),
			secondaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	@objc func secondaryButtonTapped() {

		secondaryButtonTappedCommand?()
	}

	// MARK: Public Access

	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}

	var message: String? {
		didSet {
			contentTextView.html(message)
		}
	}

	var secondaryButtonTappedCommand: (() -> Void)?

	var secondaryButtonTitle: String? {
		didSet {
			secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
		}
	}
}
