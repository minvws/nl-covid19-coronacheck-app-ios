/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RiskSettingControl: UIControl {
	
	private enum ViewTraits {
		
		enum Margin {
			static let horizontal: CGFloat = 20
			static let vertical: CGFloat = 24
		}
		enum Spacing {
			static let label: CGFloat = 8
		}
		enum Title {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Subtitle {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
		}
	}
	
	private let titleLabel: Label = {
		return Label(body: nil).header().multiline()
	}()
	
	private let subtitleLabel: Label = {
		return Label(subhead: nil).multiline()
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViewHierarchy()
		setupViewConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// Setup the view hierarchy
	func setupViewHierarchy() {

		// Add icon
		addSubview(titleLabel)
		addSubview(subtitleLabel)
	}

	/// Setup all the constraints
	func setupViewConstraints() {

		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: topAnchor,
											constant: ViewTraits.Margin.vertical),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
												constant: ViewTraits.Margin.horizontal),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
												 constant: -ViewTraits.Margin.horizontal),
			
			subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
											   constant: ViewTraits.Spacing.label),
			subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
												   constant: ViewTraits.Margin.horizontal),
			subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
													constant: -ViewTraits.Margin.horizontal),
			subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor,
												  constant: -ViewTraits.Margin.vertical)
		])
	}
	
	// MARK: Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Title.lineHeight,
															 kerning: ViewTraits.Title.kerning,
															 textColor: Theme.colors.dark)
		}
	}
	
	var subtitle: String? {
		didSet {
			subtitleLabel.attributedText = subtitle?.setLineHeight(ViewTraits.Subtitle.lineHeight,
																   kerning: ViewTraits.Subtitle.kerning,
																   textColor: Theme.colors.secondaryText)
		}
	}
}
