/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PagedAnnouncementItemViewModel: Logging {
	
	@Bindable private(set) var image: UIImage?
	@Bindable private(set) var tagline: String?
	@Bindable private(set) var title: String
	@Bindable private(set) var content: String
	
	/// Initializer
	/// - Parameters:
	///   - newFeatureItem: the container with new feature info
	init(item: NewFeatureItem) {
		
		image = item.image
		tagline = item.tagline
		title = item.title
		content = item.content
	}
}
