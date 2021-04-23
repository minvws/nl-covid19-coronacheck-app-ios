/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ResultView: ScrolledStackWithButtonView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0
		static let imageMargin: CGFloat = 70.0
		static let verifiedMessageMargin: CGFloat = UIDevice.current.isSmallScreen ? 95.0 : 108.0
		static let identityTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 20.0
	}

	let contentView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

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

	/// The debug label
	let debugLabel: Label = {

		let label = Label(subhead: nil).multiline()
		label.isHidden = true
		label.layer.borderWidth = 2
		label.layer.borderColor = Theme.colors.dark.cgColor
		label.backgroundColor = Theme.colors.lightBackground.withAlphaComponent(0.9)
		label.textColor = Theme.colors.dark
		return label
	}()

	let identityView: IdentityView = {

		let view = IdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	private let spacer: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		return view
	}()

	var checkIdentityView: VerifierCheckIdentityView = {

		let view = VerifierCheckIdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	var messageTopConstraint: NSLayoutConstraint?

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		titleLabel.textAlignment = .center
		messageLabel.textAlignment = .center
		primaryButton.style = .secondary
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		checkIdentityView.alpha = 0
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		contentView.addSubview(imageView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(messageLabel)
		contentView.addSubview(identityView)
		contentView.addSubview(debugLabel)
		contentView.addSubview(spacer)
		contentView.addSubview(checkIdentityView)
		stackView.addArrangedSubview(contentView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		setupPrimaryButton()

		checkIdentityView.embed(in: contentView)

		NSLayoutConstraint.activate([

			// Image
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
			imageView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.imageMargin
			),
			imageView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.imageMargin
			),

			// Debug
			debugLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
			debugLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			debugLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: imageView.bottomAnchor,
				constant: 2 * ViewTraits.margin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),

			identityView.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: ViewTraits.identityTopMargin
			),
			identityView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),

			// Spacer
			spacer.topAnchor.constraint(equalTo: messageLabel.bottomAnchor),
			spacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			spacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			spacer.heightAnchor.constraint(equalTo: footerBackground.heightAnchor),
			spacer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])

		messageTopConstraint = messageLabel.topAnchor.constraint(
			equalTo: titleLabel.bottomAnchor,
			constant: 2 * ViewTraits.margin
		)
		messageTopConstraint?.isActive = true
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()
		// Title
		titleLabel.accessibilityTraits = .header
	}

	// MARK: Public Access

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
		messageLabel.accessibilityTraits = [.staticText, .link]
	}

	func setupForVerified() {

		identityView.isHidden = false
		messageTopConstraint?.constant = ViewTraits.verifiedMessageMargin
		messageLabel.font = Theme.fonts.body
		primaryButton.style = .primary
		primaryButton.alpha = 0

		UIView.animate(withDuration: 0.3, delay: 0.8, options: .curveLinear) {
			self.primaryButton.alpha = 100
			self.checkIdentityView.alpha = 100
		} completion: { _ in
			print("completed")
		}

	}
}
