/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AppointmentView: ScrollViewWithHeader {

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
	}

	/// The title label
	let titleLabel: Label = {

		return Label(title1: nil).multiline()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// the update button
	let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()

	override func setupViews() {

		super.setupViews()
		headerImageView.backgroundColor = Theme.colors.appointment
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		contentView.addSubview(titleLabel)
		contentView.addSubview(messageLabel)
		contentView.addSubview(primaryButton)
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

			// Primary Button
			primaryButton.topAnchor.constraint(
				equalTo: messageLabel.bottomAnchor,
				constant: ViewTraits.buttonMargin
			),
			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			primaryButton.widthAnchor.constraint(equalToConstant: ViewTraits.buttonWidth),
			primaryButton.bottomAnchor.constraint(
				equalTo: contentView.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
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

	/// Underline part ot the message
	/// - Parameter text: the text to underline
	func underline(_ text: String?) {

		guard let underlinedText = text,
			  let messageText = message else {
			return
		}

		let attributedUnderlined = messageText.color(text: underlinedText, with: Theme.colors.iosBlue)
		messageLabel.attributedText = attributedUnderlined.setLineHeight(ViewTraits.messageLineHeight)
	}

	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	// MARK: Public Access

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?
}
