/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class EmptyDashboardView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Spacing {
			static let cardToMessage: CGFloat = 24
		}
	}
	
	let contentTextView = TextView()
	
	private let cardView = EmptyStateCardView()
		
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
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(stackView)
		stackView.addArrangedSubview(cardView)
		stackView.addArrangedSubview(contentTextView)
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
				font: Theme.fonts.body,
				textColor: Theme.colors.dark,
				paragraphSpacing: 0
			)
		}
	}
}

private final class EmptyStateCardView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Size {
			static let image: CGSize = CGSize(width: 111, height: 120)
		}
		enum Margins {
			static let vertical: CGFloat = 40
			static let maxHorizontal: CGFloat = 20
		}
		enum Spacing {
			static let imageToLabel: CGFloat = 24
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
		let label = Label(headlineBold: nil, montserrat: true).multiline()
		label.translatesAutoresizingMaskIntoConstraints = false
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
			imageView.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.Margins.vertical),
			imageView.heightAnchor.constraint(equalToConstant: ViewTraits.Size.image.height),
			imageView.widthAnchor.constraint(equalToConstant: ViewTraits.Size.image.width),
			
			titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: ViewTraits.Spacing.imageToLabel),
			titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: ViewTraits.Margins.maxHorizontal),
			titleLabel.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -ViewTraits.Margins.maxHorizontal),
			titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.Margins.vertical)
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
			titleLabel.text = title
		}
	}
}
