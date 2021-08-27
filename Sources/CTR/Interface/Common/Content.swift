/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

struct Content {
	let title: String
	let subTitle: String?
	let primaryActionTitle: String?
	let primaryAction: (() -> Void)?
	let secondaryActionTitle: String?
	let secondaryAction: (() -> Void)?
}
