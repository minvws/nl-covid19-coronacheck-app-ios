/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class FakeNavigationBarView: BaseView {
	
	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let margin: CGFloat = 20
		
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
	}
	
	let titleLabel: Label = {
		let label = Label(title1: "", textColor: C.black()!, montserrat: true).header()
		label.numberOfLines = 0
		label.setContentCompressionResistancePriority(.required, for: .horizontal)
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.adjustsFontForContentSizeCategory = true
		if #available(iOS 15.0, *) {
			label.maximumContentSizeCategory = .accessibilityMedium
		}
		return label
	}()
	
	private lazy var menuButton: MenuButton = {
		let button = MenuButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setContentCompressionResistancePriority(.required, for: .horizontal)
		button.setContentHuggingPriority(.required, for: .horizontal)
		button.accessibilityTraits = .button
		return button
	}()
	
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = self.axisForStackView
		stackView.distribution = .equalCentering
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	private var axisForStackView: NSLayoutConstraint.Axis {
		
		if traitCollection.verticalSizeClass == .regular,
			traitCollection.preferredContentSizeCategory >= .extraExtraExtraLarge {
			return .vertical
		} else {
			return .horizontal
		}
	}

	private func configureSubviews(forStackviewAxis axis: NSLayoutConstraint.Axis) {
		stackView.axis = axis
		menuButton.iconPosition = axis == .horizontal ? .right : .left
		stackView.alignment = axis == .horizontal ? .trailing : .fill
	}
	
	// MARK: - Lifecycle
	
	override func setupViews() {

		super.setupViews()
		configureSubviews(forStackviewAxis: axisForStackView)
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(stackView)
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(menuButton)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		// Decrease spacing to dashboard tab bar for larger font sizes
		var bottomMargin = ViewTraits.margin
		if traitCollection.preferredContentSizeCategory >= .accessibilityMedium {
			bottomMargin = 0
		} else if traitCollection.preferredContentSizeCategory >= .extraExtraExtraLarge {
			bottomMargin = ViewTraits.margin / 2
		}
		
		stackView.embed(
			in: self,
			insets: UIEdgeInsets(top: ViewTraits.margin, left: ViewTraits.margin, bottom: bottomMargin, right: ViewTraits.margin)
		)
	}
	
	// MARK: - UITraitEnvironment
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		configureSubviews(forStackviewAxis: axisForStackView)
	}

	// MARK: - Properties
	
	var tapMenuButtonHandler: (() -> Void)? {
		didSet {
			menuButton.action = tapMenuButtonHandler
		}
	}
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Title.lineHeight,
															 kerning: ViewTraits.Title.kerning)
			setupLargeContentViewer(title: title)
		}
	}
}
