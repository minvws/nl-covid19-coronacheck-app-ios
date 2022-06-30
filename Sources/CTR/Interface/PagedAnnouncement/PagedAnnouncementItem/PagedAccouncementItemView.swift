/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PagedAnnouncementItemView: ScrolledStackView {
	
	private enum ViewTraits {
		
		// Dimensions
		static let titleLineHeight: CGFloat = 32
		static let titleKerning: CGFloat = -0.26
		static let imageHeightPercentage: CGFloat = 0.38
		static let taglineLineHeight: CGFloat = 22
		static let taglineKerning: CGFloat = -0.41
		static let margin: CGFloat = 20
		
		// Margins
		static let taglineSpacing: CGFloat = 8
		static let titleSpacing: CGFloat = 24
		
		// Insets
		static let regularStackViewInset = UIEdgeInsets(top: 48, left: margin, bottom: margin, right: margin)
		static let fullWidthHeaderImageStackViewInset = UIEdgeInsets(top: 0, left: 0, bottom: margin, right: 0)
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
		return view
	}()
	
	/// The title label
	private let titleLabel: Label = {
		
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	private let taglineLabel: Label = {
		
		return Label(bodySemiBold: nil)
	}()
	
	private let contentTextView: TextView = {
		
		return TextView()
	}()
	
	let shouldShowWithFullWidthHeaderImage: Bool
	
	init(shouldShowWithFullWidthHeaderImage: Bool = false) {
		self.shouldShowWithFullWidthHeaderImage = shouldShowWithFullWidthHeaderImage
		super.init(frame: .zero)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = C.white()
		
		if shouldShowWithFullWidthHeaderImage {
			// No margins on the horizontal sides to display image full width
			stackViewInset = ViewTraits.fullWidthHeaderImageStackViewInset
			
			// Apply side margins for labels
			bottomStackView.insets(.init(top: 0, leading: ViewTraits.margin, bottom: 0, trailing: ViewTraits.margin))
		} else {
			stackViewInset = ViewTraits.regularStackViewInset
		}
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()

		bottomStackView.addArrangedSubview(taglineLabel)
		bottomStackView.setCustomSpacing(ViewTraits.taglineSpacing, after: taglineLabel)
		bottomStackView.addArrangedSubview(titleLabel)
		bottomStackView.setCustomSpacing(ViewTraits.titleSpacing, after: titleLabel)
		bottomStackView.addArrangedSubview(contentTextView)

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
	
	var image: UIImage? {
		didSet {
			imageView.image = image
		}
	}
	
	var imageBackgroundColor: UIColor? {
		didSet {
			imageView.backgroundColor = imageBackgroundColor
		}
	}
	
	var tagline: String? {
		didSet {
			taglineLabel.attributedText = tagline?.setLineHeight(
				ViewTraits.taglineLineHeight,
				kerning: ViewTraits.taglineKerning,
				textColor: C.primaryBlue()!
			)
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
	
	var content: String? {
		didSet {
			NSAttributedString.makeFromHtml(text: content, style: .bodyDark) {
				self.contentTextView.attributedText = $0
			}
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
