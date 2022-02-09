/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class ChangeRiskSettingView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
	
		enum Margin {
			static let horizontal: CGFloat = 20
			static let vertical: CGFloat = 24
		}
		enum Spacing {
			static let labels: CGFloat = 8
			static let subtitleToChangeButton: CGFloat = 16
		}
		enum Height {
			static let separator: CGFloat = 1
		}
		enum Font {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
	}
	
	private let topSeparatorView: UIView = {
		let separatorView = UIView()
		separatorView.translatesAutoresizingMaskIntoConstraints = false
		separatorView.backgroundColor = Theme.colors.grey4
		return separatorView
	}()
	
	private let bottomSeparatorView: UIView = {
		let separatorView = UIView()
		separatorView.translatesAutoresizingMaskIntoConstraints = false
		separatorView.backgroundColor = Theme.colors.grey4
		return separatorView
	}()
	
	private let titleLabel: Label = {
		return Label(bodySemiBold: nil).header().multiline()
	}()
	
	private let subtitleLabel: Label = {
		return Label(body: nil).multiline()
	}()
	
	private let changeButton: Button =  {
		return Button(style: .textLabelBlue)
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
		
		changeButton.touchUpInside(self, action: #selector(tapChangeButton))
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(topSeparatorView)
		addSubview(titleLabel)
		addSubview(subtitleLabel)
		addSubview(changeButton)
		addSubview(bottomSeparatorView)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			topSeparatorView.topAnchor.constraint(equalTo: topAnchor),
			topSeparatorView.leftAnchor.constraint(equalTo: leftAnchor),
			topSeparatorView.rightAnchor.constraint(equalTo: rightAnchor),
			topSeparatorView.heightAnchor.constraint(equalToConstant: ViewTraits.Height.separator),
			
			titleLabel.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor,
											constant: ViewTraits.Margin.vertical),
			titleLabel.leftAnchor.constraint(equalTo: leftAnchor,
											 constant: ViewTraits.Margin.horizontal),
			titleLabel.rightAnchor.constraint(equalTo: rightAnchor,
											  constant: -ViewTraits.Margin.horizontal),
			
			subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
											   constant: ViewTraits.Spacing.labels),
			subtitleLabel.leftAnchor.constraint(equalTo: leftAnchor,
												constant: ViewTraits.Margin.horizontal),
			subtitleLabel.rightAnchor.constraint(equalTo: rightAnchor,
												 constant: -ViewTraits.Margin.horizontal),
			
			changeButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor,
											  constant: ViewTraits.Spacing.subtitleToChangeButton),
			changeButton.leadingAnchor.constraint(equalTo: leadingAnchor,
												  constant: ViewTraits.Margin.horizontal),
			changeButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor,
												   constant: -ViewTraits.Margin.horizontal),
			
			bottomSeparatorView.topAnchor.constraint(equalTo: changeButton.bottomAnchor,
													 constant: ViewTraits.Margin.vertical),
			bottomSeparatorView.leftAnchor.constraint(equalTo: leftAnchor),
			bottomSeparatorView.rightAnchor.constraint(equalTo: rightAnchor),
			bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
			bottomSeparatorView.heightAnchor.constraint(equalToConstant: ViewTraits.Height.separator)
		])
	}
	
	@objc func tapChangeButton() {
		
		changeButtonCommand?()
	}
	
	// MARK: - Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Font.lineHeight,
															 kerning: ViewTraits.Font.kerning)
		}
	}
	
	var subtitle: String? {
		didSet {
			subtitleLabel.attributedText = subtitle?.setLineHeight(ViewTraits.Font.lineHeight,
																   kerning: ViewTraits.Font.kerning)
		}
	}
	
	var changeButtonTitle: String? {
		didSet {
			changeButton.title = changeButtonTitle
		}
	}
	
	var changeButtonCommand: (() -> Void)?
}
