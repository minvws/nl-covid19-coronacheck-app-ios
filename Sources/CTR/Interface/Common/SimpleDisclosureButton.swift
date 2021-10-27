/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// A grey full width button with a title and a disclosure icon
class SimpleDisclosureButton: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let lineHeight: CGFloat = 22
		static let disclosureHeight: CGFloat = 12
		static let kerning: CGFloat = -0.41

		// Margins
		static let margin: CGFloat = 20.0
		static let textMargin: CGFloat = 15.0
	}

	private let titleLabel: Label = {

		return Label(body: nil).multiline()
	}()

	private let disclosureView: UIImageView = {

		let view = UIImageView(image: I.disclosure())
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The line above the button
	private let lineView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let button: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		titleLabel.textColor = Theme.colors.dark
		lineView.backgroundColor = Theme.colors.grey4
		disclosureView.tintColor = Theme.colors.grey4
		button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(disclosureView)
		addSubview(titleLabel)
		addSubview(lineView)
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
				constant: ViewTraits.textMargin
			),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: disclosureView.leadingAnchor),
			titleLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.textMargin
			),
			titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.lineHeight),

			// Line
			lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
			lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
			lineView.heightAnchor.constraint(equalToConstant: 1),

			disclosureView.trailingAnchor.constraint(equalTo: trailingAnchor),
			disclosureView.heightAnchor.constraint(equalToConstant: ViewTraits.disclosureHeight),
			disclosureView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}

	override func setupAccessibility() {

		super.setupAccessibility()
		titleLabel.isAccessibilityElement = false
		button.isAccessibilityElement = true
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
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.lineHeight,
															 kerning: ViewTraits.kerning)
			button.accessibilityLabel = title
		}
	}
}
