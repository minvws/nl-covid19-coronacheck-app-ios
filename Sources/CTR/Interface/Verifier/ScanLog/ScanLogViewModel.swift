/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class ScanLogViewModel {

	weak private var coordinator: OpenUrlProtocol?

	@Bindable private(set) var title: String = L.scan_log_title()
	@Bindable private(set) var message: String = L.scan_log_message()
	@Bindable private(set) var appInUseSince: String

	init(
		coordinator: OpenUrlProtocol
	) {
		self.coordinator = coordinator

		// Todo: Insert the actual first usage timestamp in the placeholder,
		// and check if it is older than a month
		appInUseSince = L.scan_log_footer_long_time()
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}
}
