/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class ScanInstructionsView: PagedAnnouncementView {
	
	override func setupContainerViewConstraints() {
		
		NSLayoutConstraint.activate([
			containerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
			containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
	}
}
