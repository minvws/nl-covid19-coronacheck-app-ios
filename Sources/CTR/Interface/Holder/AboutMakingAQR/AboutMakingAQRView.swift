/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AboutMakingAQRView: ScrolledStackWithHeaderView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let buttonHeight: CGFloat = 52

		// Margins
		static let margin: CGFloat = 20.0
		static let titleTopMargin: CGFloat = 34.0
		static let contentTextTopMargin: CGFloat = 24.0
		static let stackviewTopMargin: CGFloat = 32.0
	}

	/// The title label
	let titleLabel: Label = {

        return Label(title1: nil, montserrat: true).multiline().header()
	}()

	let contentTextView: TextView = {

		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// the secondary button
	let button: Button = {

		let button = Button(title: "Button", style: .primary)
		button.titleLabel?.font = Theme.fonts.bodySemiBold
		button.rounded = true
		return button
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		headerImageView.backgroundColor = Theme.colors.create
		stackView.backgroundColor = Theme.colors.create
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		contentView.addSubview(titleLabel)
		contentView.addSubview(contentTextView)
		contentView.addSubview(button)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: headerImageView.bottomAnchor,
				constant: ViewTraits.titleTopMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: contentTextView.topAnchor,
				constant: -ViewTraits.contentTextTopMargin
			),

			// Message
			contentTextView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			contentTextView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),

			// StackView
			button.topAnchor.constraint(
				equalTo: contentTextView.bottomAnchor,
				constant: ViewTraits.stackviewTopMargin
			),
			button.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			button.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			button.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.margin
			),
			button.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight)
		])
	}

	// MARK: Public Access

	/// The title
	var header: String? {
		didSet {
			titleLabel.attributedText = header?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}

	/// The message
	var body: String? {
		didSet {
			contentTextView.html(body)
		}
	}

	var buttonTitle: String? {
		didSet {
			button.setTitle(buttonTitle, for: .normal)
		}
	}

	/// The header image
	var headerImage: UIImage? {
		didSet {
			headerImageView.image = headerImage
		}
	}

	/// Hide the header image
	func hideImage() {

		headerImageView.isHidden = true

	}

	/// Show the header image
	func showImage() {

		headerImageView.isHidden = false
	}
}
