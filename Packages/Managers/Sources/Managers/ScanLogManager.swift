/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import CoreData
import Shared
import Persistence
import Models

public protocol ScanLogManaging: AnyObject {

	func didWeScanQRs(withinLastNumberOfSeconds: Int, now: Date) -> Bool

	func getScanEntries(withinLastNumberOfSeconds: Int, now: Date) -> Result<[ScanLogEntry], Error>

	func addScanEntry(verificationPolicy: VerificationPolicy, date: Date)

	func wipePersistedData()
}

public class ScanLogManager: ScanLogManaging {

	public static let policy1G: String = "1G"
	public static let policy3G: String = "3G"

	private var dataStoreManager: DataStoreManaging
	private let notificationCenter: NotificationCenterProtocol
	private let remoteConfigManager: RemoteConfigManaging
	private let now: () -> Date
	
	public required init(dataStoreManager: DataStoreManaging, remoteConfigManager: RemoteConfigManaging, now: @escaping () -> Date, notificationCenter: NotificationCenterProtocol = NotificationCenter.default) {

		self.dataStoreManager = dataStoreManager
		self.remoteConfigManager = remoteConfigManager
		self.now = now
		self.notificationCenter = notificationCenter
		setupNotificationObservers()
	}
	
	deinit {
		notificationCenter.removeObserver(self)
	}
	
	private func setupNotificationObservers() {
		
		guard AppFlavor.flavor == .verifier else {
			// There is no scan log database on the holder
			return
		}
		
		notificationCenter.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
			guard let self else { return }
			self.deleteExpiredScanLogEntries(
				seconds: self.remoteConfigManager.storedConfiguration.scanLogStorageSeconds ?? 3600,
				now: self.now()
			)
		}
	}

	public func didWeScanQRs(withinLastNumberOfSeconds seconds: Int, now: Date) -> Bool {

		switch getScanEntries(withinLastNumberOfSeconds: seconds, now: now) {
			case .success(let log): return !log.isEmpty
			case .failure: return false
		}
	}

	public func getScanEntries(withinLastNumberOfSeconds seconds: Int, now: Date) -> Result<[ScanLogEntry], Error> {

		var result: Result<[ScanLogEntry], Error> = .success([])
		let fromDate = now.addingTimeInterval(TimeInterval(seconds) * -1)

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			result = ScanLogEntryModel.listEntriesStartingFrom(date: fromDate, managedContext: context)
		}
		return result
	}

	public func addScanEntry(verificationPolicy: VerificationPolicy, date: Date) {
		
		// Nothing for now
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			var mode: String = ""
			switch verificationPolicy {
				case .policy3G:
					mode = ScanLogManager.policy3G
				case .policy1G:
					mode = ScanLogManager.policy1G
			}
			let entry = ScanLogEntry(mode: mode, date: date, managedContext: context)
			dataStoreManager.save(context)

			// Update the auto_increment identifier
			entry.identifier = entry.autoId
			dataStoreManager.save(context)
		}
	}

	public func deleteExpiredScanLogEntries(seconds: Int, now: Date) {

		let untilDate = now.addingTimeInterval(TimeInterval(seconds) * -1)
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			let result = ScanLogEntryModel.listEntriesUpTo(date: untilDate, managedContext: context)
			switch result {
				case let .success(entries):
					entries.forEach { context.delete($0) }
				case .failure:
					break
			}
			dataStoreManager.save(context)
		}
	}

	public func wipePersistedData() {

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			let result = ScanLogEntryModel.listEntries(managedContext: context)
			switch result {
				case let .success(entries):
					entries.forEach { context.delete($0) }
				case .failure:
					break
			}
			dataStoreManager.save(context)
		}
	}
}
