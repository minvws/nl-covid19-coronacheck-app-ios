/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import DataMigration
import Resources
import QRGenerator
import Transport

class ExportLoopViewModel {
	
	weak var delegate: MigrationCoordinatorDelegate?

	private var version: String

	private var imageList: [UIImage]
	
	private var currentPage: Int

	private var animationTimer: Timeable?

	private let frequency: Double = 3.0
	
	// MARK: - Observable

	var title = Observable<String>(value: L.holder_startMigration_onboarding_title())
	var step = Observable<String>(value: L.holder_startMigration_onboarding_step("3"))
	var header = Observable<String>(value: L.holder_startMigration_toOtherDevice_onboarding_step3_title())
	var message = Observable<String>(value: L.holder_startMigration_toOtherDevice_onboarding_step3_message())
	var actionTitle = Observable<String>(value: L.holder_startMigration_onboarding_doneButton())
	var image = Observable<UIImage?>(value: nil)

	/// Initializer
	/// - Parameters:
	///   - delegate: the Data Migration Coordinator Delegate
	///   - version: the version of the data parcels.
	init(delegate: MigrationCoordinatorDelegate?, version: String) {

		self.delegate = delegate
		self.version = version
		currentPage = 0
		imageList = []
		exportEventGroups()
	}
	
	deinit {
		stopTimer()
	}
	
	func exportEventGroups() {

		let eventGroupParcels = listEventGroupParcels()

		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		logDebug("We got \(eventGroupParcels.count) event group parcels")

		if let encoded = try? encoder.encode(eventGroupParcels) {

			do {
				let items = try DataExporter(maxPackageSize: 800, version: version).export(encoded)

				items.forEach { item in
					DispatchQueue.global(qos: .userInitiated).async {
						if let image = item.generateQRCode(correctionLevel: QRGenerator.CorrectionLevel.medium) {
							self.imageList.append(image)
						}
						if self.imageList.count == items.count {
							logDebug("All converted to QR, start animation")
							DispatchQueue.main.async {
								self.startTimer()
							}
						}
					}
				}
			} catch let error {
				presentError(error)
			}
		}
	}
	
	private func listEventGroupParcels() -> [EventGroupParcel] {
		
		let eventGroupParcels: [EventGroupParcel] = Current.walletManager.listEventGroups()
			.compactMap { eventGroup -> EventGroupParcel? in

				guard let slashedJSONData = eventGroup.jsonData,
					  let removedSlashesJSONString = String(data: slashedJSONData, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/"),
					  let fixedJSONData = removedSlashesJSONString.data(using: .utf8),
					  let providerIdentifier = eventGroup.providerIdentifier,
					  let type = eventGroup.type,
					  eventGroup.isDraft == false
				else { return nil }

				return EventGroupParcel(
					expiryDate: eventGroup.expiryDate,
					jsonData: fixedJSONData,
					providerIdentifier: providerIdentifier,
					type: type
				)
			}
		return eventGroupParcels
	}
	
	private func presentError(_ error: Error) {
		
		logError("exportEventGroups error: \(error)")
		let errorCode: ErrorCode
		switch error {
			case DataMigrationError.compressionError:
				errorCode = ErrorCode(flow: .migration, step: .export, clientCode: .compressionError)
			default:
				errorCode = ErrorCode(flow: .migration, step: .export, clientCode: .other)
		}
		delegate?.presentError(errorCode)
	}
	
	@objc func alterImage() {
		
//		logDebug("Alter Image, current: \(currentPage), total: \(imageList.count)")
		
		guard imageList.isNotEmpty else { return }
		
		image.value = imageList[currentPage]
		currentPage = currentPage == imageList.count - 1 ? 0 : currentPage + 1
	}
	
	func startTimer() {
		
		animationTimer = Timer.scheduledTimer(
			withTimeInterval: 1 / frequency,
			repeats: true,
			block: { [weak self] _ in
			self?.alterImage()
		})
		animationTimer?.fire()
	}
	
	func stopTimer() {
		
		animationTimer?.invalidate()
		animationTimer = nil
	}
	
	func done() {
		
		stopTimer()
		delegate?.userCompletedMigrationToOtherDevice()
	}
}
