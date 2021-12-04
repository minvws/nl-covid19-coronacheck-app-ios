/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol HolderDashboardViewDelegate: AnyObject {
	
	func holderDashboardView(_ view: HolderDashboardView, didDisplay tab: DashboardTab)
}

final class HolderDashboardView: BaseView {
	
	weak var delegate: HolderDashboardViewDelegate?
	
	/// The display constants
	private enum ViewTraits {
		
		enum Spacing {
			static let stackView: CGFloat = 24
		}
	}
	
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
		scrollView.backgroundColor = Theme.colors.viewControllerBackground
		return scrollView
	}()
	
	/// The scrolled stackview to display international cards
	let internationalScrollView: ScrolledStackView = {
		let scrollView = ScrolledStackView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.stackView.spacing = ViewTraits.Spacing.stackView
		scrollView.backgroundColor = Theme.colors.viewControllerBackground
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
	
	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
		
		tabBar.delegate = self
		scrollView.delegate = self
		footerButtonView.isHidden = true
	}
	
	/// Setup the view hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(tabBar)
		addSubview(scrollView)
		addSubview(footerButtonView)
		scrollView.addSubview(domesticScrollView)
		scrollView.addSubview(internationalScrollView)
	}
	
	/// Setup all the constraints
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			tabBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			tabBar.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			tabBar.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			
			scrollView.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
			scrollView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			scrollView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			{
				let constraint = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
				bottomScrollViewConstraint = constraint
				return constraint
			}(),
			
			footerButtonView.leftAnchor.constraint(equalTo: leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			domesticScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			domesticScrollView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
			domesticScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			domesticScrollView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor),
			{
				let constraint = domesticScrollView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
				constraint.priority = .defaultLow
				return constraint
			}(),
			
			internationalScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			internationalScrollView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
			internationalScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			internationalScrollView.leftAnchor.constraint(equalTo: domesticScrollView.rightAnchor),
			internationalScrollView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor),
			{
				let constraint = internationalScrollView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
				constraint.priority = .defaultLow
				return constraint
			}()
		])
	}
	
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
}

extension HolderDashboardView: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard scrollView.isDragging else { return }
		let scrollViewWidth = scrollView.bounds.width
		let pageScroll = 1.5 * scrollViewWidth
		let nextPage = scrollView.contentOffset.x + scrollViewWidth > pageScroll
		let selectedTab: DashboardTab = nextPage ? .international : .domestic
		let hasTabChanged = tabBar.selectedTab != selectedTab
		
		guard hasTabChanged else { return }
		tabBar.select(tab: selectedTab, animated: true)
		
		updateScrollViewContentOffsetObserver(for: selectedTab)
		delegate?.holderDashboardView(self, didDisplay: selectedTab)
	}
}

extension HolderDashboardView: DashboardTabBarDelegate {
	
	func dashboardTabBar(_ tabBar: DashboardTabBar, didSelect tab: DashboardTab) {
		let scrollOffset = CGPoint(x: scrollView.bounds.width * CGFloat(tab.rawValue), y: 0)
		scrollView.setContentOffset(scrollOffset, animated: true)
		UIAccessibility.post(notification: .pageScrolled, argument: nil)
				
		updateScrollViewContentOffsetObserver(for: tab)
		delegate?.holderDashboardView(self, didDisplay: tab)
	}
}
