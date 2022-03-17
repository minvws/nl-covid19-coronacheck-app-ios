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
			static let iconToLabel: CGFloat = 24
		}
		enum Size {
			static let icon: CGFloat = 22
		}
		enum Title {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Subtitle {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Colors {
			static let highlighted = UIColor(white: 0.98, alpha: 1)
		}
	}
	
	private let iconImageView: UIImageView = {
		let imageView = ImageView(imageName: I.radioButton.normal.name,
								  highlightedImageName: I.radioButton.selected.name)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let titleLabel: Label = {
		return Label(bodySemiBold: nil).header().multiline()
	}()
	
	private let subtitleLabel: Label = {
		return Label(body: nil).multiline()
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
		setupViewHierarchy()
		setupViewConstraints()
		setupAccessibility()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// Setup all the views
	private func setupViews() {
		
		backgroundColor = C.white()
		
		addTarget(self, action: #selector(toggle), for: .touchUpInside)
	}
	
	/// Setup the view hierarchy
	private func setupViewHierarchy() {

		addSubview(iconImageView)
		addSubview(titleLabel)
		addSubview(subtitleLabel)
	}

	/// Setup all the constraints
	private func setupViewConstraints() {

		NSLayoutConstraint.activate([
			
			iconImageView.topAnchor.constraint(equalTo: topAnchor,
											   constant: ViewTraits.Margin.vertical),
			iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor,
												   constant: ViewTraits.Margin.horizontal),
			iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor,
												  constant: -ViewTraits.Margin.vertical),
			iconImageView.widthAnchor.constraint(equalToConstant: ViewTraits.Size.icon),
			iconImageView.heightAnchor.constraint(equalToConstant: ViewTraits.Size.icon),
			
			titleLabel.topAnchor.constraint(equalTo: topAnchor,
											constant: ViewTraits.Margin.vertical),
			titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor,
												constant: ViewTraits.Spacing.iconToLabel),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
												 constant: -ViewTraits.Margin.horizontal),
			
			subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
											   constant: ViewTraits.Spacing.label),
			subtitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor,
												   constant: ViewTraits.Spacing.iconToLabel),
			subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
													constant: -ViewTraits.Margin.horizontal),
			subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor,
												  constant: -ViewTraits.Margin.vertical)
		])
	}
	
	private func setupAccessibility() {
		isAccessibilityElement = true
		accessibilityTraits = .button
	}
	
	override var isSelected: Bool {
		didSet {
			Haptic.light()
			
			iconImageView.isHighlighted = isSelected
			
			if isSelected {
				accessibilityTraits.insert(.selected)
			} else {
				accessibilityTraits.remove(.selected)
			}
		}
	}
	
	override var isHighlighted: Bool {
		didSet {
			backgroundColor = isHighlighted ? ViewTraits.Colors.highlighted : C.white()
		}
	}
	
	@objc private func toggle() {
		isSelected = true
		onTapCommand?()
	}
	
	// MARK: Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Title.lineHeight,
															 kerning: ViewTraits.Title.kerning,
															 textColor: C.black()!)
		}
	}
	
	var subtitle: String? {
		didSet {
			subtitleLabel.attributedText = subtitle?.setLineHeight(ViewTraits.Subtitle.lineHeight,
																   kerning: ViewTraits.Subtitle.kerning,
																   textColor: C.secondaryText()!)
		}
	}
	
	var onTapCommand: (() -> Void)?

	var hasError: Bool = false {
		didSet {
			if hasError {
				iconImageView.image = I.toggle.error()
			} else {
				iconImageView.image = I.radioButton.normal()
			}
		}
	}
}
