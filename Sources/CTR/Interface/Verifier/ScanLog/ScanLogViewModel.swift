/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

enum ScanLogDisplayEntry: Equatable {

	case message (message: String)

	case entry(type: String, timeInterval: String, message: String, warning: String?)
}

class ScanLogViewModel {

	weak private var coordinator: OpenUrlProtocol?

	weak private var scanManager: ScanLogManaging? = Services.scanLogManager
	weak private var appInstalledSinceManager: AppInstalledSinceManaging? = Services.appInstalledSinceManager

	@Bindable private(set) var title: String = L.scan_log_title()
	@Bindable private(set) var message: String
	@Bindable private(set) var appInUseSince: String?
	@Bindable private(set) var listHeader: String
	@Bindable private(set) var displayEntries: [ScanLogDisplayEntry] = []
	@Bindable private(set) var alert: AlertContent?

	init(
		coordinator: OpenUrlProtocol,
		configuration: RemoteConfiguration,
		now: @escaping () -> Date
	) {
		self.coordinator = coordinator
		let scanLogStorageSeconds: Int = configuration.scanLogStorageSeconds ?? 3600
		let scanLogStorageMinutes: Int = scanLogStorageSeconds / 60

		message = L.scan_log_message("\(scanLogStorageMinutes)")
		listHeader = L.scan_log_list_header(scanLogStorageMinutes)
		handleFirstUseDate(now)
		handleScanEntries(scanLogStorageSeconds)
	}

	private func handleScanEntries(_ scanLogStorageMinutes: Int) {

		guard let scanManager = scanManager else { return }

		let result = scanManager.getScanEntries(seconds: scanLogStorageMinutes)
		switch result {
			case let .success(log):
				displayEntries.append(contentsOf: ScanLogDataSource(entries: log).getDisplayEntries())
			case .failure:
				handleCoreDataError()
		}
	}

	private func handleCoreDataError() {

		let code = ErrorCode(flow: .scanFlow, step: .showLog, clientCode: .coreDataFetchError)
		alert = AlertContent(
			title: L.generalErrorTitle(),
			subTitle: L.generalErrorTechnicalCustom("\(code)"),
			cancelAction: nil,
			cancelTitle: nil,
			okAction: nil,
			okTitle: L.generalClose()
		)
	}

	private func handleFirstUseDate(_ now: @escaping () -> Date) {

		guard let firstUseDate = appInstalledSinceManager?.firstUseDate else { return }
		if firstUseDate < now().addingTimeInterval(-30 * 24 * 60 * 60) { // Cut off 30 days
			appInUseSince = L.scan_log_footer_long_time()
		} else {
			let dateFormatter = DateFormatter()
			dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
			dateFormatter.dateFormat = "d MMMM yyyy HH:mm"
			appInUseSince = L.scan_log_footer_in_use(dateFormatter.string(from: firstUseDate))
		}
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}
}

struct ScanLogDataSource: Logging {

	struct ScanLogLineItem {
		var mode: String
		var count = 0
		var skew: Bool = false
		var from: Date?
		var to: Date?

		mutating func updateToDate(_ scanDate: Date) {
			if let itemTo = to {
				to = max(scanDate, itemTo)
			} else {
				to = scanDate
			}
		}

		mutating func updateFromDate(_ scanDate: Date) {
			if let itemFrom = from {
				from = min(scanDate, itemFrom)
			} else {
				from = scanDate
			}
		}
	}

	let timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm"
		formatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		return formatter
	}()

	let entries: [ScanLogEntry]

	init(entries: [ScanLogEntry]) {
		self.entries = entries
	}

	func getDisplayEntries() -> [ScanLogDisplayEntry] {

		guard !entries.isEmpty else {
			return [.message(message: L.scan_log_list_no_items())]
		}
		return populateLog(sortedEntries: entries.sortedByIdentifier())
	}

	private func populateLog(sortedEntries: [ScanLogEntry]) -> [ScanLogDisplayEntry] {

		var currentTime: Date?
		var lineItem: ScanLogLineItem?
		var log: [ScanLogLineItem] = []

		sortedEntries.forEach { scan in
			guard let scanDate = scan.date, let scanMode = scan.mode else {
				return
			}

			if lineItem == nil || scanMode != lineItem?.mode ||
				(currentTime != nil && currentTime! > scanDate) {
				if let item = lineItem {
					// We had a previous line item, put it on the log stack.
					log.append(item)
				}
				// Switch occurred
				lineItem = ScanLogLineItem(mode: scanMode)
				if let currentTime = currentTime, currentTime > scanDate {
					lineItem?.skew = true
				}
			}

			currentTime = scanDate
			lineItem?.count += 1
			lineItem?.updateToDate(scanDate)
			lineItem?.updateFromDate(scanDate)
		}

		if let item = lineItem {
			// At the end of the loop, process the last lineItem.
			log.append(item)
		}

		// We want to display last switch first, so finally reverse the log
		log = log.reversed()

		// Convert to display entries
		var result = [ScanLogDisplayEntry]()
		var firstItem = true
		log.forEach { item in

			if let scanLogDisplayEntry = convert(item, replaceToDate: firstItem) {
				firstItem = false
				result.append(scanLogDisplayEntry)
			}
		}
		return result
	}

	private func convert(_ item: ScanLogLineItem, replaceToDate: Bool) -> ScanLogDisplayEntry? {

		// logDebug("convert lineItem : \(item)")
		let roundedToTens = roundToTens(count: item.count)
		guard let itemFrom = item.from, let itemTo = item.to else {
			return nil
		}
		var timeTo = timeFormatter.string(from: itemTo)
		if replaceToDate {
			timeTo = L.scan_log_list_now()
		}

		return ScanLogDisplayEntry.entry(
			type: item.mode,
			timeInterval: timeFormatter.string(from: itemFrom) + " - " + timeTo,
			message: L.scan_log_list_entry(roundedToTens.lowerBound, roundedToTens.higherBound),
			warning: item.skew ? L.scan_log_list_clock_skew_detected() : nil
		)
	}

	// Turn 1, 2, 3, 4, 5, 6, 7, 8, 9 to '1 to 10'
	// 10, 11, 12 become 10-20 etc.
	private func roundToTens(count: Int) -> (lowerBound: Int, higherBound: Int) {

		// the max makes the first one '1 to 10' instead of '0 to 10' while the rest remains '10 - 20'
		let lowerBound = max(1, count - (count % 10))
		let higherBound = count + 10 - (count % 10)

		return (lowerBound: lowerBound, higherBound: higherBound)
	}
}

extension ErrorCode.Flow {

	static let scanFlow = ErrorCode.Flow(value: "1")
}

// MARK: ErrorCode.Step (Scan log flow)
extension ErrorCode.Step {

	static let showLog = ErrorCode.Step(value: "30")
}
