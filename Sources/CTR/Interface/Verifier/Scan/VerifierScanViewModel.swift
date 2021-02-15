/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class VerifierScanViewModel: Logging {

	/// The logging category
	var loggingCategory: String = "VerifierScanViewModel"

	/// The crypto manager
	weak var cryptoManager: CryptoManaging?

	/// Coordination Delegate
	weak var coordinator: VerifierCoordinatorDelegate?

	// MARK: - Bindable properties

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The message of the scene
	@Bindable private(set) var message: String

	/// The accessibility message for the torch
	@Bindable private(set) var torchAccessibility: String

	/// Start scanning
	@Bindable private(set) var startScanning: Bool = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	init(
		coordinator: VerifierCoordinatorDelegate,
		cryptoManager: CryptoManaging) {

		self.coordinator = coordinator
		self.cryptoManager = cryptoManager

		self.title = .verifierScanTitle
		self.message = .verifierScanMessage
		self.torchAccessibility = .verifierScanTorchAccessibility
	}

	/// Parse the scanned QR-code
	/// - Parameter code: the scanned code
	func parseQRMessage(_ message: String) {

		if let attributes = cryptoManager?.verifyQRMessage(message) {
			coordinator?.navigateToScanResult(attributes)
		} else {
			startScanning = true
		}
	}
}
