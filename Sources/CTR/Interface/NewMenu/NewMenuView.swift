/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class NewMenuView: ScrolledStackView {

	// MARK: - Lifecycle
	
	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = C.primaryBlue5()
		
		stackViewInset = .zero
		stackView.spacing = 0
	}
}
