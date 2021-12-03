/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

enum ScanLogDisplayEntry {

	case message (message: String)

	case entry(type: String, timeInterval: String, message: String)
}

class ScanLogViewModel {

	weak private var coordinator: OpenUrlProtocol?

	weak private var scanManager: ScanLogManaging? = Services.scanManager

	private var scanLogStorageMinutes: Int

	@Bindable private(set) var title: String = L.scan_log_title()
	@Bindable private(set) var message: String
	@Bindable private(set) var appInUseSince: String
	@Bindable private(set) var listHeader: String
	@Bindable private(set) var displayEntries: [ScanLogDisplayEntry] = []

	init(
		coordinator: OpenUrlProtocol,
		configuration: RemoteConfiguration
	) {
		self.coordinator = coordinator
		scanLogStorageMinutes = (configuration.scanLogStorageSeconds ?? 3600) / 60

		// Todo: Insert the actual first usage timestamp in the placeholder,
		// and check if it is older than a month
		appInUseSince = L.scan_log_footer_long_time()

		message = L.scan_log_message("\(scanLogStorageMinutes)")
		listHeader = L.scan_log_list_header("\(scanLogStorageMinutes)")

		let entries = scanManager?.getScanEntries(seconds: configuration.scanLogStorageSeconds ?? 3600) ?? []
		handleScanLogEntries(entries)
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}

	private func handleScanLogEntries(_ entries: [ScanLogEntry]) {

		guard !entries.isEmpty else {

			displayEntries.append(.message(message: L.scan_log_list_no_items()))
			return
		}
//		displayEntries.append(.message(message: L.scan_log_list_no_items()))
//		displayEntries.append(.entry(type: L.scan_log_list_lowrisk(), timeInterval: "22:02 - nu", message: "1 tot 10 bewijzen gescand"))
	}
}
