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
	weak private var appInstalledSinceManager: AppInstalledSinceManaging? = Services.appInstalledSinceManager

	private var scanLogStorageMinutes: Int

	@Bindable private(set) var title: String = L.scan_log_title()
	@Bindable private(set) var message: String
	@Bindable private(set) var appInUseSince: String?
	@Bindable private(set) var listHeader: String
	@Bindable private(set) var displayEntries: [ScanLogDisplayEntry] = []

	init(
		coordinator: OpenUrlProtocol,
		configuration: RemoteConfiguration,
		now: @escaping () -> Date
	) {
		self.coordinator = coordinator

		scanLogStorageMinutes = (configuration.scanLogStorageSeconds ?? 3600) / 60

		message = L.scan_log_message("\(scanLogStorageMinutes)")
		listHeader = L.scan_log_list_header(scanLogStorageMinutes)
		handleFirstUseDate(now)

		let entries = scanManager?.getScanEntries(seconds: configuration.scanLogStorageSeconds ?? 3600) ?? []
		handleScanLogEntries(entries)
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}

	private func handleFirstUseDate(_ now: @escaping () -> Date) {

		if let firstUseDate = appInstalledSinceManager?.firstUseDate {
			if firstUseDate < now().addingTimeInterval(-30 * 24 * 60 * 60) { // Cut off 30 days
				appInUseSince = L.scan_log_footer_long_time()
			} else {
				let dateFormatter = DateFormatter()
				dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
				dateFormatter.dateFormat = "d MMMM yyyy HH:mm"
				appInUseSince = L.scan_log_footer_in_use(dateFormatter.string(from: firstUseDate))
			}
		}

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
