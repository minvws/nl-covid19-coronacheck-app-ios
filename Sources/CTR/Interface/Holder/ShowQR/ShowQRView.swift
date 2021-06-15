/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class ShowQRImageView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 10.0
		static let securityMargin: CGFloat = 38.0
	}

	/// The image view for the QR image
	internal let largeQRimageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
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
	}
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(securityView)
		addSubview(largeQRimageView)
	}
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// QR View
			largeQRimageView.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.margin
			),
			largeQRimageView.heightAnchor.constraint(equalTo: largeQRimageView.widthAnchor),
			largeQRimageView.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.margin
			),
			largeQRimageView.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.margin
			),

			// Security
			securityView.leadingAnchor.constraint(equalTo: leadingAnchor),
			securityView.trailingAnchor.constraint(equalTo: trailingAnchor),
			securityView.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: ViewTraits.securityMargin
			)
		])

		bringSubviewToFront(largeQRimageView)
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()

        largeQRimageView.isAccessibilityElement = true
        largeQRimageView.accessibilityTraits = .image
        
        accessibilityElements = [largeQRimageView]
	}

	// MARK: Public Access

	/// The qr  image
	var qrImage: UIImage? {
		didSet {
			largeQRimageView.image = qrImage
		}
	}

	/// The accessibility description
	var accessibilityDescription: String? {
		didSet {
            largeQRimageView.accessibilityLabel = accessibilityDescription
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

	/// Resume the animation
	func resume() {

		securityView.resume()
	}
}
