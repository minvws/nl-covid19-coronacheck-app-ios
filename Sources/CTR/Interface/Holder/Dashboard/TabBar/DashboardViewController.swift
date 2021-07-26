/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DashboardViewController: BaseViewController {
	
	private let topTabBar = TopTabBar()
	private let scrollView = UIScrollView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Mijn bewijzen"
		
		view.addSubview(topTabBar)
		topTabBar.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			topTabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			topTabBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
			topTabBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
			
			scrollView.topAnchor.constraint(equalTo: topTabBar.bottomAnchor),
			scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
			scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
}
