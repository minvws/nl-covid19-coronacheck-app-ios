/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class NewFeaturesItemViewModel {
	
	@Bindable private(set) var image: UIImage?
	@Bindable private(set) var tagline: String
	@Bindable private(set) var title: String
	@Bindable private(set) var content: String
	
	/// Initializer
	/// - Parameters:
	///   - newFeatureItem: the container with new feature info
	init( newFeatureItem: NewFeatureItem) {
		
		image = newFeatureItem.image
		tagline = newFeatureItem.tagline
		title = newFeatureItem.title
		content = newFeatureItem.content
	}
}
