/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol TopTabBarDelegate: AnyObject {
	
	func topTabBarDidSelectTab(_ tab: TopTabBar.Tab)
}

final class TopTabBar: BaseView {
	
	enum Tab: Int {
		case domestic
		case international
	}
	
	weak var delegate: TopTabBarDelegate?
	
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
		view.backgroundColor = Theme.colors.grey4
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
		view.backgroundColor = Theme.colors.dark
		return view
	}()
	
	private var selectionLineLeftConstraint: NSLayoutConstraint?
	private var selectionLineRightConstraint: NSLayoutConstraint?
	private var isAnimating = false
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
		
		domesticButton.title = L.generalNetherlands()
		domesticButton.tapHandler = { [weak self] in
			self?.tapTabButton(.domestic)
		}
		internationalButton.title = L.generalEuropeanUnion()
		internationalButton.tapHandler = { [weak self] in
			self?.tapTabButton(.international)
		}
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(stackView)
		stackView.addArrangedSubview(domesticButton)
		stackView.addArrangedSubview(internationalButton)
		stackView.addSubview(separatorView)
		stackView.addSubview(selectionLineView)
	}
	
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
		
		select(tab: .domestic, animated: false)
	}
	
	private func tapTabButton(_ tab: Tab) {
		guard !isAnimating else { return }
		
		delegate?.topTabBarDidSelectTab(tab)
		selectedTab = tab
	}
	
	private func select(tab: Tab, animated: Bool) {
		
		selectionLineLeftConstraint?.isActive = false
		selectionLineRightConstraint?.isActive = false
		domesticButton.isSelected = false
		internationalButton.isSelected = false
		
		let button = tab == .domestic ? domesticButton : internationalButton
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
	
	var selectedTab: Tab = .domestic {
		didSet {
			select(tab: selectedTab, animated: true)
		}
	}
}

private class TabBarButton: UIControl {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 24
			static let bottom: CGFloat = 18
		}
	}
	
	private let titleLabel: Label = {
		let label = Label(subheadMedium: nil)
		label.textAlignment = .center
		label.textColor = Theme.colors.secondaryText
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViews()
		setupViewHierarchy()
		setupViewConstraints()
	}
	
	override var isSelected: Bool {
		didSet {
			titleLabel.textColor = isSelected ? Theme.colors.dark : Theme.colors.secondaryText
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// Setup all the views
	private func setupViews() {

		backgroundColor = Theme.colors.viewControllerBackground
		
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
			titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor),
			titleLabel.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor)
		])
	}
	
	@objc
	private func touchUp() {
		tapHandler?()
	}
	
	var tapHandler: (() -> Void)?
	
	/// The title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}
}
