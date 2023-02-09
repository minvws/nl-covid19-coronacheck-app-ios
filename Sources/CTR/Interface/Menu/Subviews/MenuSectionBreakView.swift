/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class MenuSectionBreakView: BaseView {
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.primaryBlue5()
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		var constraints = [NSLayoutConstraint]()
		constraints += [heightAnchor.constraint(equalToConstant: 24)]
		NSLayoutConstraint.activate(constraints)
	}
	
}
