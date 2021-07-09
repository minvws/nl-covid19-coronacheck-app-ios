/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class HolderDashboardView: ScrolledStackWithButtonView {
	
	private var scrollViewToFooterConstraint: NSLayoutConstraint?
	
	private let changeRegionView: ChangeRegionView = {
		let view = ChangeRegionView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	override func setupViews() {
		super.setupViews()
		stackView.distribution = .fill
		stackView.spacing = 40
	}
	
	func setupPrimaryButton(display: Bool) {
		if display {
			// Display button and background
			bottomScrollViewConstraint?.isActive = false
			
			NSLayoutConstraint.activate([
				{
					let constraint = scrollView.bottomAnchor.constraint(equalTo: footerBackground.topAnchor)
					scrollViewToFooterConstraint = constraint
					return constraint
				}()
			])
			
			setupPrimaryButton()
		} else if primaryButton.superview != nil, bottomScrollViewConstraint?.isActive == false {
			// Hide button
			primaryButton.removeFromSuperview()
			
			// Hide button background
			bottomScrollViewConstraint?.isActive = true
			scrollViewToFooterConstraint?.isActive = false
		}
	}
	
	func setupRegionButton(buttonTitle: String?, currentLocationTitle: String?, actionHandler: (() -> Void)?) {
		if let buttonTitle = buttonTitle,
		   let currentLocationTitle = currentLocationTitle,
		   let actionHandler = actionHandler {
			
			hasFooterView = true
			
			changeRegionView.changeRegionButtonTitle = buttonTitle
			changeRegionView.currentLocationTitle = currentLocationTitle
			changeRegionView.changeRegionButtonTappedCommand = actionHandler
			contentScrollView.addSubview(changeRegionView)
			
			NSLayoutConstraint.activate([
				changeRegionView.topAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: 32),
				changeRegionView.leftAnchor.constraint(equalTo: contentScrollView.leftAnchor),
				changeRegionView.rightAnchor.constraint(equalTo: contentScrollView.rightAnchor),
				changeRegionView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
				changeRegionView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor)
			])
		} else {
			changeRegionView.removeFromSuperview()
			hasFooterView = false
		}
	}
}
