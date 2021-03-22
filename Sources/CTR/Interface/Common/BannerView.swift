/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class BannerView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimension
		static let imageHeight: CGFloat = 20.0
		static let imageWidth: CGFloat = 16.0
		static let titleKerning: CGFloat = -0.41
		static let buttonSize: CGFloat = 60.0

		// Margins
		static let margin: CGFloat = 20.0

	}

	/// The banner image
	let bannerImageView: UIImageView = {
		let view = UIImageView(image: .alert)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.tintColor = Theme.colors.secondary
		return view
	}()

	/// the close button
	let closeButton: Button = {

		let button = Button(title: "", style: .secondary)
		button.setImage(UIImage.cross, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.tintColor = Theme.colors.secondary
		return button
	}()

	/// The title label
	let titleLabel: Label = {

		return Label(bodySemiBold: nil).multiline()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(footnote: nil).multiline()
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = .clear
		titleLabel.textColor = Theme.colors.secondary
		messageLabel.textColor = Theme.colors.secondary
		closeButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
		backgroundColor = Theme.colors.bannerBackgroundColor
		closeButton.backgroundColor = Theme.colors.bannerBackgroundColor
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(bannerImageView)
		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(closeButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Header
			bannerImageView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			bannerImageView.widthAnchor.constraint(equalToConstant: ViewTraits.imageWidth),
			bannerImageView.heightAnchor.constraint(equalToConstant: ViewTraits.imageHeight),
			bannerImageView.topAnchor.constraint(
				equalTo: closeButton.topAnchor,
				constant: 2 * ViewTraits.margin
			),

			closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			closeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
			closeButton.widthAnchor.constraint(equalToConstant: ViewTraits.buttonSize),
			closeButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonSize),

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: closeButton.topAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: bannerImageView.trailingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: bannerImageView.trailingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor),
			messageLabel.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: 4
			),
			messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40)
		])
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(kerning: ViewTraits.titleKerning)
		}
	}

	/// The message
	var message: String? {
		didSet {
			messageLabel.attributedText = .makeFromHtml(
				text: message,
				font: Theme.fonts.footnote,
				textColor: Theme.colors.secondary,
				lineHeight: 18
			)
		}
	}

	/// The icon
	var icon: UIImage? {
		didSet {
			bannerImageView.image = icon
		}
	}

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?
}
