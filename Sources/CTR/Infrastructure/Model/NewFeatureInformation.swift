/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The what's new pages content for the new feature
struct NewFeatureItem: Equatable {

	/// The image of a new feature page
	let image: UIImage?

	/// The tagline of a new feature page
	let tagline: String

	/// The title of a new feature page
	let title: String

	/// The content of a new feature page
	let content: String
}

/// The content for the consent part of the new feature
struct NewFeatureConsent: Equatable {

	/// The title of the  new feature consent
	let title: String

	/// The highlights of the  new feature consent
	let highlight: String

	/// The content of the  new feature consent
	let content: String

	/// True if consent must be given, False if consent is not required
	let consentMandatory: Bool
}

/// A struct to use for combining all the content needed for new feature
struct NewFeatureInformation {

	/// An array of additional onboarding pages
	let pages: [NewFeatureItem]

	/// Optional new consent
	let consent: NewFeatureConsent?

	/// The version of the new feature
	let version: Int
}
