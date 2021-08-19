/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DeniedView: BaseView {
	
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 4
			static let secondaryButtonBottom: CGFloat = 20
			static let buttonMargin: CGFloat = 36
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
		view.image = .denied
		return view
	}()
	
	private let titleLabel: Label = {

		let label = Label(title1: nil, montserrat: true).multiline().header()
		label.textAlignment = .center
		label.textColor = Theme.colors.dark
		return label
	}()
	
	let secondaryButton: Button = {

		let button = Button()
		button.style = .roundedClear
		button.title = L.verifierResultDeniedReadmore()
		button.titleLabel?.textAlignment = .center
		return button
	}()
	
	let footerButtonView: VerifierFooterButtonView = {
		
		let footerView = VerifierFooterButtonView()
		footerView.translatesAutoresizingMaskIntoConstraints = false
		return footerView
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.denied
		scrollView.backgroundColor = Theme.colors.denied
		footerButtonView.primaryButton.style = .roundedWhite
		footerButtonView.footerActionColor = Theme.colors.denied
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
			secondaryButton.leftAnchor.constraint(greaterThanOrEqualTo: scrollView.contentView.leftAnchor, constant: ViewTraits.Margin.buttonMargin),
			secondaryButton.rightAnchor.constraint(lessThanOrEqualTo: scrollView.contentView.rightAnchor, constant: -ViewTraits.Margin.buttonMargin),
			secondaryButton.centerXAnchor.constraint(equalTo: scrollView.contentView.centerXAnchor),
			secondaryButton.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor, constant: -ViewTraits.Margin.secondaryButtonBottom),
			secondaryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.Size.buttonWidth),
			secondaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.Size.buttonHeight),
						
			// Footer view
			footerButtonView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}
}
