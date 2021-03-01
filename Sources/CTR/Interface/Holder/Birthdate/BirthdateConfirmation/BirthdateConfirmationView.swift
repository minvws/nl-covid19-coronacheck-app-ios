/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ConfirmationView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let titleLineHeight: CGFloat = 28
		static let cornerRadius: CGFloat = 15
		static let iconSize: CGFloat = 35

		// Margins
		static let margin: CGFloat = 20.0
		static let buttonMargin: CGFloat = 47.0
		static let imageMargin: CGFloat = 24.0
		static let primaryButtonMargin: CGFloat = 64.0
	}

	private let containerView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The image view
	private let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.image = .check
		return view
	}()

	/// The title label
	private let titleLabel: Label = {

		return Label(title3: nil, montserrat: true).multiline()
	}()

	/// the update button
	let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()

	override func setupViews() {

		super.setupViews()

		containerView.backgroundColor = Theme.colors.viewControllerBackground
		backgroundColor = UIColor.black.withAlphaComponent(0.3)
		containerView.layer.cornerRadius = ViewTraits.cornerRadius
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(containerView)
		containerView.addSubview(imageView)
		containerView.addSubview(titleLabel)
		containerView.addSubview(primaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			imageView.widthAnchor.constraint(equalToConstant: ViewTraits.iconSize),
			imageView.heightAnchor.constraint(equalToConstant: ViewTraits.iconSize),
			imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
			imageView.bottomAnchor.constraint(
				equalTo: titleLabel.topAnchor,
				constant: -ViewTraits.imageMargin
			),

			// Title
			titleLabel.leadingAnchor.constraint(
				equalTo: containerView.leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: containerView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

			// Primary Button
			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.leadingAnchor.constraint(
				equalTo: containerView.leadingAnchor,
				constant: ViewTraits.buttonMargin
			),
			primaryButton.trailingAnchor.constraint(
				equalTo: containerView.trailingAnchor,
				constant: -ViewTraits.buttonMargin
			),
			primaryButton.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: ViewTraits.primaryButtonMargin
			),
			primaryButton.bottomAnchor.constraint(
				equalTo: containerView.bottomAnchor,
				constant: 2 * -ViewTraits.margin
			),

			// Container view
			containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
			containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
			containerView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: 2 * ViewTraits.margin
			),
			containerView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: 2 * -ViewTraits.margin
			)
		])
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The  title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight, alignment: .center)
		}
	}

	/// The primary button title
	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}
	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?
}

class BirthdateConfirmationView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let titleLineHeight: CGFloat = 26

		// Margins
		static let margin: CGFloat = 20.0
		static let titleTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 34.0
		static let messageTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 24.0
	}

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline()
	}()

	/// The message label
	private let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	let consentButton: ConsentButton = {

		let button = ConsentButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	/// the update button
	let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()

	/// the update button
	let secondaryButton: Button = {

		let button = Button(title: "Button 1", style: .secondary)
		button.rounded = true
		button.setTitleColor(Theme.colors.primary, for: .normal)
		button.titleLabel?.font = Theme.fonts.bodySemiBold
		return button
	}()

	let confirmationView: ConfirmationView = {

		let view = ConfirmationView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(consentButton)
		addSubview(primaryButton)
		addSubview(secondaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.titleTopMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.messageTopMargin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

			// Consent Button
			consentButton.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			consentButton.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			consentButton.bottomAnchor.constraint(
				equalTo: primaryButton.topAnchor,
				constant: -ViewTraits.margin
			),

			// Primary Button
			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: 2 * ViewTraits.margin
			),
			primaryButton.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: 2 * -ViewTraits.margin
			),
			primaryButton.bottomAnchor.constraint(
				equalTo: secondaryButton.topAnchor,
				constant: -ViewTraits.margin
			),

			// Secondary Button
			secondaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			secondaryButton.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			secondaryButton.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			secondaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	/// User tapped on the secondary button
	@objc func secondaryButtonTapped() {

		secondaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The  title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}

	/// The  message
	var message: NSAttributedString? {
		didSet {
			messageLabel.attributedText = message
		}
	}

	var consent: String? {
		didSet {
			consentButton.setTitle(consent, for: .normal)
		}
	}

	/// The primary button title
	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	/// The secondary button title
	var secondaryTitle: String = "" {
		didSet {
			secondaryButton.setTitle(secondaryTitle, for: .normal)
		}
	}

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	/// The user tapped on the secondary button
	var secondaryButtonTappedCommand: (() -> Void)?
}
