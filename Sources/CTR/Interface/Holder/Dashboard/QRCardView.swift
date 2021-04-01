/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class QRCardView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let buttonHeight: CGFloat = 42
		static let titleLineHeight: CGFloat = 28
		static let cornerRadius: CGFloat = 15
		static let buttonRatio: CGFloat = 0.45
		static let shadowRadius: CGFloat = 8
		static let shadowOpacity: Float = 0.3

		// Margins
		static let smallMargin: CGFloat = 8.0
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 24.0
	}
	
	/// The title label
	private let titleLabel: Label = {
		
		return Label(title3: nil, montserrat: true).multiline()
	}()

	/// The time label
	let identityLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	/// The time label
	let timeLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The message label
	let messageLabel: Label = {
		
		return Label(subhead: nil).multiline()
	}()

	/// the scan button
	private let primaryButton: Button = {
		
		let button = Button(title: "Button 1", style: .primary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.rounded = true
		return button
	}()
	
	let backgroundImageView: UIImageView = {
		
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .bottomRight
		view.clipsToBounds = true
		view.layer.cornerRadius = ViewTraits.cornerRadius
		view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		return view
	}()

	let blurView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
		view.layer.cornerRadius = ViewTraits.cornerRadius
		view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		return view
	}()
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		layer.cornerRadius = ViewTraits.cornerRadius
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		identityLabel.textColor = Theme.colors.tileGray
		backgroundColor = Theme.colors.viewControllerBackground
		
		// Shadow
		layer.shadowColor = Theme.colors.shadow.cgColor
		layer.shadowOpacity = ViewTraits.shadowOpacity
		layer.shadowOffset = .zero
		layer.shadowRadius = ViewTraits.shadowRadius
		// Cache Shadow
		layer.shouldRasterize = true
		layer.rasterizationScale = UIScreen.main.scale
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		addSubview(backgroundImageView)
		addSubview(titleLabel)
		addSubview(identityLabel)
		addSubview(timeLabel)

		blurView.addSubview(messageLabel)
		blurView.addSubview(primaryButton)

		addSubview(blurView)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		
		NSLayoutConstraint.activate([
			
			// BackgroundImage
			backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
			backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
			backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
			backgroundImageView.topAnchor.constraint(equalTo: topAnchor),

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.topMargin
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
				equalTo: identityLabel.topAnchor,
				constant: -ViewTraits.smallMargin
			),

			// Identity
			identityLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			identityLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			identityLabel.bottomAnchor.constraint(
				equalTo: timeLabel.topAnchor,
				constant: -24
			),

			// Time
			timeLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			timeLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

			// Time
			blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
			blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
			blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
			blurView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 40),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: blurView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.topAnchor.constraint(
				equalTo: blurView.topAnchor,
				constant: 19
			),

			// Primary Button
			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight),
			primaryButton.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			primaryButton.widthAnchor.constraint(
				greaterThanOrEqualTo: widthAnchor,
				multiplier: ViewTraits.buttonRatio
			),
			primaryButton.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -16
			)
		])

		setupViewConstraintsForBottomBehaviour()
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()

		// Title
		titleLabel.accessibilityTraits = .header

		// Time
		timeLabel.accessibilityTraits = .updatesFrequently
	}

	func setupViewConstraintsForBottomBehaviour() {

		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
			// Larger font size -> Show message above button
			NSLayoutConstraint.activate([
				messageLabel.trailingAnchor.constraint(
					equalTo: blurView.trailingAnchor,
					constant: -ViewTraits.margin
				),
				messageLabel.bottomAnchor.constraint(
					equalTo: primaryButton.topAnchor,
					constant: -19
				)
			])
		} else {
			// Normal font size -> Show message next to button
			NSLayoutConstraint.activate([
				messageLabel.trailingAnchor.constraint(
					equalTo: primaryButton.leadingAnchor,
					constant: -10
				),
				messageLabel.bottomAnchor.constraint(
					equalTo: bottomAnchor,
					constant: -19
				)
			])
		}
	}
	
	/// User tapped on the primary button
	@objc func primaryButtonTapped() {
		
		primaryButtonTappedCommand?()
	}
	
	// MARK: Public Access
	
	/// The  title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}
	
	/// The  message
	var message: String? {
		didSet {
			messageLabel.text = message
		}
	}

	/// The  identity
	var identity: String? {
		didSet {
			identityLabel.text = identity
		}
	}

	/// The  time
	var time: String? {
		didSet {
			timeLabel.attributedText = .makeFromHtml(
				text: time,
				font: Theme.fonts.body,
				textColor: Theme.colors.dark,
				lineHeight: 17.0
			)
		}
	}

	/// The accessibility string for the time
	var timeAccessibility: String? {
		didSet {
			timeLabel.accessibilityLabel = timeAccessibility
		}
	}

	/// The background image
	var backgroundImage: UIImage? {
		didSet {
			backgroundImageView.image = backgroundImage
		}
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
