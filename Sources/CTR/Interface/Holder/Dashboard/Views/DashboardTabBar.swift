/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol DashboardTabBarDelegate: AnyObject {
	
	func dashboardTabBar(_ tabBar: DashboardTabBar, didSelect tab: DashboardTab)
}

final class DashboardTabBar: BaseView {
	
	weak var delegate: DashboardTabBarDelegate?
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let horizontal: CGFloat = 20
		}
		enum Size {
			static let separatorHeight: CGFloat = 2
			static let lineHeight: CGFloat = 2
		}
		enum Duration {
			static let lineAnimation: TimeInterval = 0.25
		}
	}
	
	private let domesticButton: TabBarButton = {
		let button = TabBarButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private let internationalButton: TabBarButton = {
		let button = TabBarButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private let separatorView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = C.grey4()
		return view
	}()
	
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		return stackView
	}()
	
	private let selectionLineView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = C.black()
		return view
	}()
	
	private var selectionLineLeftConstraint: NSLayoutConstraint?
	private var selectionLineRightConstraint: NSLayoutConstraint?
	
	/// Only allows tab interation when animation is ended
	private var isAnimating = false
	
	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
		
		domesticButton.title = L.generalNetherlands()
		domesticButton.tapHandler = { [weak self] in
			self?.tapTabButton(.domestic)
		}
		internationalButton.title = L.generalEuropeanUnion()
		internationalButton.tapHandler = { [weak self] in
			self?.tapTabButton(.international)
		}
	}
	
	/// Setup the view hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(stackView)
		stackView.addArrangedSubview(domesticButton)
		stackView.addArrangedSubview(internationalButton)
		stackView.addSubview(separatorView)
		stackView.addSubview(selectionLineView)
	}
	
	/// Setup all the constraints
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: ViewTraits.Margin.horizontal),
			stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -ViewTraits.Margin.horizontal),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			separatorView.leftAnchor.constraint(equalTo: stackView.leftAnchor),
			separatorView.rightAnchor.constraint(equalTo: stackView.rightAnchor),
			separatorView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
			separatorView.heightAnchor.constraint(equalToConstant: ViewTraits.Size.separatorHeight),
			
			selectionLineView.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
			selectionLineView.heightAnchor.constraint(equalToConstant: ViewTraits.Size.lineHeight)
		])
	}
	
	/// Setup all the accessibility traits
	override func setupAccessibility() {
		super.setupAccessibility()
		
		accessibilityTraits = .tabBar
		isAccessibilityElement = false // Should have it disabled for this trait
	}
	
	override func accessibilityElementIsFocused() -> Bool {
		return domesticButton.accessibilityElementIsFocused() || internationalButton.accessibilityElementIsFocused()
	}
	
	private func tapTabButton(_ tab: DashboardTab) {
		guard !isAnimating else { return }
		
		delegate?.dashboardTabBar(self, didSelect: tab)
		select(tab: tab, animated: true)
	}
	
	/// Select a tab
	/// - Parameters:
	///   - tab: The dashboard tab
	///   - animated: Boolean to display tab animated
	func select(tab: DashboardTab, animated: Bool) {
		selectedTab = tab
		
		selectionLineLeftConstraint?.isActive = false
		selectionLineRightConstraint?.isActive = false
		domesticButton.isSelected = false
		internationalButton.isSelected = false
		
		let button = tab.isDomestic ? domesticButton : internationalButton
		button.isSelected = true
		
		selectionLineLeftConstraint = selectionLineView.leftAnchor.constraint(equalTo: button.leftAnchor)
		selectionLineLeftConstraint?.isActive = true
		selectionLineRightConstraint = selectionLineView.rightAnchor.constraint(equalTo: button.rightAnchor)
		selectionLineRightConstraint?.isActive = true
		
		setNeedsLayout()
		
		guard animated else { return }
		
		isAnimating = true
		UIView.animate(withDuration: ViewTraits.Duration.lineAnimation) {
			self.layoutIfNeeded()
		} completion: { [weak self] _ in
			self?.isAnimating = false
		}
	}
	
	/// Get selected tab
	private(set) var selectedTab: DashboardTab = .domestic
}

private class TabBarButton: UIControl {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = UIDevice.current.isSmallScreen ? 13 : 24
			static let bottom: CGFloat = 18
		}
		enum Colors {
			static let highlighted = UIColor(white: 0.98, alpha: 1)
		}
		enum Title {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
		}
	}
	
	private let titleLabel: Label = {
		let label = Label(subheadMedium: nil)
		label.adjustsFontForContentSizeCategory = true
		if #available(iOS 15.0, *) {
			label.maximumContentSizeCategory = .accessibilityMedium
		}
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViews()
		setupViewHierarchy()
		setupViewConstraints()
		setupAccessibility()
	}
	
	override var isHighlighted: Bool {
		didSet {
			backgroundColor = isHighlighted ? ViewTraits.Colors.highlighted : C.white()
		}
	}
	
	override var isSelected: Bool {
		didSet {
			titleLabel.textColor = isSelected ? C.black() : C.secondaryText()
			titleLabel.font = isSelected ? Fonts.subheadHeavyBold : Fonts.subheadMedium
			
			if isSelected {
				accessibilityTraits.insert(.selected)
			} else {
				accessibilityTraits.remove(.selected)
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// Setup all the views
	private func setupViews() {

		backgroundColor = C.white()
		
		addTarget(self, action: #selector(touchUp), for: .touchUpInside)
	}

	/// Setup the view hierarchy
	private func setupViewHierarchy() {

		addSubview(titleLabel)
	}

	/// Setup all the constraints
	private func setupViewConstraints() {

		NSLayoutConstraint.activate([
			titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.Margin.top),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.Margin.bottom),
			titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
			titleLabel.rightAnchor.constraint(equalTo: rightAnchor)
		])
	}
	
	/// Setup all the accessibility traits
	private func setupAccessibility() {

		isAccessibilityElement = true
	}
	
	@objc
	private func touchUp() {
		tapHandler?()
	}
	
	/// The tap handler
	var tapHandler: (() -> Void)?
	
	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Title.lineHeight,
															 alignment: .center,
															 kerning: ViewTraits.Title.kerning)
			accessibilityLabel = title
			setupLargeContentViewer(title: title)
		}
	}
}
