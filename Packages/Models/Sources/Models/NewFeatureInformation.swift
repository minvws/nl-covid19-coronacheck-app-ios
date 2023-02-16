/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// A struct to use for combining all the content needed for new feature
public struct NewFeatureInformation {

	/// An array of additional onboarding pages
	public let pages: [PagedAnnoucementItem]

	/// The version of the new feature
	public let version: Int
	
	public init(pages: [PagedAnnoucementItem], version: Int) {
		self.pages = pages
		self.version = version
	}
}
