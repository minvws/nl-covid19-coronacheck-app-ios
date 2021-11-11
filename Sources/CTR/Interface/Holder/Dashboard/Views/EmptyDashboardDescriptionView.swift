/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class EmptyDashboardDescriptionView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Spacing {
			static let messageToButton: CGFloat = 16
			static let cardToMessage: CGFloat = 32
		}
	}
	
	let contentTextView = TextView()
	
	private let cardView = EmptyStateCardView()
	
	private let button: Button = {
		let button = Button(style: .textLabelBlue)
		button.contentHorizontalAlignment = .left
		return button
	}()
		
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = ViewTraits.Spacing.cardToMessage
		return stackView
	}()
	
	// MARK: - Lifecycle

	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = .white
		
		button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(stackView)
		stackView.addArrangedSubview(contentTextView)
		stackView.addArrangedSubview(cardView)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			stackView.leftAnchor.constraint(equalTo: leftAnchor),
			stackView.rightAnchor.constraint(equalTo: rightAnchor),
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	/// Card view image
	var image: UIImage? {
		didSet {
			cardView.image = image
		}
	}
	
	/// Card view title
	var title: String? {
		didSet {
			cardView.title = title
		}
	}
	
	/// The message
	var message: String? {
		didSet {
			contentTextView.attributedText = .makeFromHtml(
				text: message,
				style: NSAttributedString.HTMLStyle(
					font: Theme.fonts.body,
					textColor: Theme.colors.dark,
					paragraphSpacing: 0
				)
			)
		}
	}
	
	/// The button title
	var buttonTitle: String? {
		didSet {
			guard button.title?.isEmpty == true, let buttonTitle = buttonTitle else { return }
			button.title = buttonTitle
			stackView.insertArrangedSubview(button, at: 1)
			stackView.setCustomSpacing(ViewTraits.Spacing.messageToButton, after: contentTextView)
		}
	}
	
	/// User tapped on the button
	@objc func onTap() {

		buttonTappedCommand?()
	}

	/// The user tapped on the button
	var buttonTappedCommand: (() -> Void)?
}

private final class EmptyStateCardView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Size {
			static let image: CGSize = CGSize(width: 56, height: 56)
		}
		enum Margins {
			static let topImage: CGFloat = 48
			static let bottomLabel: CGFloat = 40
			static let maxHorizontal: CGFloat = 20
		}
		enum Spacing {
			static let imageToLabel: CGFloat = 35
		}
		enum Radius {
			static let corner: CGFloat = 15
		}
	}
	
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	private let titleLabel: Label = {
        let label = Label(headlineBold: nil, montserrat: true).multiline().header()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Theme.colors.dark
		return label
	}()
	
	// MARK: - Lifecycle

	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.emptyDashboardColor
		layer.cornerRadius = ViewTraits.Radius.corner
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(imageView)
		addSubview(titleLabel)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			imageView.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.Margins.topImage),
			imageView.heightAnchor.constraint(equalToConstant: ViewTraits.Size.image.height),
			imageView.widthAnchor.constraint(equalToConstant: ViewTraits.Size.image.width),
			
			titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: ViewTraits.Spacing.imageToLabel),
			titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: ViewTraits.Margins.maxHorizontal),
			titleLabel.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -ViewTraits.Margins.maxHorizontal),
			titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.Margins.bottomLabel)
		])
	}
	
	/// The image
	var image: UIImage? {
		didSet {
			imageView.image = image
		}
	}
	
	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(alignment: .center)
		}
	}
}
