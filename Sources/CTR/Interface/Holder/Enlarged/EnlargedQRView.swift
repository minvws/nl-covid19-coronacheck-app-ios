/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class EnlargedQRImageView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 10.0
		static let labelSidemargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 20.0
		static let messageMargin: CGFloat = UIDevice.current.isSmallScreen ? 5.0 : 24.0
		static let securityMargin: CGFloat = 38.0
	}

	/// The image view for the QR image
	internal let largeQRimageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The title label
	private let titleLabel: Label = {

		return Label(subheadMedium: nil).multiline()
	}()

	/// The message label
	private let messageLabel: Label = {

		return Label(subheadMedium: nil).multiline()
	}()

	/// The security features
	let securityView: SecurityFeaturesView = {

		let view = SecurityFeaturesView()
		view.translatesAutoresizingMaskIntoConstraints = false

		return view
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()

		// Fixed white background, no inverted QR in dark mode
		backgroundColor = .white
		titleLabel.textAlignment = .center
		messageLabel.textAlignment = .center
	}
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(securityView)
		addSubview(largeQRimageView)
		addSubview(titleLabel)
//		addSubview(messageLabel)
	}
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Message
			titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.labelSidemargin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.labelSidemargin
			),

			// QR View
			largeQRimageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			largeQRimageView.heightAnchor.constraint(equalTo: largeQRimageView.widthAnchor),
			largeQRimageView.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.margin
			),
			largeQRimageView.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.margin
			),

//			// Message
//			messageLabel.topAnchor.constraint(
//				equalTo: largeQRimageView.bottomAnchor,
//				constant: ViewTraits.messageMargin
//			),
//			messageLabel.leadingAnchor.constraint(
//				equalTo: leadingAnchor,
//				constant: ViewTraits.labelSidemargin
//			),
//			messageLabel.trailingAnchor.constraint(
//				equalTo: trailingAnchor,
//				constant: -ViewTraits.labelSidemargin
//			),

			// Security
			securityView.leadingAnchor.constraint(equalTo: leadingAnchor),
			securityView.trailingAnchor.constraint(equalTo: trailingAnchor),
			securityView.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: ViewTraits.securityMargin
			)
		])
	}

	// MARK: Public Access

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

	/// The title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	/// The qr  image
	var qrImage: UIImage? {
		didSet {
			largeQRimageView.image = qrImage
		}
	}

	/// Hide the QR Image
	var hideQRImage: Bool = false {
		didSet {
			largeQRimageView.isHidden = hideQRImage
		}
	}

	/// Play the animation
	func play() {

		securityView.play()
	}
}
