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

	var securityViewBottomConstraint: NSLayoutConstraint?

	/// The spinner
	let spinner: UIActivityIndicatorView = {

		let view = UIActivityIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 13.0, *) {
			view.style = .large
		} else {
			view.style = .whiteLarge
		}
		view.color = Theme.colors.primary
		view.hidesWhenStopped = true
		return view
	}()

	/// The image view for the QR image
	internal let largeQRimageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The security features
	let securityView: SecurityFeaturesView = {

		let view = SecurityFeaturesView()
		view.contentMode = .bottom
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		spinner.startAnimating()
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(securityView)
		addSubview(spinner)
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

			spinner.centerYAnchor.constraint(equalTo: largeQRimageView.centerYAnchor),
			spinner.centerXAnchor.constraint(equalTo: largeQRimageView.centerXAnchor),

			// Security
			securityView.leadingAnchor.constraint(equalTo: leadingAnchor),
			securityView.trailingAnchor.constraint(equalTo: trailingAnchor),
			securityView.heightAnchor.constraint(equalTo: securityView.widthAnchor)
		])

		securityViewBottomConstraint = securityView.bottomAnchor.constraint(
			equalTo: bottomAnchor,
			constant: ViewTraits.securityMargin
		)
		securityViewBottomConstraint?.isActive = true

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
			qrImage == nil ? spinner.startAnimating() : spinner.stopAnimating()
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

	func setupForInternational() {

		securityView.setupForInternational()
		securityViewBottomConstraint?.constant = 46
	}
}
