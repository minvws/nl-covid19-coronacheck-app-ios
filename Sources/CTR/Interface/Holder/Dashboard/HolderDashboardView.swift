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
	
	let domesticScrollView: ScrolledStackView = {
		let scrollView = ScrolledStackView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.backgroundColor = Theme.colors.viewControllerBackground
		return scrollView
	}()
	
	let internationalScrollView: ScrolledStackView = {
		let scrollView = ScrolledStackView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.backgroundColor = Theme.colors.viewControllerBackground
		return scrollView
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
		
		tabBar.delegate = self
		scrollView.delegate = self
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(tabBar)
		addSubview(scrollView)
		scrollView.addSubview(domesticScrollView)
		scrollView.addSubview(internationalScrollView)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			tabBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			tabBar.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			tabBar.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			
			scrollView.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
			scrollView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			scrollView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
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
	
	func updateScrollPosition() {
		let selectedTab = tabBar.selectedTab.rawValue
		scrollView.contentOffset = CGPoint(x: scrollView.bounds.width * CGFloat(selectedTab), y: 0)
	}
	
	func select(tab: DashboardTab) {
		tabBar.select(tab: tab, animated: false)
		
		// Run on next runloop to update scroll position
		DispatchQueue.main.asyncAfter(deadline: .now()) {
			self.updateScrollPosition()
		}
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
		tabBar.select(tab: selectedTab, animated: true)
		
		guard hasTabChanged else { return }
		delegate?.holderDashboardView(self, didDisplay: selectedTab)
	}
}

extension HolderDashboardView: DashboardTabBarDelegate {
	
	func dashboardTabBar(_ tabBar: DashboardTabBar, didSelect tab: DashboardTab) {
		let scrollOffset = CGPoint(x: scrollView.bounds.width * CGFloat(tab.rawValue), y: 0)
		scrollView.setContentOffset(scrollOffset, animated: true)
		
		delegate?.holderDashboardView(self, didDisplay: tab)
	}
}
