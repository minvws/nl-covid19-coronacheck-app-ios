/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class OnboardingView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22
		
		// Margins
		static let margin: CGFloat = 20.0
		static let ribbonOffset: CGFloat = 15.0
		static let buttonWidth: CGFloat = 182.0
		static let pageControlMargin: CGFloat = 12.0
	}
	
	private let ribbonView: UIImageView = {
		
		let view = UIImageView(image: .ribbon)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let imageContainerView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
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
	private let messageLabel: Label = {
		
		return Label(body: nil).multiline()
	}()
	
	let pageControl: UIPageControl = {
		
		let view = UIPageControl()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		view.pageIndicatorTintColor = Theme.colors.gray.withAlphaComponent(0.3)
		view.currentPageIndicatorTintColor = Theme.colors.gray
		return view
	}()
	
	/// the update button
	let primaryButton: Button = {
		
		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = .white
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(ribbonView)
		imageContainerView.addSubview(imageView)
		addSubview(imageContainerView)
		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(pageControl)
		addSubview(primaryButton)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			// Ribbon
			ribbonView.centerXAnchor.constraint(equalTo: centerXAnchor),
			ribbonView.topAnchor.constraint(
				equalTo: topAnchor,
				constant: UIDevice.current.hasNotch ? ViewTraits.ribbonOffset : -ViewTraits.ribbonOffset
			),

			// ImageContainer
			imageContainerView.topAnchor.constraint(equalTo: ribbonView.bottomAnchor),
			imageContainerView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),
			imageContainerView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin),
			imageContainerView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

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
				constant: -ViewTraits.margin
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

			// Button
			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			primaryButton.widthAnchor.constraint(equalToConstant: ViewTraits.buttonWidth),
			primaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		// Layout page control when the view has a frame
		NSLayoutConstraint.activate([

			// Message
			messageLabel.bottomAnchor.constraint(
				equalTo: pageControl.topAnchor,
				constant: UIDevice.current.isSmallScreen ? 0 : -ViewTraits.margin
			),

			// Page Control
			pageControl.bottomAnchor.constraint(
				equalTo: primaryButton.topAnchor,
				constant: UIDevice.current.isSmallScreen ? 0 : -ViewTraits.pageControlMargin),
			pageControl.centerXAnchor.constraint(equalTo: centerXAnchor)
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

	/// The onboarding mage
	var image: UIImage? {
		didSet {
			imageView.image = image
		}
	}

	func underline(_ text: String?) {

		guard let underlinedText = text,
			  let messageText = message else {
			return
		}

		let attributedUnderlined = messageText.underline(underlined: underlinedText, with: Theme.colors.iosBlue)
		messageLabel.attributedText = attributedUnderlined.setLineHeight(ViewTraits.messageLineHeight)
	}
}
