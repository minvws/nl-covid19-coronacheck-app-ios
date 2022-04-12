/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The what's new pages content for the new feature
struct NewFeatureItem: Equatable {

	/// The title of a new feature page
	let title: String

	/// The content of a new feature page
	let content: String

	/// The image of a new feature page
	let image: UIImage?

	let imageBackgroundColor: UIColor?

	/// The tagline of a new feature page
	let tagline: String?
 
	/// The step of the onboarding page
	let step: Int
}

/// A struct to use for combining all the content needed for new feature
struct NewFeatureInformation {

	/// An array of additional onboarding pages
	let pages: [NewFeatureItem]

	/// The version of the new feature
	let version: Int
}
