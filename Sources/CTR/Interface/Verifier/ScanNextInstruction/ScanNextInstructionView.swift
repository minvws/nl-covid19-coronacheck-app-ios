/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

final class ScanNextInstructionView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 24
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let subtitleToTitle: CGFloat = 16
			static let titleToHeader: CGFloat = 24
		}
		enum Subtitle {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
		enum Header {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
	}
	
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	private let subtitleLabel: Label = {
		return Label(bodySemiBold: nil).multiline().header()
	}()
	
	private let titleLabel: Label = {
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	private let headerLabel: Label = {
		return Label(body: nil).multiline()
	}()
	
	let footerButtonView: FooterButtonView = {
		let view = FooterButtonView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let secondaryButton: Button = {
		
		return Button(style: .roundedBlueBorder)
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
		secondaryButton.touchUpInside(self, action: #selector(noProofAvailableTapped))
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(scrollView)
		addSubview(footerButtonView)
		scrollView.addSubview(subtitleLabel)
		scrollView.addSubview(titleLabel)
		scrollView.addSubview(headerLabel)
		footerButtonView.buttonStackView.insertArrangedSubview(secondaryButton, at: 0)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			scrollView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			
			footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
			footerButtonView.leftAnchor.constraint(equalTo: leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			subtitleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor,
											   constant: ViewTraits.Margin.top),
			subtitleLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor,
												constant: ViewTraits.Margin.edge),
			subtitleLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor,
												 constant: -ViewTraits.Margin.edge),
			subtitleLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
												 constant: -2 * ViewTraits.Margin.edge),
			
			titleLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor,
											constant: ViewTraits.Spacing.subtitleToTitle),
			titleLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor,
											 constant: ViewTraits.Margin.edge),
			titleLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor,
											  constant: -ViewTraits.Margin.edge),
			titleLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
											  constant: -2 * ViewTraits.Margin.edge),
			
			headerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
											 constant: ViewTraits.Spacing.titleToHeader),
			headerLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor,
											  constant: ViewTraits.Margin.edge),
			headerLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor,
											   constant: -ViewTraits.Margin.edge),
			headerLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
											   constant: -2 * ViewTraits.Margin.edge),
			headerLabel.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor,
												constant: -ViewTraits.Margin.edge)
		])
	}
	
	@objc private func noProofAvailableTapped() {
		
		noProofAvailableCommand?()
	}
	
	// MARK: Public Access
	
	var subtitle: String? {
		didSet {
			subtitleLabel.attributedText = subtitle?.setLineHeight(ViewTraits.Subtitle.lineHeight,
																   kerning: ViewTraits.Subtitle.kerning)
		}
	}
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Title.lineHeight,
															 kerning: ViewTraits.Title.kerning)
		}
	}
	
	var header: String? {
		didSet {
			headerLabel.attributedText = header?.setLineHeight(ViewTraits.Header.lineHeight,
															   kerning: ViewTraits.Header.kerning)
		}
	}
	
	var primaryTitle: String? {
		didSet {
			footerButtonView.primaryTitle = primaryTitle
		}
	}
	
	var secondaryTitle: String? {
		didSet {
			secondaryButton.title = secondaryTitle
		}
	}
	
	var noProofAvailableCommand: (() -> Void)?
}
