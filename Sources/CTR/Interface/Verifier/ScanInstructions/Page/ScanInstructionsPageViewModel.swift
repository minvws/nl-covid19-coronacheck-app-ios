/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanInstructionsPageViewModel {

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var image: UIImage?
	
	init(page: ScanInstructionsPage) {

		title = page.title
		message = page.message
		image = page.image
	}
}
