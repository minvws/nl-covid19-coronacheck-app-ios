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

	let containerView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

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

	/// The message text view
	let messageTextView: TextView = {

		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = .clear
		closeButton.addTarget(
			self,
			action: #selector(primaryButtonTapped),
			for: .touchUpInside
		)
		backgroundColor = Theme.colors.bannerBackgroundColor
		closeButton.backgroundColor = Theme.colors.bannerBackgroundColor
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(containerView)
		containerView.addSubview(bannerImageView)
		containerView.addSubview(titleLabel)
		containerView.addSubview(messageTextView)
		addSubview(closeButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Container
			containerView.topAnchor.constraint(
				equalTo: closeButton.topAnchor,
				constant: ViewTraits.margin
			),
			containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor),
			containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -36),

			// Header
			bannerImageView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			bannerImageView.widthAnchor.constraint(equalToConstant: ViewTraits.imageWidth),
			bannerImageView.heightAnchor.constraint(equalToConstant: ViewTraits.imageHeight),
			bannerImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

			closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			closeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
			closeButton.widthAnchor.constraint(equalToConstant: ViewTraits.buttonSize),
			closeButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonSize),

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: containerView.topAnchor
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: bannerImageView.trailingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

			// Message
			messageTextView.leadingAnchor.constraint(
				equalTo: bannerImageView.trailingAnchor,
				constant: ViewTraits.margin
			),
			messageTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			messageTextView.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: 4
			),
			messageTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()

		titleLabel.accessibilityTraits = .header
		closeButton.accessibilityLabel = .close
		bannerImageView.isAccessibilityElement = true
		bannerImageView.accessibilityTraits = .staticText
		bannerImageView.accessibilityLabel = .notification
		accessibilityElements = [bannerImageView, titleLabel, messageTextView, closeButton]
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				kerning: ViewTraits.titleKerning,
				textColor: Theme.colors.secondary
			)
		}
	}

	/// The  message
	var message: String? {
		didSet {
			messageTextView.html(message, textColor: Theme.colors.secondary)
			messageTextView.linkTextAttributes = [
				.foregroundColor: Theme.colors.secondary,
				.underlineColor: Theme.colors.secondary
			]
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
