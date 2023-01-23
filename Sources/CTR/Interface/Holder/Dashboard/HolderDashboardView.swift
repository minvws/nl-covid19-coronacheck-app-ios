/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

protocol HolderDashboardViewDelegate: AnyObject {
	
	func holderDashboardView(didDisplay tab: DashboardTab)
}

final class HolderDashboardView: BaseView {
	
	weak var delegate: HolderDashboardViewDelegate?
	
	/// The display constants
	private enum ViewTraits {
		
		enum Spacing {
			static let stackView: CGFloat = 24
		}
	}
	
	private let fakeNavigationBar: FakeNavigationBarView = {
		let navbar = FakeNavigationBarView()
		navbar.translatesAutoresizingMaskIntoConstraints = false
		return navbar
	}()
	
	private let tabBar: DashboardTabBar = {
		let tabBar = DashboardTabBar()
		tabBar.translatesAutoresizingMaskIntoConstraints = false
		return tabBar
	}()
	
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.isPagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		return scrollView
	}()
	
	/// The scrolled stackview to display domestic cards
	let domesticScrollView: ScrolledStackView = {
		let scrollView = ScrolledStackView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.stackView.spacing = ViewTraits.Spacing.stackView
		scrollView.backgroundColor = C.white()
		return scrollView
	}()
	
	/// The scrolled stackview to display international cards
	let internationalScrollView: ScrolledStackView = {
		let scrollView = ScrolledStackView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.stackView.spacing = ViewTraits.Spacing.stackView
		scrollView.backgroundColor = C.white()
		return scrollView
	}()
	
	/// Footer view with primary button
	let footerButtonView: FooterButtonView = {
		let footerView = FooterButtonView()
		footerView.translatesAutoresizingMaskIntoConstraints = false
		return footerView
	}()
	
	private var bottomScrollViewConstraint: NSLayoutConstraint?
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	private lazy var scrollViewTopConstraintWithTabBar: NSLayoutConstraint = scrollView.topAnchor.constraint(equalTo: tabBar.bottomAnchor)
	private lazy var scrollViewTopConstraintWithoutTabBar: NSLayoutConstraint = scrollView.topAnchor.constraint(equalTo: fakeNavigationBar.bottomAnchor)
	
	// MARK: - Overrides
	
	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
		
		tabBar.delegate = self
		scrollView.delegate = self
		footerButtonView.isHidden = true
		
		NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
			DispatchQueue.main.async { // because otherwise `UIApplication.shared.keyWindow?.bounds.width` has the wrong value 🙄
				self?.updateStackViewInsets()
			}
		}
		updateStackViewInsets()
	}
	
	/// Setup the view hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(fakeNavigationBar)
		addSubview(tabBar)
		addSubview(scrollView)
		addSubview(footerButtonView)
		scrollView.addSubview(domesticScrollView)
		scrollView.addSubview(internationalScrollView)
	}

	/// Setup all the constraints
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		scrollViewTopConstraintWithTabBar.isActive = shouldShowTabBar
		scrollViewTopConstraintWithoutTabBar.isActive = !shouldShowTabBar
		
		NSLayoutConstraint.activate(domesticTabEnabledConstraints)
		
		NSLayoutConstraint.activate([
			
			fakeNavigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			fakeNavigationBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			fakeNavigationBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			
			tabBar.topAnchor.constraint(equalTo: fakeNavigationBar.bottomAnchor),
			tabBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			tabBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			{
				let constraint = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
				bottomScrollViewConstraint = constraint
				return constraint
			}(),
			
			footerButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
			footerButtonView.trailingAnchor.constraint(equalTo: trailingAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			internationalScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			internationalScrollView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			internationalScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			internationalScrollView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor),
			{
				let constraint = internationalScrollView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
				constraint.priority = .defaultLow
				return constraint
			}()
		])
	}
	
	lazy var domesticTabEnabledConstraints: [NSLayoutConstraint] = [
		internationalScrollView.leadingAnchor.constraint(equalTo: domesticScrollView.trailingAnchor),
		
		domesticScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
		domesticScrollView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
		domesticScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
		domesticScrollView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor),
		{
			let constraint = domesticScrollView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
			constraint.priority = .defaultLow
			return constraint
		}()
	]
	
	lazy var domesticTabDisabledConstraints: [NSLayoutConstraint] = [
		internationalScrollView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
	]
	
	override var accessibilityElements: [Any]? {
		get {
			let selectedScrollView: [UIView] = {
				switch tabBar.selectedTab {
					case .domestic: return [domesticScrollView]
					case .international: return [internationalScrollView]
				}
			}()
			return [fakeNavigationBar, tabBar] + selectedScrollView + [footerButtonView]
		}
		set {}
	}
	
	/// Enables swipe to navigate behaviour for assistive technologies
	override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
		guard !tabBar.accessibilityElementIsFocused() else {
			// Scrolling in tab bar is not supported
			return true
		}
		
		if let tab: DashboardTab = {
			switch direction {
				case .right: return DashboardTab.domestic
				case .left: return DashboardTab.international
				default: return Optional.none
			}
		}() {
			selectTab(tab: tab)
			delegate?.holderDashboardView(didDisplay: tab)
		}
		
		// Scroll via swipe gesture
		return false
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateStackViewInsets()
	}
	
	private func updateStackViewInsets() {
		guard let windowWidth = UIApplication.shared.keyWindow?.bounds.width else { return }
		
		let insets: NSDirectionalEdgeInsets? = {
			guard !(traitCollection.preferredContentSizeCategory.isAccessibilityCategory || traitCollection.horizontalSizeClass == .compact)
			else { return nil }
			
			let contentPercentageWidth: CGFloat = 0.65
			let horizontalInset = CGFloat((windowWidth - windowWidth * contentPercentageWidth) / 2)
			return NSDirectionalEdgeInsets(top: 8, leading: horizontalInset, bottom: 8, trailing: horizontalInset)
		}()
		
		domesticScrollView.stackView.insets(insets)
		internationalScrollView.stackView.insets(insets)
	}
	
	// MARK: - Public Access
	
	/// Display primary button view
	var shouldDisplayButtonView = false {
		didSet {
			footerButtonView.isHidden = !shouldDisplayButtonView
			bottomScrollViewConstraint?.isActive = false
			let anchor: NSLayoutYAxisAnchor = shouldDisplayButtonView ? footerButtonView.topAnchor : self.bottomAnchor
			bottomScrollViewConstraint = scrollView.bottomAnchor.constraint(equalTo: anchor)
			bottomScrollViewConstraint?.isActive = true
		}
	}

	/// Updates selected tab position
	func updateScrollPosition() {
		guard shouldShowTabBar else { return }
		let selectedTab = tabBar.selectedTab.rawValue
		scrollView.contentOffset = CGPoint(x: scrollView.bounds.width * CGFloat(selectedTab), y: 0)
	}
	
	/// Selects a tab view shown on start
	/// - Parameter tab: The dashboard tab
	func selectTab(tab: DashboardTab) {
		tabBar.select(tab: tab, animated: false)
		
		updateScrollPosition()
		updateScrollViewContentOffsetObserver(for: tab)
	}
	
	var tapMenuButtonHandler: (() -> Void)? {
		didSet {
			fakeNavigationBar.tapMenuButtonHandler = tapMenuButtonHandler
		}
	}
	
	var shouldShowTabBar: Bool = true {
		didSet {
			
			// Ordering is important here to prevent autolayout complaints, so using if/else rather than setting directly:
			if shouldShowTabBar {
				scrollViewTopConstraintWithoutTabBar.isActive = false
				scrollViewTopConstraintWithTabBar.isActive = true
				tabBar.isHidden = false
			} else {
				tabBar.isHidden = true
				scrollViewTopConstraintWithTabBar.isActive = false
				scrollViewTopConstraintWithoutTabBar.isActive = true
				UIAccessibility.post(notification: .layoutChanged, argument: self)
			}
			setNeedsLayout()
		}
	}
	
	var shouldShowOnlyInternationalPane: Bool = false {
		didSet {
			guard oldValue != shouldShowOnlyInternationalPane else { return }
			if shouldShowOnlyInternationalPane {
				domesticScrollView.removeFromSuperview()
				NSLayoutConstraint.deactivate(domesticTabEnabledConstraints)
				NSLayoutConstraint.activate(domesticTabDisabledConstraints)
				UIAccessibility.post(notification: .layoutChanged, argument: self)
			} else {
				scrollView.addSubview(domesticScrollView)
				NSLayoutConstraint.deactivate(domesticTabDisabledConstraints)
				NSLayoutConstraint.activate(domesticTabEnabledConstraints)
			}
			setNeedsLayout()
		}
	}
	
	var fakeNavigationTitle: String? {
		didSet {
			fakeNavigationBar.title = fakeNavigationTitle
		}
	}
	
	var fakeNavigationBarAlpha: CGFloat {
		get {
			fakeNavigationBar.alpha
		}
		set {
			fakeNavigationBar.alpha = newValue
		}
	}
}

