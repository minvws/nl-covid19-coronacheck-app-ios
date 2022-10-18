/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class PolicyInformationView: ScrolledStackView {
	
	private enum ViewTraits {
		
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
		enum Tagline {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Margin {
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let tagline: CGFloat = 8
			static let title: CGFloat = 24
		}
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
		backgroundColor = C.white()
		
		// No margins on the horizontal sides to display image full width
		stackViewInset = .bottom(ViewTraits.Margin.edge)
		// Apply side margins for labels
		bottomStackView.insets(.init(top: 0,
									 leading: ViewTraits.Margin.edge,
									 bottom: 0,
									 trailing: ViewTraits.Margin.edge))
		
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
		bottomStackView.setCustomSpacing(ViewTraits.Spacing.tagline, after: taglineLabel)
		bottomStackView.addArrangedSubview(titleLabel)
		bottomStackView.setCustomSpacing(ViewTraits.Spacing.title, after: titleLabel)
		bottomStackView.addArrangedSubview(contentTextView)

		stackView.addArrangedSubview(imageView)
		stackView.addArrangedSubview(bottomStackView)
	}
	
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		
		bottomScrollViewConstraint?.isActive = false
		
		NSLayoutConstraint.activate([
			footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
			footerButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
			footerButtonView.trailingAnchor.constraint(equalTo: trailingAnchor),
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
				ViewTraits.Tagline.lineHeight,
				kerning: ViewTraits.Tagline.kerning,
				textColor: C.primaryBlue()!
			)
		}
	}
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
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
