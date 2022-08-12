/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// A grey full width button with a title and a disclosure icon
class SimpleDisclosureButton: BaseView {

	/// The display constants
	fileprivate struct ViewTraits {

		// Dimensions
		static let lineHeight: CGFloat = 22
		static let disclosureHeight: CGFloat = 12
		static let kerning: CGFloat = -0.41

		// Margins
		static let topMargin: CGFloat = 12.0
		static let bottomMargin: CGFloat = 16.0
	}
	
	fileprivate var titleTopMarginConstraint: NSLayoutConstraint?
	fileprivate var titleBottomMarginConstraint: NSLayoutConstraint?
	fileprivate var titleLeadingConstraint: NSLayoutConstraint?
	fileprivate var disclosureTrailingConstraint: NSLayoutConstraint?
	
	fileprivate let titleLabel: Label = {

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

	fileprivate let button: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
		titleLabel.textColor = C.black()
		lineView.backgroundColor = C.grey4()
		disclosureView.tintColor = C.grey4()
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
			{
				let constraint = titleLabel.topAnchor.constraint(
					equalTo: topAnchor,
					constant: ViewTraits.topMargin
				)
				titleTopMarginConstraint = constraint
				return constraint
			}(),
			{
				let constraint = titleLabel.bottomAnchor.constraint(
					equalTo: bottomAnchor,
					constant: -ViewTraits.bottomMargin
				)
				titleBottomMarginConstraint = constraint
				return constraint
			}(),
			{
				let constraint = titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
				titleLeadingConstraint = constraint
				return constraint
			}(),
			titleLabel.trailingAnchor.constraint(equalTo: disclosureView.leadingAnchor),
			titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.lineHeight),

			// Line
			lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
			lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
			lineView.heightAnchor.constraint(equalToConstant: 1),

			{
				let constraint = disclosureView.trailingAnchor.constraint(equalTo: trailingAnchor)
				disclosureTrailingConstraint = constraint
				return constraint
			}(),
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

class RedDisclosureButton: SimpleDisclosureButton {
	
	/// The display constants
	private struct ViewTraits {
		
		// Margins
		static let inset: CGFloat = 20
		static let topMargin: CGFloat = 24.0
		static let bottomMargin: CGFloat = 24.0
	}
	
	override func setupViews() {
		
		super.setupViews()
		titleLabel.font = Fonts.bodyBold
	}
	
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		titleTopMarginConstraint?.constant = RedDisclosureButton.ViewTraits.topMargin
		titleBottomMarginConstraint?.constant = -RedDisclosureButton.ViewTraits.bottomMargin
		titleLeadingConstraint?.constant = RedDisclosureButton.ViewTraits.inset
		disclosureTrailingConstraint?.constant = -RedDisclosureButton.ViewTraits.inset
	}
	
	/// The  title
	override var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				SimpleDisclosureButton.ViewTraits.lineHeight,
				kerning: SimpleDisclosureButton.ViewTraits.kerning,
				textColor: C.error() ?? UIColor.red
			)
			button.accessibilityLabel = title
		}
	}
}
