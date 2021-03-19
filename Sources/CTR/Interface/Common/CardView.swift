/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class CardView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let buttonHeight: CGFloat = 42
		static let titleLineHeight: CGFloat = 28
		static let messageLineHeight: CGFloat = 22
		static let cornerRadius: CGFloat = 15
		static let messageRatio: CGFloat = UIDevice.current.isSmallScreen ? 0.8 : 0.75
		static let buttonRatio: CGFloat = 0.5
		static let shadowRadius: CGFloat = 8
		static let shadowOpacity: Float = 0.3
		
		// Margins
		static let textMargin: CGFloat = 16.0
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 24.0
		static let bottomMargin: CGFloat = 24.0
	}
	
	/// The title label
	private let titleLabel: Label = {
		
		return Label(title3: nil, montserrat: true).multiline()
	}()
	
	/// The message label
	let messageLabel: Label = {
		
		return Label(bodyMedium: nil).multiline()
	}()
	
	/// the scan button
	private let primaryButton: Button = {
		
		let button = Button(title: "Button 1", style: .secondary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.rounded = true
		return button
	}()
	
	let backgroundImageView: UIImageView = {
		
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .bottomRight
		view.clipsToBounds = true
		return view
	}()
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		layer.cornerRadius = ViewTraits.cornerRadius
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		
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
		addSubview(messageLabel)
		addSubview(primaryButton)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		
		NSLayoutConstraint.activate([
			
			// BackgroundImage
			backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
			backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
			backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
			backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
			
			// Primary Button
			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
//			primaryButton.widthAnchor.constraint(
//				equalTo: widthAnchor,
//				multiplier: ViewTraits.buttonRatio
//			),
			primaryButton.widthAnchor.constraint(
				greaterThanOrEqualTo: widthAnchor,
				multiplier: ViewTraits.buttonRatio
			),
			primaryButton.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.bottomMargin
			),
			
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
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.textMargin
			),
			
			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.widthAnchor.constraint(
				equalTo: widthAnchor,
				multiplier: ViewTraits.messageRatio
			),
			messageLabel.bottomAnchor.constraint(
				equalTo: primaryButton.topAnchor,
				constant: -40
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
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}
	
	/// The  message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
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
