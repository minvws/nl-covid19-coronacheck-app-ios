/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

enum ScanLogDisplayEntry {

	case message (message: String)

	case entry(type: String, timeInterval: String, message: String, warning: String?)
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
	@Bindable private(set) var alert: AlertContent?

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
		listHeader = L.scan_log_list_header(scanLogStorageMinutes)

		//		ScanLogManager().addScanEntry(riskLevel: .low, date: Date().addingTimeInterval(-11 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .low, date: Date().addingTimeInterval(-12 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .low, date: Date().addingTimeInterval(-11 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .low, date: Date().addingTimeInterval(-10 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .low, date: Date().addingTimeInterval(-9 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .low, date: Date().addingTimeInterval(-8 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .low, date: Date().addingTimeInterval(-7 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .low, date: Date().addingTimeInterval(-6 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .low, date: Date().addingTimeInterval(-5 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .high, date: Date().addingTimeInterval(-4 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .high, date: Date().addingTimeInterval(-3 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .high, date: Date().addingTimeInterval(-2 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .low, date: Date().addingTimeInterval(-1.5 * 60))
		//		ScanLogManager().addScanEntry(riskLevel: .low, date: Date().addingTimeInterval(-1 * 60))

		handleScanEntries(scanLogStorageMinutes)
	}

	private func handleScanEntries(_ scanLogStorageMinutes: Int) {

		guard let scanManager = scanManager else { return }

		let result = scanManager.getScanEntries(seconds: scanLogStorageMinutes)
		switch result {
			case let .success(log):
				displayEntries.append(contentsOf: ScanLogDataSource(entries: log).getDisplayEntries())
			case .failure:
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
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}
}

struct ScanLogDataSource: Logging {

	struct LineItem {
		var mode: String
		var count = 0
		var skew: Bool = false
		var from: Date?
		var to: Date?
	}

	let timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm"
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
		return sortAndSplitEtc()
	}

	func sortAndSplitEtc() -> [ScanLogDisplayEntry] {

		let sortedEntries = entries.sortedByIdentifier()
		var currentTime: Date?
		var lineItem: LineItem?
		var log: [LineItem] = []

		sortedEntries.forEach { scan in

//			logInfo("entry \(scan.identifier) \(scan.mode) \(scan.date)")

			guard let scanDate = scan.date, let scanMode = scan.mode else {
				return
			}

			if lineItem == nil ||
				scanMode != lineItem?.mode ||
				(currentTime != nil &&
				 currentTime! > scanDate) {
				if let item = lineItem {
					// We had a previous line item, put it on the log stack.
					log.append(item)
				}
				// Switch occurred
				lineItem = LineItem(mode: scanMode)
				if let currentTime = currentTime, currentTime > scanDate {
					lineItem?.skew = true
				}
			}

			currentTime = scanDate
			lineItem?.count += 1

			if let lineItemTo = lineItem?.to {
				lineItem?.to = max(scanDate, lineItemTo)
			} else {
				lineItem?.to = scanDate
			}

			if let lineItemFrom = lineItem?.from {
				lineItem?.from = min(scanDate, lineItemFrom)
			} else {
				lineItem?.from = scanDate
			}
		}

		if let item = lineItem {
			// At the end of the loop, process the last lineItem.
			log.append(item)
		}

		// We want to display last switch first, so finally reverse the log
		log = log.reversed()

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

	private func convert(_ item: LineItem, replaceToDate: Bool) -> ScanLogDisplayEntry? {

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
