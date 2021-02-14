/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ExpiredQRView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let shadowRadius: CGFloat = 8
		static let shadowOpacity: Float = 0.3

		// Margins
		static let margin: CGFloat = 20.0
		static let messageTopMargin: CGFloat = 24.0
	}

	/// The expired image
	private let expiredImageView: UIImageView = {
		let view = UIImageView(image: .expiredQR)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The title label
	private let titleLabel: Label = {

		return Label(body: nil).multiline()
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = .white
		layer.cornerRadius = ViewTraits.cornerRadius
		createShadow()
	}

	/// Create the shadow around the view
	func createShadow() {

		// Shadow
		layer.shadowColor = Theme.colors.shadow.cgColor
		layer.shadowOpacity = ViewTraits.shadowOpacity
		layer.shadowOffset = .zero
		layer.shadowRadius = ViewTraits.shadowRadius
		// Cache Shadow
		layer.shouldRasterize = true
		layer.rasterizationScale = UIScreen.main.scale
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(expiredImageView)
		addSubview(titleLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Header
			expiredImageView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			expiredImageView.widthAnchor.constraint(equalToConstant: 30),
			expiredImageView.heightAnchor.constraint(equalToConstant: 32),
			expiredImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.messageTopMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: expiredImageView.trailingAnchor,
				constant: 5
			),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			titleLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.messageTopMargin
			)
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
