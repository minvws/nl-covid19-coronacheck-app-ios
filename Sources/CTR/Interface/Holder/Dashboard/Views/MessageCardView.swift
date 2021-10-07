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
		static let buttonSize: CGFloat = 20
		static let imageWidth: CGFloat = 30
		static let imageHeight: CGFloat = 32

		// Margins
		static let margin: CGFloat = 24.0
	}

	/// The title label
	private let titleLabel: Label = {

        return Label(body: nil).multiline().header()
	}()

	/// The info button
	private let infoButton: TappableButton = {

		let button = TappableButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(I.questionMark(), for: .normal)
		return button
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = .white
		layer.cornerRadius = ViewTraits.cornerRadius
		createShadow()
		infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
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
		addSubview(titleLabel)
		addSubview(infoButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: infoButton.leadingAnchor,
				constant: -16
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.margin
			),

			infoButton.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.margin),
			infoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.margin),
			infoButton.widthAnchor.constraint(equalToConstant: ViewTraits.buttonSize),
			infoButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonSize)
		])
	}

//	/// Setup all the accessibility traits
//	override func setupAccessibility() {
//
//		super.setupAccessibility()
//		// Button
//		infoButton.accessibilityLabel = .info
//	}

	/// User tapped on the info button
	@objc func infoButtonTapped() {

		infoButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	/// The user tapped on the info button
	var infoButtonTappedCommand: (() -> Void)?
}
