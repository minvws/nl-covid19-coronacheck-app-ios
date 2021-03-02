/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class QRImageView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let shadowRadius: CGFloat = 8
		static let shadowOpacity: Float = 0.3

		// Margins
		static let margin: CGFloat = 24.0
		static let titleMargin: CGFloat = 4.0
		static let subTitleMargin: CGFloat = 8.0
		static let labelSidemargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 20.0
		static let imageSidemargin: CGFloat = UIDevice.current.isSmallScreen ? 20.0 : 40.0
		static let securityOffset: CGFloat = 30.0
	}

	/// The image view for the QR image
	internal let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The title label
	private let titleLabel: Label = {

		return Label(title3: nil, montserrat: true)
	}()

	/// The sub title label
	private let subTitleLabel: Label = {

		return Label(subheadMedium: nil)
	}()

	/// The message label
	private let messageLabel: Label = {

		return Label(subheadMedium: nil).multiline()
	}()

	/// The security features
	let securityView: SecurityFeaturesView = {

		let view = SecurityFeaturesView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.clipsToBounds = true
		return view
	}()

	let containerView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()

		// Fixed white background, no inverted QR in dark mode
		backgroundColor = .white
		containerView.backgroundColor = .white

		titleLabel.textAlignment = .center
		subTitleLabel.textAlignment = .center
		messageLabel.textAlignment = .center
		containerView.layer.cornerRadius = ViewTraits.cornerRadius
		createShadow()
	}

	/// Create the shadow around the view
	func createShadow() {

		// Shadow
		containerView.layer.shadowColor = Theme.colors.shadow.cgColor
		containerView.layer.shadowOpacity = ViewTraits.shadowOpacity
		containerView.layer.shadowOffset = .zero
		containerView.layer.shadowRadius = ViewTraits.shadowRadius
		// Cache Shadow
		containerView.layer.shouldRasterize = true
		containerView.layer.rasterizationScale = UIScreen.main.scale
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		containerView.addSubview(titleLabel)
		containerView.addSubview(subTitleLabel)
		containerView.addSubview(imageView)
		containerView.addSubview(messageLabel)

		addSubview(securityView)
		addSubview(containerView)
	}
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Container
			containerView.topAnchor.constraint(equalTo: topAnchor),
			containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
			containerView.bottomAnchor.constraint(
				equalTo: securityView.topAnchor,
				constant: ViewTraits.securityOffset
			),

			// Security
			securityView.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: ViewTraits.securityOffset
			),
			securityView.leadingAnchor.constraint(equalTo: leadingAnchor),
			securityView.trailingAnchor.constraint(equalTo: trailingAnchor),

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: containerView.topAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: containerView.leadingAnchor,
				constant: ViewTraits.labelSidemargin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: containerView.trailingAnchor,
				constant: -ViewTraits.labelSidemargin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: subTitleLabel.topAnchor,
				constant: -ViewTraits.titleMargin
			),

			// SubTitle
			subTitleLabel.leadingAnchor.constraint(
				equalTo: containerView.leadingAnchor,
				constant: ViewTraits.labelSidemargin
			),
			subTitleLabel.trailingAnchor.constraint(
				equalTo: containerView.trailingAnchor,
				constant: -ViewTraits.labelSidemargin
			),
			subTitleLabel.bottomAnchor.constraint(
				equalTo: imageView.topAnchor,
				constant: -ViewTraits.subTitleMargin
			),

			// QR View
			imageView.leadingAnchor.constraint(
				equalTo: containerView.leadingAnchor,
				constant: ViewTraits.imageSidemargin
			),
			imageView.trailingAnchor.constraint(
				equalTo: containerView.trailingAnchor,
				constant: -ViewTraits.imageSidemargin
			),
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
			imageView.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.margin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: containerView.leadingAnchor,
				constant: ViewTraits.labelSidemargin
			),
			messageLabel.bottomAnchor.constraint(
				equalTo: containerView.bottomAnchor,
				constant: -ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: containerView.trailingAnchor,
				constant: -ViewTraits.labelSidemargin
			)
		])
	}

	// MARK: Public Access

	/// The  title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	var subTitle: String? {
		didSet {
			subTitleLabel.text = subTitle
		}
	}

	/// The  message
	var message: String? {
		didSet {
			messageLabel.attributedText = .makeFromHtml(
				text: message,
				font: Theme.fonts.subhead,
				textColor: Theme.colors.dark,
				textAlignment: .center
			)
		}
	}

	/// The qr  image
	var qrImage: UIImage? {
		didSet {
			imageView.image = qrImage
		}
	}

	/// Hide the QR Image
	var hideQRImage: Bool = false {
		didSet {
			imageView.isHidden = hideQRImage
		}
	}

	/// Play the animation
	func play() {

		securityView.play()
	}
}
