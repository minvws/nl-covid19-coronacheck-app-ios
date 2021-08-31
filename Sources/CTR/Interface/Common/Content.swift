/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

// A common class for displaying content. Most of our pages consist of a title, a body/subTitle
// and a primary action (aka the big blue button at the bottom) + button title.
// This struct also has an optional second action + button title for more flexibility.
struct Content {
	let title: String
	let subTitle: String?
	let primaryActionTitle: String?
	let primaryAction: (() -> Void)?
	let secondaryActionTitle: String?
	let secondaryAction: (() -> Void)?
}
