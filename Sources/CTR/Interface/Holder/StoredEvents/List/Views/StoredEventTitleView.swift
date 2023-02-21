/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import ReusableViews
import Resources

class StoredEventTitleView: BaseView {
	
	/// The display constants
	fileprivate struct ViewTraits {
		
		// Dimensions
		static let lineHeight: CGFloat = 22
		static let kerning: CGFloat = -0.41
		
		// Margins
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 24.0
		static let bottomMargin: CGFloat = 24.0
	}
	
	fileprivate var titleTopMarginConstraint: NSLayoutConstraint?
	fileprivate var titleBottomMarginConstraint: NSLayoutConstraint?
	
	fileprivate let titleLabel: Label = {
		
		return Label(body: nil).multiline()
	}()
	
	/// The line above the button
	private let topLineView: UIView = {
		
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	/// The line above the button
	private let bottomLineView: UIView = {
		
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = C.white()
		titleLabel.textColor = C.secondaryText()
		topLineView.backgroundColor = C.grey4()
		bottomLineView.backgroundColor = C.grey4()
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(topLineView)
		addSubview(titleLabel)
		addSubview(bottomLineView)
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
			
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.margin),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.margin),
			titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.lineHeight),
			
			// Line
			bottomLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			bottomLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
			bottomLineView.bottomAnchor.constraint(equalTo: bottomAnchor),
			bottomLineView.heightAnchor.constraint(equalToConstant: 1),
			
			topLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			topLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
			topLineView.topAnchor.constraint(equalTo: topAnchor),
			topLineView.heightAnchor.constraint(equalToConstant: 1)
		])
	}
	
	// MARK: Public Access
	
	/// The  title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.lineHeight,
				kerning: ViewTraits.kerning,
				textColor: C.secondaryText()!
			)
		}
	}
}

class StoredEventHeaderView: StoredEventTitleView {
	
	/// The display constants
	private struct ViewTraits {
		
		enum Title {
			static let lineHeight: CGFloat = 16
		}
		enum View {
			static let topMargin: CGFloat = 13.0
			static let bottomMargin: CGFloat = 13.0
		}
	}
	
	override func setupViews() {
		
		super.setupViews()
		setColorsForCurrentTraitCollection()
		titleLabel.font = Fonts.caption1
	}
	
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		titleTopMarginConstraint?.constant = StoredEventHeaderView.ViewTraits.View.topMargin
		titleBottomMarginConstraint?.constant = -StoredEventHeaderView.ViewTraits.View.bottomMargin
	}
	
	override func setupAccessibility() {
		super.setupAccessibility()
		titleLabel.accessibilityTraits = .header
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		setColorsForCurrentTraitCollection()
	}
	
	private func setColorsForCurrentTraitCollection() {
		backgroundColor = shouldUseDarkMode ? C.grey5() : C.white()
	}
	
	/// The  title
	override var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				StoredEventHeaderView.ViewTraits.Title.lineHeight
			)
		}
	}
}
