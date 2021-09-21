/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// A grey full width button with a title, sub title and a disclosure icon
class DisclosureSubtitleButton: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 9
		static let shadowRadius: CGFloat = 6
		static let shadowOpacity: Float = 0.2
		static let disclosureHeight: CGFloat = 12

		// Margins
		static let textMargin: CGFloat = 4.0
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 18.0
		static let leadingMargin: CGFloat = 16.0
		static let iconSpacing: CGFloat = 12.0
	}

	/// The title label
	let titleLabel: Label = {

		return Label(calloutSemiBold: nil).multiline()
	}()

	/// The sub title label
	let subtitleLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	/// The disclosure image
	let disclosureView: UIImageView = {

		let view = UIImageView(image: I.disclosure())
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	/// The subtitle icon image view
	private let iconImageView: UIImageView = {
		
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.adjustsImageSizeForAccessibilityContentSizeCategory = true
		view.contentMode = .scaleAspectFit
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
		addSubview(titleLabel)
		addSubview(subtitleLabel)
		addSubview(iconImageView)
		button.embed(in: self)
		bringSubviewToFront(button)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.topMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.leadingMargin
			),
			titleLabel.trailingAnchor.constraint(equalTo: disclosureView.leadingAnchor),
			titleLabel.bottomAnchor.constraint(
				equalTo: subtitleLabel.topAnchor,
				constant: -ViewTraits.textMargin
			),

			// Message
			subtitleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.leadingMargin
			),
			subtitleLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.topMargin
			),
			
			iconImageView.leadingAnchor.constraint(
				equalTo: subtitleLabel.trailingAnchor,
				constant: ViewTraits.iconSpacing
			),
			iconImageView.trailingAnchor.constraint(
				lessThanOrEqualTo: disclosureView.leadingAnchor,
				constant: -ViewTraits.iconSpacing
			),
			iconImageView.bottomAnchor.constraint(equalTo: subtitleLabel.bottomAnchor)
		])

		setupDisclosureViewConstraints()
	}

	func setupDisclosureViewConstraints() {

		NSLayoutConstraint.activate([

			disclosureView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			disclosureView.heightAnchor.constraint(equalToConstant: ViewTraits.disclosureHeight),
			disclosureView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()
		
		accessibilityElements = [button]
	}

	func setAccessibilityLabel() {

		button.accessibilityLabel = "\(title ?? ""). \(subtitle ?? "")"
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	/// The  title
	var title: String? {
		didSet {
			titleLabel.text = title
			setAccessibilityLabel()
		}
	}

	/// The sub title
	var subtitle: String? {
		didSet {
			subtitleLabel.text = subtitle
			setAccessibilityLabel()
		}
	}
	
	/// The icon next to subtitle
	var subtitleIcon: UIImage? {
		didSet {
			iconImageView.image = subtitleIcon
		}
	}
}
