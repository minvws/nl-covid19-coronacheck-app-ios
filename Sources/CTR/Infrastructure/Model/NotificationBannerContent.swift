/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

struct NotificationBannerContent: Equatable {

	/// The title of the banner
	let title: String

	/// The message of the banner
	let message: String?

	/// The icon to display on the banner
	let icon: UIImage?
}
