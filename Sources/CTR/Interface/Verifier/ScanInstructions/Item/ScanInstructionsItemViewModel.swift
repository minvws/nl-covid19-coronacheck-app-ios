/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanInstructionsItemViewModel {

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var animationName: String?
	
	init(page: ScanInstructionsItem) {

		title = page.title
		message = page.message
		animationName = page.animationName
	}
}
