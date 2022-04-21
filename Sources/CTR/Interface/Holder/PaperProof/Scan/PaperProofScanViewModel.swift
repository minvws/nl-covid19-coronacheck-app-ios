/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PaperProofScanViewModel: ScanPermissionViewModel {
	
	/// The crypto manager
	weak var cryptoManager: CryptoManaging? = Current.cryptoManager

	/// Coordination Delegate
	weak var theCoordinator: (PaperProofCoordinatorDelegate & OpenUrlProtocol)?
	
	var dccScanner: DCCScannerProtocol

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The message of the scene
	@Bindable private(set) var message: String

	/// The accessibility labels for the torch
	@Bindable private(set) var torchLabels: [String]
	
	@Bindable private(set) var alert: AlertContent?

	@Bindable private(set) var shouldResumeScanning: Bool?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	init(
		coordinator: (PaperProofCoordinatorDelegate & OpenUrlProtocol),
		scanner: DCCScannerProtocol = DCCScanner()
	) {
		
		self.theCoordinator = coordinator
		self.dccScanner = scanner
		
		self.title = L.holder_scanner_title()
		self.message = L.holder_scanner_message()
		self.torchLabels = [L.holderTokenscanTorchEnable(), L.holderTokenscanTorchDisable()]
		
		super.init(coordinator: coordinator)
	}

	/// Parse the scanned QR-code
	/// - Parameter code: the scanned code
	func parseQRMessage(_ message: String) {
		
		switch dccScanner.scan(message) {
			case .ctb:
				break
			case let .domesticDCC(dcc: dcc):
				theCoordinator?.userDidScanDCC(dcc)
				theCoordinator?.userWishesToEnterToken()
			case let .foreignDCC(dcc: dcc):
				theCoordinator?.userDidScanDCC(dcc)
				// Go to list Event
			
			if let wrapper = Current.couplingManager.convert(dcc, couplingCode: "ROLUS") {
				let remoteEvent = RemoteEvent(wrapper: wrapper, signedResponse: nil)
				theCoordinator?.userWishesToSeeScannedEvent(remoteEvent)
			} else {
				let errorCode = ErrorCode(flow: .hkvi, step: .coupling, clientCode: .failedToConvertDCCToV3Event)
//				displayErrorCode(subTitle: L.holderErrorstateClientMessage("\(errorCode)"))
				logInfo("Error: \(errorCode)")
			}
			
			case .other:
				break
		}
		
//		if message.lowercased().hasPrefix("nl") {
//
//			logWarning("Invalid: Domestic QR-code")
//			displayAlert(title: L.holderScannerAlertDccTitle(), message: L.holderScannerAlertDccMessage())
//
//		} else if cryptoManager?.readEuCredentials(Data(message.utf8)) != nil {
//
//			theCoordinator?.userDidScanDCC(message)
//			theCoordinator?.userWishesToEnterToken()
//
//		} else {
//
//			logWarning("Invalid: Unknown QR-code")
//			displayAlert(title: L.holderScannerAlertUnknownTitle(), message: L.holderScannerAlertUnknownMessage())
//		}
	}

	private func displayAlert(title: String, message: String) {

		alert = AlertContent(
			title: title,
			subTitle: message,
			cancelAction: nil,
			cancelTitle: nil,
			okAction: { [weak self] _ in
				self?.shouldResumeScanning = true
			},
			okTitle: L.generalOk()
		)
	}
}
