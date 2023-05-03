/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Persistence
import Managers
import Resources
import DataMigration
import Transport

class ImportViewModel: ScanPermissionViewModel {

	/// Coordination Delegate
	weak var theCoordinator: (MigrationCoordinatorDelegate & OpenUrlProtocol)?
	
	var dataImporter: DataImporter?

	var title = Observable<String>(value: L.holder_scanner_title())
	var step = Observable<String>(value: L.holder_startMigration_onboarding_step("3"))
	var header = Observable<String>(value: L.holder_startMigration_toThisDevice_onboarding_step3_title())
	var message = Observable<String>(value: L.holder_startMigration_toThisDevice_onboarding_step3_message())
	var torchLabels = Observable<[String]>(value: [L.holderTokenscanTorchEnable(), L.holderTokenscanTorchDisable()])
	var shouldStopScanning = Observable<Bool>(value: false)
	var progress = Observable<Float?>(value: nil)

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - scanner: the paper proof scanner
	init(
		coordinator: (MigrationCoordinatorDelegate & OpenUrlProtocol),
		version: String
	) {
		
		self.theCoordinator = coordinator
		super.init(coordinator: coordinator)
		self.dataImporter = DataImporter(version: version, delegate: self)
	}

	/// Parse the scanned QR-code
	/// - Parameter code: the scanned code
	func parseQRMessage(_ qrMessage: String) {
		
		guard !shouldStopScanning.value else { return }
		logVerbose("Scanned \(qrMessage)")
		do {
			try dataImporter?.importString(qrMessage)
		} catch let error {
			shouldStopScanning.value = true
			let errorCode: ErrorCode
			switch error {
				case DataMigrationError.compressionError:
					errorCode = ErrorCode(flow: .migration, step: .import, clientCode: .compressionError)
				case DataMigrationError.invalidVersion:
					errorCode = ErrorCode(flow: .migration, step: .import, clientCode: .invalidVersion)
				case DataMigrationError.invalidNumberOfPackages:
					errorCode = ErrorCode(flow: .migration, step: .import, clientCode: .invalidNumberOfPackages)
				default:
					errorCode = ErrorCode(flow: .migration, step: .import, clientCode: .other)
			}
			theCoordinator?.presentError(errorCode)
		}
	}
}

extension ImportViewModel: DataImportDelegate {

	func completed(_ value: Data) {

		shouldStopScanning.value = true

		let decoder = JSONDecoder()
		do {
			let parcels = try decoder.decode([EventGroupParcel].self, from: value)
			theCoordinator?.userWishesToSeeScannedEvents(parcels)
		} catch {
			theCoordinator?.presentError(ErrorCode(flow: .migration, step: .import, clientCode: .decodingError))
		}
	}
	
	func progress(_ percentage: Float) {
		// percentage / 100, as progress is 0 ... 1
		self.progress.value = percentage / 100
		if percentage > 0 {
			// Update texts if we are scanning
			header.value = L.holder_startMigration_toThisDevice_onboarding_step3_titleScanning()
			message.value = L.holder_startMigration_toThisDevice_onboarding_step3_messageKeepPointing()
		}
	}
}
