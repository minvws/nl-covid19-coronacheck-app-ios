/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class MessageCardView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let shadowRadius: CGFloat = 24
		static let shadowOpacity: Float = 0.15
		static let buttonSize: CGFloat = 40
		static let imageWidth: CGFloat = 30
		static let imageHeight: CGFloat = 32

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

        return Label(body: nil).multiline().header()
	}()

	/// The close button
	private let closeButton: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(.smallCross, for: .normal)
		return button
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = .white
		layer.cornerRadius = ViewTraits.cornerRadius
		createShadow()
		closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
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
		addSubview(closeButton)
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
			expiredImageView.widthAnchor.constraint(equalToConstant: ViewTraits.imageWidth),
			expiredImageView.heightAnchor.constraint(equalToConstant: ViewTraits.imageHeight),
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
			),

			closeButton.topAnchor.constraint(equalTo: topAnchor),
			closeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
			closeButton.widthAnchor.constraint(equalToConstant: ViewTraits.buttonSize),
			closeButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonSize)
		])
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()
		// Button
		closeButton.accessibilityLabel = .close
	}

	/// User tapped on the close button
	@objc func closeButtonTapped() {

		closeButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	/// The user tapped on the close button
	var closeButtonTappedCommand: (() -> Void)?
}
