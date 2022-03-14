/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DeniedAccessView: BaseView {
	
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 4
			static let secondaryButtonBottom: CGFloat = 8
			static let horizontal: CGFloat = 32
		}
		enum Spacing {
			static let views: CGFloat = UIDevice.current.isSmallScreen ? 24 : 40
		}
		enum Size {
			static let imageWidth: CGFloat = 200
			static let buttonHeight: CGFloat = 52
			static let buttonWidth: CGFloat = 234.0
		}
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
	}
	
	/// The scrollview
	private let scrollView: ScrolledContentHeightView = {

		let view = ScrolledContentHeightView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The stackview for the content
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.spacing = ViewTraits.Spacing.views
		return view
	}()
	
	private let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		view.image = I.denied()
		return view
	}()
	
	private let titleLabel: Label = {

		let label = Label(title1: nil, montserrat: true).multiline().header()
		label.textColor = C.black()
		return label
	}()
	
	let secondaryButton: Button = {

		let button = Button(style: .roundedClear)
		button.titleLabel?.textAlignment = .center
		return button
	}()
	
	let footerButtonView: FooterButtonView = {
		
		let footerView = FooterButtonView()
		footerView.translatesAutoresizingMaskIntoConstraints = false
		return footerView
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.denied
		scrollView.backgroundColor = Theme.colors.denied
		footerButtonView.primaryButton.style = .roundedWhite
		footerButtonView.backgroundColor = Theme.colors.denied
		secondaryButton.touchUpInside(self, action: #selector(readMoreTapped))
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(scrollView)
		scrollView.contentView.addSubview(stackView)
		scrollView.contentView.addSubview(secondaryButton)
		addSubview(footerButtonView)
		stackView.addArrangedSubview(imageView)
		stackView.addArrangedSubview(titleLabel)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			scrollView.topAnchor.constraint(equalTo: topAnchor),
			scrollView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			scrollView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			scrollView.bottomAnchor.constraint(equalTo: footerButtonView.topAnchor),
			
			stackView.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor),
			stackView.leftAnchor.constraint(equalTo: scrollView.contentView.leftAnchor, constant: ViewTraits.Margin.horizontal),
			stackView.rightAnchor.constraint(equalTo: scrollView.contentView.rightAnchor, constant: -ViewTraits.Margin.horizontal),
			
			{
				let constraint = imageView.widthAnchor.constraint(equalToConstant: ViewTraits.Size.imageWidth)
				constraint.priority = .defaultLow
				return constraint
			}(),
			
			secondaryButton.topAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: ViewTraits.Spacing.views),
			secondaryButton.leftAnchor.constraint(equalTo: footerButtonView.buttonStackView.leftAnchor),
			secondaryButton.rightAnchor.constraint(equalTo: footerButtonView.buttonStackView.rightAnchor),
			secondaryButton.centerXAnchor.constraint(equalTo: scrollView.contentView.centerXAnchor),
			secondaryButton.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor, constant: -ViewTraits.Margin.secondaryButtonBottom),
			secondaryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.Size.buttonWidth),
			secondaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.Size.buttonHeight),
						
			// Footer view
			footerButtonView.leftAnchor.constraint(equalTo: leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	@objc private func readMoreTapped() {
		
		readMoreTappedCommand?()
	}
	
	// MARK: - Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Title.lineHeight,
															 alignment: .center,
															 kerning: ViewTraits.Title.kerning)
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
			secondaryButton.isHidden = secondaryTitle == nil
		}
	}
	
	/// The user tapped on the primary button
	var scanNextTappedCommand: (() -> Void)? {
		didSet {
			footerButtonView.primaryButtonTappedCommand = scanNextTappedCommand
		}
	}

	/// The user tapped on the secondary button
	var readMoreTappedCommand: (() -> Void)?
	
	func focusAccessibility() {
		UIAccessibility.post(notification: .screenChanged, argument: self.titleLabel)
	}
}
