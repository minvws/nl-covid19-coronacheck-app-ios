/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class EmptyDashboardImagePlaceholderView: BaseView {
	
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
