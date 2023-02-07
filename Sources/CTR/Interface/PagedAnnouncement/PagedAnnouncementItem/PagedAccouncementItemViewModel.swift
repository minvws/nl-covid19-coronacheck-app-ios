/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import Models

class PagedAnnouncementItemViewModel {
	
	@Bindable private(set) var image: UIImage?
	@Bindable private(set) var tagline: String?
	@Bindable private(set) var title: String
	@Bindable private(set) var content: String
	
	init(item: PagedAnnoucementItem) {
		
		image = item.image
		tagline = item.tagline
		title = item.title
		content = item.content
	}
}
