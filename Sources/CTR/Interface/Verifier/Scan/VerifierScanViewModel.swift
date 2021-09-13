/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import AVFoundation
import Clcore

class VerifierScanViewModel: ScanPermissionViewModel {

	/// The crypto manager
	weak var cryptoManager: CryptoManaging? = Services.cryptoManager

	/// Coordination Delegate
	weak var theCoordinator: (VerifierCoordinatorDelegate & Dismissable & OpenUrlProtocol)?

	// MARK: - Bindable properties

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The message of the scene
	@Bindable private(set) var message: String?

	/// "Waar moet ik op letten?"
	@Bindable private(set) var moreInformationButtonText: String?

	/// The accessibility labels for the torch
	@Bindable private(set) var torchLabels: [String]
	
	@Bindable private(set) var alert: AlertContent?

	@Bindable private(set) var shouldResumeScanning: Bool?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(
		coordinator: (VerifierCoordinatorDelegate & Dismissable & OpenUrlProtocol)) {

		self.theCoordinator = coordinator

		self.title = L.verifierScanTitle()
		self.message = nil
		self.moreInformationButtonText = L.verifierScanButtonMoreInformation()
		self.torchLabels = [L.verifierScanTorchEnable(), L.verifierScanTorchDisable()]

		super.init(coordinator: coordinator)
	}

	/// Parse the scanned QR-code
	/// - Parameter code: the scanned code
	func parseQRMessage(_ message: String) {

		if let verificationResult = cryptoManager?.verifyQRMessage(message) {
			switch Int64(verificationResult.status) {
				case MobilecoreVERIFICATION_FAILED_IS_NL_DCC:

					alert = AlertContent(
						title: L.verifierResultAlertDccTitle(),
						subTitle: L.verifierResultAlertDccMessage(),
						cancelAction: nil,
						cancelTitle: nil,
						okAction: { [weak self] _ in
							self?.shouldResumeScanning = true
						},
						okTitle: L.generalOk()
					)
				case MobilecoreVERIFICATION_FAILED_UNRECOGNIZED_PREFIX:

					alert = AlertContent(
						title: L.verifierResultAlertUnknownTitle(),
						subTitle: L.verifierResultAlertUnknownMessage(),
						cancelAction: nil,
						cancelTitle: nil,
						okAction: { [weak self] _ in
							self?.shouldResumeScanning = true
						},
						okTitle: L.generalOk())
				default:
					
					theCoordinator?.navigateToScanResult(verificationResult)
			}
		}
	}

	func dismiss() {

		theCoordinator?.navigateToVerifierWelcome()
	}

	func didTapMoreInformationButton() {

		theCoordinator?.navigateToScanInstruction()
	}
}
