/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PaperCertificateScanViewModel: ScanPermissionViewModel {
	
	/// The crypto manager
	weak var cryptoManager: CryptoManaging?

	/// Coordination Delegate
	weak var theCoordinator: (HolderCoordinatorDelegate & OpenUrlProtocol)?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The message of the scene
	@Bindable private(set) var message: String

	/// The accessibility labels for the torch
	@Bindable private(set) var torchLabels: [String]
	
	@Bindable private(set) var alert: PaperCertificateScanViewController.AlertContent?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	init(
		coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol),
		cryptoManager: CryptoManaging) {
		
		self.theCoordinator = coordinator
		self.cryptoManager = cryptoManager
		
		self.title = L.holderScannerTitle()
		self.message = L.holderScannerMessage()
		self.torchLabels = [L.holderTokenscanTorchEnable(), L.holderTokenscanTorchDisable()]
		
		super.init(coordinator: coordinator)
	}

	/// Parse the scanned QR-code
	/// - Parameter code: the scanned code
	func parseQRMessage(_ message: String) {
		
		if message.hasPrefix("NL") {
			// Invalid: Domestic QR-code
			alert = .init(title: L.holderScannerAlertDccTitle(),
						  subTitle: L.holderScannerAlertDccMessage(),
						  okTitle: L.generalOk())
		} else if let euCredentialAttributes = cryptoManager?.readEuCredentials(Data(message.utf8)) {
			// Valid
			logDebug("\(euCredentialAttributes)")
		} else {
			// Invalid: Unknown QR-codeScanner
			alert = .init(title: L.holderScannerAlertUnknownTitle(),
						  subTitle: L.holderScannerAlertUnknownMessage(),
						  okTitle: L.generalOk())
		}
	}
}
