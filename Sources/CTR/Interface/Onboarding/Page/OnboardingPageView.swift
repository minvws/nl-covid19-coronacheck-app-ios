/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class OnboardingPageView: ScrolledStackView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let titleLineHeight: CGFloat = 32
		static let titleKerning: CGFloat = -0.26
		static let imageHeightPercentage: CGFloat = 0.38
		
		// Margins
		static let spacing: CGFloat = 24
	}
	
	/// The image view
	private let imageView: UIImageView = {
		
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		return view
	}()

	private let bottomStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .leading
		view.distribution = .fill
		view.spacing = ViewTraits.spacing
		return view
	}()

	/// The title label
	private let titleLabel: Label = {
		
        return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	/// The message text
	let messageTextView: TextView = {
		
        return TextView()
	}()
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()

		bottomStackView.addArrangedSubview(titleLabel)
		bottomStackView.addArrangedSubview(messageTextView)

		stackView.addArrangedSubview(imageView)
		stackView.addArrangedSubview(bottomStackView)
	}

	override func setupViewConstraints() {
		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			imageView.heightAnchor.constraint(
				lessThanOrEqualTo: heightAnchor,
				multiplier: ViewTraits.imageHeightPercentage
			)
		])
	}

	// MARK: Public Access
	
	/// The onboarding title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}
	
	/// The onboarding message
	var message: String? {
		didSet {
			messageTextView.attributedText = .makeFromHtml(
				text: message,
				font: Theme.fonts.body,
				textColor: Theme.colors.dark
			)
		}
	}
	
	/// The onboarding mage
	var image: UIImage? {
		didSet {
			imageView.image = image
		}
	}

	/// Hide the image
	func hideImage() {

		imageView.isHidden = true
	}

	/// Show the image
	func showImage() {
		
		imageView.isHidden = false
	}
}
