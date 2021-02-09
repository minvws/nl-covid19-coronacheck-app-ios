/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ButtonWithSubtitle: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let shadowRadius: CGFloat = 6
		static let shadowOpacity: Float = 0.3

//		// Margins
		static let textMargin: CGFloat = 2.0
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 18.0
		static let leadingMargin: CGFloat = 16.0
	}

	/// The title label
	let titleLabel: Label = {

		return Label(bodyBold: nil)
	}()

	/// The sub title label
	let subTitleLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	let chevron: UIImageView = {

		let view = UIImageView(image: UIImage.disclosure)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let button: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.lightBackground

		layer.cornerRadius = ViewTraits.cornerRadius

		// Shadow
		layer.shadowColor = Theme.colors.shadow.withAlphaComponent(0.7).cgColor
		layer.shadowOpacity = ViewTraits.shadowOpacity
		layer.shadowOffset = .zero
		layer.shadowRadius = ViewTraits.shadowRadius
		// Cache Shadow
		layer.shouldRasterize = true
		layer.rasterizationScale = UIScreen.main.scale

		button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(chevron)
		addSubview(titleLabel)
		addSubview(subTitleLabel)
		button.embed(in: self)
		bringSubviewToFront(button)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

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
			titleLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor),
			titleLabel.bottomAnchor.constraint(
				equalTo: subTitleLabel.topAnchor,
				constant: -ViewTraits.textMargin
			),

			// Message
			subTitleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.leadingMargin
			),
			subTitleLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor),

			subTitleLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.topMargin
			),

			chevron.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			chevron.heightAnchor.constraint(equalToConstant: 22),
			chevron.widthAnchor.constraint(equalToConstant: 10),
			chevron.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	/// The onboarding title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	/// The sub title
	var subtitle: String? {
		didSet {
			subTitleLabel.text = subtitle
		}
	}
}

class ChooseProviderView: ScrollViewWithHeader {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let buttonWidth: CGFloat = 212.0
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22
		static let imageRatio: CGFloat = 0.75

		// Margins
		static let margin: CGFloat = 20.0
		static let buttonMargin: CGFloat = 54.0
		static let titleTopMargin: CGFloat = 34.0
		static let messageTopMargin: CGFloat = 24.0
		static let spacing: CGFloat = 24.0
	}

	/// The title label
	let titleLabel: Label = {

		return Label(title1: nil).multiline()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The stackview for the content
	let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fillEqually
		view.spacing = ViewTraits.spacing
		return view
	}()

	override func setupViews() {

		super.setupViews()
		headerImageView.backgroundColor = Theme.colors.lightBackground
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		contentView.addSubview(titleLabel)
		contentView.addSubview(messageLabel)
		contentView.addSubview(stackView)
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
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.messageTopMargin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),

			// StackView
			stackView.topAnchor.constraint(
				equalTo: messageLabel.bottomAnchor,
				constant: ViewTraits.margin
			),
			stackView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			stackView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			stackView.bottomAnchor.constraint(
				equalTo: contentView.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	// MARK: Public Access

	/// The onboarding title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}

	/// The onboarding message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
		}
	}
}
