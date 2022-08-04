/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import CoreData

protocol ScanLogManaging: AnyObject {

	func didWeScanQRs(withinLastNumberOfSeconds: Int, now: Date) -> Bool

	func getScanEntries(withinLastNumberOfSeconds: Int, now: Date) -> Result<[ScanLogEntry], Error>

	func addScanEntry(verificationPolicy: VerificationPolicy, date: Date)

	func wipePersistedData()
}

class ScanLogManager: ScanLogManaging {

	static let policy1G: String = "1G"
	static let policy3G: String = "3G"

	private var dataStoreManager: DataStoreManaging
	private let notificationCenter: NotificationCenterProtocol

	required init(dataStoreManager: DataStoreManaging, notificationCenter: NotificationCenterProtocol = NotificationCenter.default) {

		self.dataStoreManager = dataStoreManager
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
			self?.deleteExpiredScanLogEntries(
				seconds: Current.remoteConfigManager.storedConfiguration.scanLogStorageSeconds ?? 3600,
				now: Current.now()
			)
		}
	}

	func didWeScanQRs(withinLastNumberOfSeconds seconds: Int, now: Date) -> Bool {

		switch getScanEntries(withinLastNumberOfSeconds: seconds, now: now) {
			case .success(let log): return !log.isEmpty
			case .failure: return false
		}
	}

	func getScanEntries(withinLastNumberOfSeconds seconds: Int, now: Date) -> Result<[ScanLogEntry], Error> {

		var result: Result<[ScanLogEntry], Error> = .success([])
		let fromDate = now.addingTimeInterval(TimeInterval(seconds) * -1)

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			result = ScanLogEntryModel.listEntriesStartingFrom(date: fromDate, managedContext: context)
		}
		return result
	}

	func addScanEntry(verificationPolicy: VerificationPolicy, date: Date) {
		
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
			let entry = ScanLogEntryModel.create(mode: mode, date: date, managedContext: context)
			dataStoreManager.save(context)

			// Update the auto_increment identifier
			entry?.identifier = entry?.autoId ?? 0
			dataStoreManager.save(context)
		}
	}

	func deleteExpiredScanLogEntries(seconds: Int, now: Date) {

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

	func wipePersistedData() {

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

extension NSManagedObject {

	var autoId: Int64 {
		/*
		 Core Data automatically generate auto increment id for each managed object.

		 The unique auto id is however not exposed through the api. However, there is [NSManagedObject objectID]
		 method that returns the unique path for each object.

		 Its usually in the form <x-coredata://SOME_ID/Entity/ObjectID>
		 e.g <x-coredata://197823AB-8917-408A-AD72-3BE89F0981F0/Message/p12> for object of Message entity with ID `p12.
		 The numeric part of the ID (last segment of the path) is the auto increment value for each object.
		 */

		let urlString = self.objectID.uriRepresentation().absoluteString
		let parts = urlString.components(separatedBy: "/")
		if let numberPart = parts.last?.replacingOccurrences(of: "p", with: ""),
			let value = Int64(numberPart) {
			return value
		}
		return 0
	}
}
