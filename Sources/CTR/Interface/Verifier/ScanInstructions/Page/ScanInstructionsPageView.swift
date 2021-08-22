/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanInstructionsPageView: ScrolledStackView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let titleLineHeight: CGFloat = 32
		static let titleKerning: CGFloat = -0.26
		static let imageHeightPercentage: CGFloat = 0.38
		
		// Margins
		static let spacing: CGFloat = 24
		static let marginBeneathImage: CGFloat = 60
	}
	
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

	/// "Step 2" etc, above the title.
	private let stepSubheadingLabel: Label = {
		let label = Label("", font: Theme.fonts.bodySemiBold, textColor: Theme.colors.primary)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let titleLabel: Label = {
		
        return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	let messageTextView: TextView = {
		
        return TextView()
	}()
	
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}
	
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()

		bottomStackView.addArrangedSubview(stepSubheadingLabel)
		bottomStackView.setCustomSpacing(8, after: stepSubheadingLabel)
		bottomStackView.addArrangedSubview(titleLabel)
		bottomStackView.addArrangedSubview(messageTextView)

		stackView.addArrangedSubview(imageView)
		stackView.setCustomSpacing(ViewTraits.marginBeneathImage, after: imageView)
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

	var stepSubheading: String? {
		didSet {
			stepSubheadingLabel.text = stepSubheading
		}
	}

	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}
	
	var message: String? {
		didSet {
			messageTextView.attributedText = .makeFromHtml(
				text: message,
				font: Theme.fonts.body,
				textColor: Theme.colors.dark
			)
		}
	}
	
	var image: UIImage? {
		didSet {
			imageView.image = image
		}
	}

	func hideImage() {

		imageView.isHidden = true
	}

	func showImage() {

		imageView.isHidden = false
	}
}
