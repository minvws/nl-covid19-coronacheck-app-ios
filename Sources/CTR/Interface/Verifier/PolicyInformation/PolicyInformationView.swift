/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class PolicyInformationView: ScrolledStackView {
	
	private enum ViewTraits {
		
		// Dimensions
		static let titleLineHeight: CGFloat = 32
		static let titleKerning: CGFloat = -0.26
		static let imageHeightPercentage: CGFloat = 0.38
		static let taglineLineHeight: CGFloat = 22
		static let taglineKerning: CGFloat = -0.41
		static let topMargin: CGFloat = 0
		static let margin: CGFloat = 20
		
		// Margins
		static let taglineSpacing: CGFloat = 8
		static let titleSpacing: CGFloat = 24
	}
	
	/// The image view
	private let imageView: UIImageView = {
		
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		view.backgroundColor = C.forcedInformationImage()
		return view
	}()
	
	private let bottomStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .leading
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
	
	let footerButtonView: FooterButtonView = {
		
		let view = FooterButtonView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		
		// No margins on the horizontal sides to display image full width
		stackViewInset = UIEdgeInsets(top: ViewTraits.topMargin,
									  left: 0,
									  bottom: ViewTraits.margin,
									  right: 0)
		// Apply side margins for labels
		bottomStackView.insets(.init(top: 0,
									 leading: ViewTraits.margin,
									 bottom: 0,
									 trailing: ViewTraits.margin))
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		addSubview(footerButtonView)

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
		
		bottomScrollViewConstraint?.isActive = false
		
		NSLayoutConstraint.activate([
			footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
			footerButtonView.leftAnchor.constraint(equalTo: leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	var image: UIImage? {
		didSet {
			imageView.image = image
		}
	}
	
	var tagline: String? {
		didSet {
			taglineLabel.attributedText = tagline?.setLineHeight(
				ViewTraits.taglineLineHeight,
				kerning: ViewTraits.taglineKerning,
				textColor: Theme.colors.primary
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
			contentTextView.attributedText = .makeFromHtml(text: content, style: .bodyDark)
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
