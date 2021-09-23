/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DeniedView: BaseView, AccessViewable {
	
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 4
			static let secondaryButtonBottom: CGFloat = 8
			static let button: CGFloat = 36
		}
		enum Spacing {
			static let views: CGFloat = UIDevice.current.isSmallScreen ? 24 : 40
		}
		enum Size {
			static let imageWidth: CGFloat = 200
			static let buttonHeight: CGFloat = 52
			static let buttonWidth: CGFloat = 234.0
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
		label.textAlignment = .center
		label.textColor = Theme.colors.dark
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
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let adjustedOffset = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.bounds.height)
			self?.footerButtonView.updateFadeAnimation(from: adjustedOffset)
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
			stackView.leftAnchor.constraint(equalTo: scrollView.contentView.leftAnchor),
			stackView.rightAnchor.constraint(equalTo: scrollView.contentView.rightAnchor),
			
			{
				let constraint = imageView.widthAnchor.constraint(equalToConstant: ViewTraits.Size.imageWidth)
				constraint.priority = .defaultLow
				return constraint
			}(),
			
			secondaryButton.topAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: ViewTraits.Spacing.views),
			secondaryButton.leftAnchor.constraint(greaterThanOrEqualTo: scrollView.contentView.leftAnchor, constant: ViewTraits.Margin.button),
			secondaryButton.rightAnchor.constraint(lessThanOrEqualTo: scrollView.contentView.rightAnchor, constant: -ViewTraits.Margin.button),
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
	
	// MARK: - AccessViewable
	
	func title(_ title: String?) {
		titleLabel.text = title
	}
	
	func primaryTitle(_ title: String?) {
		footerButtonView.primaryTitle = title
	}
	
	func secondaryTitle(_ title: String?) {
		secondaryButton.title = title
	}
}
