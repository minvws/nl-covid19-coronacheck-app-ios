/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DashboardViewController: BaseViewController {
	
	private let topTabBar: TopTabBar = {
		let tabBar = TopTabBar()
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
	
	private let domesticScrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.backgroundColor = Theme.colors.grey5
		return scrollView
	}()
	
	private let internationalScrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.backgroundColor = Theme.colors.grey4
		return scrollView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Mijn bewijzen"
		
		view.addSubview(topTabBar)
		view.addSubview(scrollView)
		scrollView.delegate = self
		scrollView.addSubview(domesticScrollView)
		scrollView.addSubview(internationalScrollView)
		
		NSLayoutConstraint.activate([
			topTabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			topTabBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
			topTabBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
			
			scrollView.topAnchor.constraint(equalTo: topTabBar.bottomAnchor),
			scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
			scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			domesticScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			domesticScrollView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
			domesticScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			domesticScrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
			{
				let constraint = domesticScrollView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
				constraint.priority = .defaultLow
				return constraint
			}(),
			
			internationalScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			internationalScrollView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
			internationalScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			internationalScrollView.leftAnchor.constraint(equalTo: domesticScrollView.rightAnchor),
			internationalScrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
			{
				let constraint = internationalScrollView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
				constraint.priority = .defaultLow
				return constraint
			}()
		])
	}
}

extension DashboardViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard scrollView.isDragging else { return }
		let scrollViewWidth = scrollView.frame.width
		let pageScroll = 1.5 * scrollViewWidth
		let nextPage = scrollView.contentOffset.x + scrollViewWidth > pageScroll
		let tab: TopTabBar.Tab = nextPage ? .international : .domestic
		topTabBar.select(tab: tab, animated: true)
	}
}
