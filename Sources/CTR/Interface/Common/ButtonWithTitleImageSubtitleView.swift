/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ButtonWithTitleImageSubtitle: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 9
		static let shadowRadius: CGFloat = 6
		static let shadowOpacity: Float = 0.2

		// Margins
		static let textMargin: CGFloat = 18.0
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 16.0
		static let leadingMargin: CGFloat = 16.0
	}

	/// The icon view
	let iconView: UIImageView  = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The sub title label
	let subTitleLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The disclosure image
	private let disclosureView: UIImageView = {

		let view = UIImageView(image: UIImage.disclosure)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let button: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.lightBackground

		layer.cornerRadius = ViewTraits.cornerRadius

		createShadow()

		button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
	}

	/// Create the shadow
	func createShadow() {

		// Shadow
		layer.shadowColor = Theme.colors.shadow.withAlphaComponent(0.7).cgColor
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
		addSubview(disclosureView)
		addSubview(iconView)
		addSubview(subTitleLabel)
		button.embed(in: self)
		bringSubviewToFront(button)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Title
			iconView.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.topMargin
			),
			iconView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.leadingMargin
			),
//			iconView.trailingAnchor.constraint(equalTo: disclosureView.leadingAnchor),
			iconView.bottomAnchor.constraint(
				equalTo: subTitleLabel.topAnchor,
				constant: -ViewTraits.textMargin
			),

			// Message
			subTitleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.leadingMargin
			),
			subTitleLabel.trailingAnchor.constraint(equalTo: disclosureView.leadingAnchor),

			subTitleLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.topMargin
			),

			disclosureView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			disclosureView.heightAnchor.constraint(equalToConstant: 22),
			disclosureView.widthAnchor.constraint(equalToConstant: 10),
			disclosureView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	var icon: UIImage? {
		didSet {
			iconView.image = icon
		}
	}

	/// The sub title
	var subtitle: String? {
		didSet {
			subTitleLabel.text = subtitle
		}
	}
}
