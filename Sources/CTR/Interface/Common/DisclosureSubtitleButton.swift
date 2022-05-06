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
		static let disclosureMargin: CGFloat = 18.0
		static let topMargin: CGFloat = 13.0
		static let bottomMargin: CGFloat = 16.0
		static let leadingMargin: CGFloat = 16.0
		
		enum Title {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Message {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
		}
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

	let button: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = C.primaryBlue5()
		layer.cornerRadius = ViewTraits.cornerRadius
		button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(disclosureView)
		addSubview(titleLabel)
		addSubview(subtitleLabel)
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
			titleLabel.trailingAnchor.constraint(
				lessThanOrEqualTo: disclosureView.leadingAnchor,
				constant: -ViewTraits.textMargin
			),
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
				constant: -ViewTraits.bottomMargin
			),
			subtitleLabel.trailingAnchor.constraint(
				lessThanOrEqualTo: disclosureView.leadingAnchor,
				constant: -ViewTraits.textMargin
			)
		])

		setupDisclosureViewConstraints()
	}

	func setupDisclosureViewConstraints() {

		NSLayoutConstraint.activate([

			disclosureView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.disclosureMargin
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
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Title.lineHeight,
															 kerning: ViewTraits.Title.kerning)
			setAccessibilityLabel()
		}
	}

	/// The sub title
	var subtitle: String? {
		didSet {
			subtitleLabel.attributedText = subtitle?.setLineHeight(ViewTraits.Message.lineHeight,
																   kerning: ViewTraits.Message.kerning)
			setAccessibilityLabel()
		}
	}
}
