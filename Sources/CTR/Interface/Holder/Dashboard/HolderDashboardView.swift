/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class HolderDashboardView: ScrolledStackWithButtonView {
	
	private var scrollViewToFooterConstraint: NSLayoutConstraint?

	override func setupViews() {
		super.setupViews()
		stackView.distribution = .fill
		stackView.spacing = 40
	}
	
	func configurePrimaryButton(display: Bool) {
		if display {
			bottomScrollViewConstraint?.isActive = false
			
			NSLayoutConstraint.activate([
				{
					let constraint = scrollView.bottomAnchor.constraint(equalTo: footerBackground.topAnchor)
					scrollViewToFooterConstraint = constraint
					return constraint
				}()
			])
			
			setupPrimaryButton()
		} else {
			bottomScrollViewConstraint?.isActive = true
			scrollViewToFooterConstraint?.isActive = false
		}
	}
}
