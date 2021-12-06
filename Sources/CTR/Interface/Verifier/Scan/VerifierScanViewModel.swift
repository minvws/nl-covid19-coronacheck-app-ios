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

	weak var scanLogManager: ScanLogManaging? = Services.scanLogManager

	/// Coordination Delegate
	weak var theCoordinator: (VerifierCoordinatorDelegate & Dismissable & OpenUrlProtocol)?

	var userSettings: UserSettingsProtocol

	// MARK: - Bindable properties

	/// The title of the scene
	@Bindable private(set) var title: String

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
		coordinator: (VerifierCoordinatorDelegate & Dismissable & OpenUrlProtocol),
		userSettings: UserSettingsProtocol
	) {

		self.theCoordinator = coordinator
		self.userSettings = userSettings

		self.title = L.verifierScanTitle()
		self.moreInformationButtonText = L.verifierScanButtonMoreInformation()
		self.torchLabels = [L.verifierScanTorchEnable(), L.verifierScanTorchDisable()]

		super.init(coordinator: coordinator)
	}

	/// Parse the scanned QR-code
	/// - Parameter code: the scanned code
	func parseQRMessage(_ message: String) {

		let currentRiskLevel = userSettings.scanRiskLevelValue
		scanLogManager?.addScanEntry(riskLevel: currentRiskLevel, date: Date())

		if let verificationResult = cryptoManager?.verifyQRMessage(message) {
			switch Int64(verificationResult.status) {
				case MobilecoreVERIFICATION_FAILED_IS_NL_DCC:

					displayAlert(title: L.verifierResultAlertDccTitle(),
								 message: L.verifierResultAlertDccMessage())

				case MobilecoreVERIFICATION_FAILED_UNRECOGNIZED_PREFIX:

					displayAlert(title: L.verifierResultAlertUnknownTitle(),
								 message: L.verifierResultAlertUnknownMessage())
					
				case MobilecoreVERIFICATION_SUCCESS where verificationResult.details != nil:

					guard let details = verificationResult.details else {
						fallthrough
					}
					theCoordinator?.navigateToCheckIdentity(details)

				default:
					
					theCoordinator?.navigateToDeniedAccess()
					
			}
		}
	}

	private func displayAlert(title: String, message: String) {

		alert = AlertContent(
			title: title,
			subTitle: message,
			okAction: { [weak self] _ in
				self?.shouldResumeScanning = true
			},
			okTitle: L.generalOk()
		)
	}

	func dismiss() {

		theCoordinator?.navigateToVerifierWelcome()
	}

	func didTapMoreInformationButton() {

		theCoordinator?.navigateToScanInstruction()
	}
}
