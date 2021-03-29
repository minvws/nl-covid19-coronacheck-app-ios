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
		static let messageRatio: CGFloat = UIDevice.current.isSmallScreen ? 1 : 0.75
		static let buttonRatio: CGFloat = UIDevice.current.isLandscape ? 0.3 : 0.5
		static let shadowRadius: CGFloat = 6
		static let shadowOpacity: Float = 0.4
		
		// Margins
		static let textMargin: CGFloat = 16.0
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 24.0
		static let bottomMargin: CGFloat = 24.0
		static let buttonMargin: CGFloat = 32.0
	}
	
	/// The title label
	private let titleLabel: Label = {
		
		return Label(title3: nil, montserrat: true).multiline()
	}()
	
	/// The message label
	let messageLabel: Label = {
		
		return Label(bodyMedium: nil).multiline()
	}()

	let contentView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.clipsToBounds = true
		view.layer.cornerRadius = ViewTraits.cornerRadius
		return view
	}()

	let gradientView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.clipsToBounds = true
		view.layer.cornerRadius = ViewTraits.cornerRadius
		return view
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
		view.layer.cornerRadius = ViewTraits.cornerRadius
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

		contentView.embed(in: self)

		contentView.addSubview(backgroundImageView)
		contentView.addSubview(gradientView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(messageLabel)
		contentView.addSubview(primaryButton)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		
		NSLayoutConstraint.activate([

			// Background image
			backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

			gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
			gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

			// Primary Button
			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight),
			primaryButton.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			primaryButton.widthAnchor.constraint(
				greaterThanOrEqualTo: contentView.widthAnchor,
				multiplier: ViewTraits.buttonRatio
			),
			primaryButton.widthAnchor.constraint(
				lessThanOrEqualTo: contentView.widthAnchor
			),
			primaryButton.bottomAnchor.constraint(
				equalTo: contentView.bottomAnchor,
				constant: -ViewTraits.bottomMargin
			),
			
			// Title
			titleLabel.topAnchor.constraint(
				equalTo: contentView.topAnchor,
				constant: ViewTraits.topMargin
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
				constant: -ViewTraits.textMargin
			),
			
			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.widthAnchor.constraint(
				equalTo: titleLabel.widthAnchor,
				multiplier: ViewTraits.messageRatio
			),
			messageLabel.bottomAnchor.constraint(
				equalTo: primaryButton.topAnchor,
				constant: -ViewTraits.buttonMargin
			)
		])
	}

	private func setupGradient() {

		guard let color = color else {
			return
		}

		gradientView.backgroundColor = .clear
		let gradient = CAGradientLayer()
		gradient.frame = contentView.bounds
		// horizontal
		gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
		gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
		// 100% at midway
		gradient.colors = [
			color.withAlphaComponent(1.0).cgColor,
			color.withAlphaComponent(1.0).cgColor,
			color.withAlphaComponent(0.0).cgColor
		]
		gradientView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
		gradientView.layer.insertSublayer(gradient, at: 0)
	}

	override func layoutSubviews() {

		super.layoutSubviews()

		setupGradient()
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

	var color: UIColor? {
		didSet {
			backgroundColor = color
			setupGradient()
		}
	}
	
	// MARK: Public Access
	
	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?
}
