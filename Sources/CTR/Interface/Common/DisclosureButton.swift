/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

/// A grey full width button with a title and a disclosure icon
class DisclosureButton: DisclosureSubtitleButton {
	
	/// The display constants
	private struct ViewTraits {
		
		// Margins
		static let topMargin: CGFloat = 18.0
		static let bottomMargin: CGFloat = 22
		static let leadingMargin: CGFloat = 16.0
		static let trailingMargin: CGFloat = 8.0
		
		enum Icon {
			static let size: CGFloat = 20.0
			static let trailingMargin: CGFloat = 16.0
		}
	}
	
	/// The disclosure image
	let iconView: UIImageView = {
		
		let view = UIImageView()
		view.contentMode = .scaleAspectFill
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	var titleLabelToDisclosureLayoutConstraint: NSLayoutConstraint?
	var titleLabelToIconLayoutConstraint: NSLayoutConstraint?
	
	override func setupViews() {
		
		super.setupViews()
		subtitleLabel.isHidden = true
		addSubview(iconView)
	}
	
	override func setupViewConstraints() {
		
		// No super.setupViewConstraints(), override only
		
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
			{
				let constraint = titleLabel.trailingAnchor.constraint(
					lessThanOrEqualTo: disclosureView.leadingAnchor,
					constant: -ViewTraits.trailingMargin
				)
				titleLabelToDisclosureLayoutConstraint = constraint
				return constraint
			}(),
			{
				let constraint = titleLabel.trailingAnchor.constraint(
					lessThanOrEqualTo: iconView.leadingAnchor,
					constant: -ViewTraits.trailingMargin
				)
				titleLabelToIconLayoutConstraint = constraint
				return constraint
			}(),
			
			titleLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.bottomMargin
			),
			
			iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
			iconView.trailingAnchor.constraint(
				equalTo: disclosureView.leadingAnchor,
				constant: -ViewTraits.Icon.trailingMargin
			),
			iconView.heightAnchor.constraint(equalToConstant: ViewTraits.Icon.size),
			iconView.widthAnchor.constraint(equalToConstant: ViewTraits.Icon.size)
		])
		
		titleLabelToIconLayoutConstraint?.isActive = false
		
		setupDisclosureViewConstraints()
	}
	
	override func setAccessibilityLabel() {
		
		button.accessibilityLabel = title
	}
	
	var icon: UIImage? {
		didSet {
			iconView.image = icon
			titleLabelToIconLayoutConstraint?.isActive = icon != nil
			titleLabelToDisclosureLayoutConstraint?.isActive = icon == nil
		}
	}
}
