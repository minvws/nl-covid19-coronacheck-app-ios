/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// the what's new pages content for the forced information
struct ForcedInformationPage {

	/// The image of a forced information page
	let image: UIImage

	/// The tagline of a forced information page
	let tagline: String

	/// The title of a forced information page
	let title: String

	/// The content of a forced information page
	let content: String
}

/// The content for the consent part of the forced information
struct ForcedInformationConsent: Equatable {

	/// The title of the  forced information consent
	let title: String

	/// The highlights of the  forced information consent
	let highlight: String

	/// The content of the  forced information consent
	let content: String

	/// True if consent must be given, False if consent is not required
	let consentMandatory: Bool
}

/// A struct to use for combining all the content needed for forced information
struct ForcedInformation {

	/// An array of additional onboarding pages
	let pages: [ForcedInformationPage]

	/// Optional new consent
	let consent: ForcedInformationConsent?

	/// The version of the forced information
	let version: Int
}
