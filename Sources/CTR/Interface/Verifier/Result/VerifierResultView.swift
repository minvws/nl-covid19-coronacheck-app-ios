/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierResultView: ScrolledStackWithButtonView {

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

        return Label(title1: nil, montserrat: true).multiline().header()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(title3Medium: nil).multiline()
	}()

	let checkIdentityView: VerifierCheckIdentityView = {

		let view = VerifierCheckIdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private var messageTopConstraint: NSLayoutConstraint?
	private var imageHeightConstraint: NSLayoutConstraint?

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
		stackView.addArrangedSubview(contentView)
		scrollView.addSubview(checkIdentityView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		setupPrimaryButton(useFullWidth: {
			switch traitCollection.preferredContentSizeCategory {
				case .unspecified: return true
				case let size where size > .extraLarge: return true
				default: return false
			}
		}())

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
			messageLabel.bottomAnchor.constraint(
				lessThanOrEqualTo: footerBackground.topAnchor,
				constant: -ViewTraits.margin
			),
			
			// CheckIdentityView
			checkIdentityView.topAnchor.constraint(
				equalTo: scrollView.topAnchor,
				constant: stackViewInset.top
			),
			checkIdentityView.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: stackViewInset.left
			),
			checkIdentityView.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -stackViewInset.right
			),
			checkIdentityView.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -stackViewInset.bottom
			),
			checkIdentityView.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -stackViewInset.left - stackViewInset.right
			),
			checkIdentityView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
		])

		messageTopConstraint = messageLabel.topAnchor.constraint(
			equalTo: titleLabel.bottomAnchor,
			constant: 2 * ViewTraits.margin
		)
		messageTopConstraint?.isActive = true

		imageHeightConstraint = imageView.heightAnchor.constraint(
			equalTo: heightAnchor,
			multiplier: 0.3
		)
		imageHeightConstraint?.isActive = false

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
			self.contentView.alpha = 0
		} completion: { _ in
			// Make disclaimer button tappable
			self.stackView.isHidden = true
			self.accessibilityElements = [self.checkIdentityView, self.primaryButton]
			UIAccessibility.post(notification: .screenChanged, argument: self.checkIdentityView)
			onCompletion?()
		}
	}

	func layoutForOrientation() {

		if traitCollection.verticalSizeClass == .compact ||
			OrientationUtility.currentOrientation() == .landscapeLeft ||
			OrientationUtility.currentOrientation() == .landscapeRight {
			// Image should be 0.3 times the screen height in a compact vertical screen
			imageHeightConstraint?.isActive = true
		} else {
			// Image height should be bound by the width only
			imageHeightConstraint?.isActive = false
		}
	}
}
