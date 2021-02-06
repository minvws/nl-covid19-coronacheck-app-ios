/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class OnboardingPageView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22
		
		// Margins
		static let margin: CGFloat = 20.0
	}

	/// The container for centering the image
	private let imageContainerView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The image view
	private let imageView: UIImageView = {
		
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		return view
	}()
	
	/// The title label
	private let titleLabel: Label = {
		
		return Label(title1: nil).multiline()
	}()
	
	/// The message label
	let messageLabel: Label = {
		
		return Label(body: nil).multiline()
	}()

	let consentButton: ConsentButton = {

		let button = ConsentButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		return button
	}()

	var messageBottomConstraintWithConsent: NSLayoutConstraint?
	var messageBottomConstraintWithoutConsent: NSLayoutConstraint?
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		imageContainerView.addSubview(imageView)
		addSubview(imageContainerView)
		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(consentButton)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([

			// ImageContainer
			imageContainerView.topAnchor.constraint(equalTo: topAnchor),
			imageContainerView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),
			imageContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			imageContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),

			// Image
			imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
			imageView.leadingAnchor.constraint(
				equalTo: imageContainerView.leadingAnchor,
				constant: ViewTraits.margin),
			imageView.trailingAnchor.constraint(
				equalTo: imageContainerView.trailingAnchor,
				constant: -ViewTraits.margin
			),

			// Title
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			titleLabel.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: UIDevice.current.isSmallScreen ? 0 : -ViewTraits.margin
			),

			// Message
			messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

			// Consent Button
			consentButton.leadingAnchor.constraint(equalTo: leadingAnchor),
			consentButton.trailingAnchor.constraint(equalTo: trailingAnchor),
			consentButton.bottomAnchor.constraint(equalTo: bottomAnchor)
		])

		messageBottomConstraintWithoutConsent = messageLabel.bottomAnchor.constraint(
			equalTo: bottomAnchor,
			constant: -ViewTraits.margin
		)
		messageBottomConstraintWithConsent = messageLabel.bottomAnchor.constraint(
			equalTo: consentButton.topAnchor,
			constant: -ViewTraits.margin
		)
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

	/// The onboarding mage
	var image: UIImage? {
		didSet {
			imageView.image = image
		}
	}

	/// Underline part ot the message
	/// - Parameter text: the text to underline
	func underline(_ text: String?) {

		guard let underlinedText = text,
			  let messageText = message else {
			return
		}

		let attributedUnderlined = messageText.underline(underlined: underlinedText, with: Theme.colors.iosBlue)
		messageLabel.attributedText = attributedUnderlined.setLineHeight(ViewTraits.messageLineHeight)
	}

	var consent: String? {
		didSet {
			consentButton.setTitle(consent, for: .normal)
			if consent != nil {
				messageBottomConstraintWithConsent?.isActive = true
				consentButton.isHidden = false
			} else {
				messageBottomConstraintWithoutConsent?.isActive = true
				consentButton.isHidden = true
			}
		}
	}
}
