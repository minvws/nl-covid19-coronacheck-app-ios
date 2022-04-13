/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

struct PagedAnnoucementItem: Equatable {

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
