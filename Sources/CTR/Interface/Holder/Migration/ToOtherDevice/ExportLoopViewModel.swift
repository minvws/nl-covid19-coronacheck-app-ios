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
import Managers

class ExportLoopViewModel {
	
	weak var delegate: MigrationCoordinatorDelegate?

	internal var imageList: [UIImage]
	
	private var currentPage: Int

	private var animationTimer: Timeable?

	private let frequency: Double = 3.0
	
	private let screenBrightnessManager: ScreenBrightnessProtocol
	
	private let dataExporter: DataExporterProtocol
	
	// MARK: - Observable

	let title = Observable<String>(value: L.holder_startMigration_onboarding_toolbar())
	let step = Observable<String>(value: L.holder_startMigration_onboarding_step("3"))
	var header = Observable<String>(value: L.holder_startMigration_toOtherDevice_onboarding_step3_title())
	var message = Observable<String>(value: L.holder_startMigration_toOtherDevice_onboarding_step3_message())
	let actionTitle = Observable<String>(value: L.holder_startMigration_onboarding_doneButton())
	let qrAccessibilityTitle = Observable<String>(value: L.holder_startMigration_toOtherDevice_accessiblityQR())
	var image = Observable<UIImage?>(value: nil)
	var pageControlCount = Observable<Int>(value: 0)

	/// Initializer
	/// - Parameters:
	///   - delegate: the Data Migration Coordinator Delegate
	///   - dataExporter:  the data exporter class
	///   - screenBrightness: the screen brightness manager
	init(
		delegate: MigrationCoordinatorDelegate?,
		dataExporter: DataExporterProtocol,
		screenBrightness: ScreenBrightnessProtocol
	) {
		
		self.delegate = delegate
		self.dataExporter = dataExporter
		self.screenBrightnessManager = screenBrightness
		pageControlCount.value = MigrationOnboardingFactory().getExportInstructions().count + 1
		currentPage = 0
		imageList = []
		exportEventGroups()
	}
	
	func viewWillAppear() {
		
		screenBrightnessManager.animateToFullBrightness()
	}
	
	func viewWillDisappear() {
		
		screenBrightnessManager.animateToInitialBrightness()
	}
	
	deinit {
		stopTimer()
	}
	
	func exportEventGroups() {
		
		let eventGroupParcels = listEventGroupParcels()
		let encoder = JSONEncoder()
		logDebug("We got \(eventGroupParcels.count) event group parcels")
		
		if let encoded = try? encoder.encode(eventGroupParcels) {
			do {
				let items = try dataExporter.export(encoded)
				appendItemsToImageList(items)
			} catch let error {
				presentError(error)
			}
		}
	}
	
	private func appendItemsToImageList(_ items: [String]) {
		
		items.forEach { item in
			DispatchQueue.global(qos: .userInitiated).async {
				if let image = item.generateQRCode(correctionLevel: QRGenerator.CorrectionLevel.medium) {
					self.imageList.append(image)
				}
				if self.imageList.count == items.count {
					logDebug("All \(items.count) converted to QR, start animation")
					DispatchQueue.main.async {
						self.startTimer()
					}
				}
			}
		}
	}
	
	private func listEventGroupParcels() -> [EventGroupParcel] {
		
		let eventGroupParcels: [EventGroupParcel] = Current.walletManager.listEventGroups()
			.compactMap { eventGroup -> EventGroupParcel? in

				guard let slashedJSONData = eventGroup.jsonData,
					  let removedSlashesJSONString = String(data: slashedJSONData, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/"),
					  let fixedJSONData = removedSlashesJSONString.data(using: .utf8),
					  eventGroup.isDraft == false
				else { return nil }

				return EventGroupParcel( jsonData: fixedJSONData)
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
	
	@objc func showQR() {
		
		guard imageList.isNotEmpty else { return }
		
		image.value = imageList[currentPage]
		currentPage = currentPage == imageList.count - 1 ? 0 : currentPage + 1
	}
	
	func startTimer() {
		
		animationTimer = Timer.scheduledTimer(
			withTimeInterval: 1 / frequency,
			repeats: true,
			block: { [weak self] _ in
			self?.showQR()
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
	
	func backToPreviousScreen() {
		
		stopTimer()
		delegate?.userWishesToGoBackToPreviousScreen(animated: false)
	}
}
