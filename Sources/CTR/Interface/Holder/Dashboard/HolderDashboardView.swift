/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class HolderDashboardView: BaseView {
	
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
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(tabBar)
		tabBar.delegate = self
		addSubview(scrollView)
		scrollView.delegate = self
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
	
	func updateForRotation() {
		let selectedTab = tabBar.selectedTab.rawValue
		scrollView.contentOffset = CGPoint(x: scrollView.bounds.width * CGFloat(selectedTab), y: 0)
	}
}

extension HolderDashboardView: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard scrollView.isDragging else { return }
		let scrollViewWidth = scrollView.frame.width
		let pageScroll = 1.5 * scrollViewWidth
		let nextPage = scrollView.contentOffset.x + scrollViewWidth > pageScroll
		tabBar.selectedTab = nextPage ? .international : .domestic
	}
}

extension HolderDashboardView: DashboardTabBarDelegate {
	
	func dashboardTabBar(_ tabBar: DashboardTabBar, didSelect tab: DashboardTabBar.Tab) {
		let scrollOffset = CGPoint(x: scrollView.frame.width * CGFloat(tab.rawValue), y: 0)
		scrollView.setContentOffset(scrollOffset, animated: true)
	}
}
