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
		coordinator: (PaperProofCoordinatorDelegate & OpenUrlProtocol)) {
		
		self.theCoordinator = coordinator
		
		self.title = L.holderScannerTitle()
		self.message = L.holderScannerMessage()
		self.torchLabels = [L.holderTokenscanTorchEnable(), L.holderTokenscanTorchDisable()]
		
		super.init(coordinator: coordinator)
	}

	/// Parse the scanned QR-code
	/// - Parameter code: the scanned code
	func parseQRMessage(_ message: String) {
		
		if message.lowercased().hasPrefix("nl") {

			logWarning("Invalid: Domestic QR-code")
			displayAlert(title: L.holderScannerAlertDccTitle(), message: L.holderScannerAlertDccMessage())

		} else if cryptoManager?.readEuCredentials(Data(message.utf8)) != nil {

			theCoordinator?.userWishesToCreateACertificate(message: message)

		} else {

			logWarning("Invalid: Unknown QR-code")
			displayAlert(title: L.holderScannerAlertUnknownTitle(), message: L.holderScannerAlertUnknownMessage())
		}
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