private extension HolderDashboardView {
	
	func updateScrollViewContentOffsetObserver(for tab: DashboardTab) {
		let scrollView = tab.isDomestic ? domesticScrollView.scrollView : internationalScrollView.scrollView
		updateFooterViewAnimation(for: scrollView)
		
		scrollViewContentOffsetObserver?.invalidate()
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			self?.updateFooterViewAnimation(for: scrollView)
		}
	}
	
	func updateFooterViewAnimation(for scrollView: UIScrollView) {
		let translatedOffset = scrollView.translatedBottomScrollOffset
		footerButtonView.updateFadeAnimation(from: translatedOffset)
	}
	
	func selectedTab(for scrollView: UIScrollView) -> DashboardTab {
		let scrollViewWidth = scrollView.bounds.width
		let pageScroll = 1.5 * scrollViewWidth
		let internationalPage = scrollView.contentOffset.x + scrollViewWidth > pageScroll
		return internationalPage ? .international : .domestic
	}
}

extension HolderDashboardView: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard scrollView.isDragging else { return }
		let selectedTab = selectedTab(for: scrollView)
		let hasTabChanged = tabBar.selectedTab != selectedTab
		
		guard hasTabChanged else { return }
		tabBar.select(tab: selectedTab, animated: true)
		
		updateScrollViewContentOffsetObserver(for: selectedTab)
		delegate?.holderDashboardView(didDisplay: selectedTab)
	}
}

extension HolderDashboardView: DashboardTabBarDelegate {
	
	func dashboardTabBar(didSelect tab: DashboardTab) {
		let scrollOffset = CGPoint(x: scrollView.bounds.width * CGFloat(tab.rawValue), y: 0)
		scrollView.setContentOffset(scrollOffset, animated: true)
		UIAccessibility.post(notification: .pageScrolled, argument: nil)
				
		updateScrollViewContentOffsetObserver(for: tab)
		delegate?.holderDashboardView(didDisplay: tab)
	}
}

extension HolderDashboardView: UIScrollViewAccessibilityDelegate {
	
	func accessibilityScrollStatus(for scrollView: UIScrollView) -> String? {
		let selectedTab = selectedTab(for: scrollView)
		return selectedTab == .domestic ? L.generalNetherlands() : L.generalEuropeanUnion()
	}
}
