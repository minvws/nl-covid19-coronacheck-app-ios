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
		stackViewInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
		scrollView.bounces = false
		titleLabel.textAlignment = .center
		messageLabel.textAlignment = .center
		primaryButton.style = .secondary
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		checkIdentityView.alpha = 0
		footerBackground.alpha = 0
		footerGradientView.alpha = 0
		lineView.alpha = 0
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		contentView.addSubview(imageView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(messageLabel)
		contentView.addSubview(debugLabel)
		contentView.addSubview(spacer)
		contentView.addSubview(checkIdentityView)
		stackView.addArrangedSubview(contentView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		setupPrimaryButton()

		// disable the bottom constraint of the scroll view, add our own
		bottomScrollViewConstraint?.isActive = false

		NSLayoutConstraint.activate([

			// Scroll View
			scrollView.bottomAnchor.constraint(equalTo: footerBackground.topAnchor),

			// Image
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
			imageView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.imageMargin + ViewTraits.margin
			),
			imageView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.imageMargin - ViewTraits.margin
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

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),

			// Message
			checkIdentityView.topAnchor.constraint(
				equalTo: contentView.topAnchor,
				constant: ViewTraits.margin
			),
			checkIdentityView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor
			),
			checkIdentityView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor
			),
			checkIdentityView.bottomAnchor.constraint(
				equalTo: contentView.bottomAnchor,
				constant: 200
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

		footerBackground.alpha = 0
		footerGradientView.alpha = 0
		messageTopConstraint?.constant = ViewTraits.verifiedMessageMargin
		messageLabel.font = Theme.fonts.body
		primaryButton.style = .primary
		primaryButton.alpha = 0
	}

	func setupForDenied() {

		footerBackground.alpha = 100
		footerGradientView.alpha = 100
		messageTopConstraint?.constant = 2 * ViewTraits.margin
		messageLabel.font = Theme.fonts.title3Medium
		primaryButton.style = .secondary
		primaryButton.alpha = 100
	}

	func revealIdentityView(_ onCompletion: (() -> Void)? = nil) {

		UIView.animate(withDuration: 0.5, delay: 0.8, options: .curveLinear) {
			self.primaryButton.alpha = 100
			self.checkIdentityView.alpha = 100
			self.footerBackground.alpha = 100
			self.footerGradientView.alpha = 100
		} completion: { _ in
			onCompletion?()
		}
	}
}
