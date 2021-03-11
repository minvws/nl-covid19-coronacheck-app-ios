/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ResultView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let buttonWidth: CGFloat = 212.0

		// Margins
		static let margin: CGFloat = 20.0
		static let imageMargin: CGFloat = 70.0
		static let verifiedMessageMargin: CGFloat = UIDevice.current.isSmallScreen ? 95.0 : 108.0
		static let identityTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 20.0
	}

	let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		return view
	}()

	/// The title label
	let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(title3Medium: nil).multiline()
	}()

	let identityView: IdentityView = {

		let view = IdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	/// the scan button
	private let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .secondary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.rounded = true
		return button
	}()

	var messageTopConstraint: NSLayoutConstraint?

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		titleLabel.textAlignment = .center
		messageLabel.textAlignment = .center
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(imageView)
		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(identityView)
		addSubview(primaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		NSLayoutConstraint.activate([

			// Image
			imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
			imageView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.imageMargin
			),
			imageView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.imageMargin
			),

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: imageView.bottomAnchor,
				constant: 2 * ViewTraits.margin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

			identityView.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: ViewTraits.identityTopMargin
			),
			identityView.centerXAnchor.constraint(equalTo: centerXAnchor),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

			// Button
			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			primaryButton.widthAnchor.constraint(equalToConstant: ViewTraits.buttonWidth),
			primaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])

		messageTopConstraint = messageLabel.topAnchor.constraint(
			equalTo: titleLabel.bottomAnchor,
			constant: 2 * ViewTraits.margin
		)
		messageTopConstraint?.isActive = true
	}

	// MARK: Public Access

	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	/// The title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	/// The message
	var message: String? {
		didSet {
			messageLabel.text = message
		}
	}

	/// Underline part ot the message
	/// - Parameter text: the text to underline
	func underline(_ text: String?) {

		guard let underlinedText = text,
			  let messageText = message else {
			return
		}

		let attributedUnderlined = messageText.underline(underlined: underlinedText, with: Theme.colors.dark)
		messageLabel.attributedText = attributedUnderlined
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	func setupForVerified() {

		identityView.isHidden = false
		messageTopConstraint?.constant = ViewTraits.verifiedMessageMargin
		messageLabel.font = Theme.fonts.body
	}
}
