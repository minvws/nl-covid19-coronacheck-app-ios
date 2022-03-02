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
	weak var cryptoManager: CryptoManaging? = Current.cryptoManager

	weak var scanLogManager: ScanLogManaging? = Current.scanLogManager
	
	weak var riskLevelManager: RiskLevelManaging? = Current.riskLevelManager

	/// Coordination Delegate
	weak var theCoordinator: (VerifierCoordinatorDelegate & Dismissable & OpenUrlProtocol)?

	// MARK: - Bindable properties

	/// The title of the scene
	@Bindable private(set) var title: String

	/// "Waar moet ik op letten?"
	@Bindable private(set) var moreInformationButtonText: String?

	/// The accessibility labels for the torch
	@Bindable private(set) var torchLabels: [String]
	
	@Bindable private(set) var alert: AlertContent?

	@Bindable private(set) var shouldResumeScanning: Bool?
	
	@Bindable private(set) var verificationPolicy: VerificationPolicy?
	
	private var riskLevelObserverToken: RiskLevelManager.ObserverToken?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(
		coordinator: (VerifierCoordinatorDelegate & Dismissable & OpenUrlProtocol)
	) {

		self.theCoordinator = coordinator

		self.title = L.verifierScanTitle()
		self.moreInformationButtonText = L.verifierScanButtonMoreInformation()
		self.torchLabels = [L.verifierScanTorchEnable(), L.verifierScanTorchDisable()]
		self.verificationPolicy = riskLevelManager?.state

		super.init(coordinator: coordinator)
		
		riskLevelObserverToken = Current.riskLevelManager.appendObserver { [weak self] updatedPolicy in
			
			guard self?.verificationPolicy != updatedPolicy else { return }
			self?.dismiss()
		}
	}

	/// Parse the scanned QR-code
	/// - Parameter code: the scanned code
	func parseQRMessage(_ message: String) {

		if Current.featureFlagManager.areMultipleVerificationPoliciesEnabled() {

			guard let currentVerificationPolicy = riskLevelManager?.state else {
				assertionFailure("Risk level should be set")
				handleScanError(.noRiskSetting)
				return
			}
			scanLogManager?.addScanEntry(verificationPolicy: currentVerificationPolicy, date: Date())
		}

		guard let cryptoManager = cryptoManager else {
			handleScanError(.unknown)
			return
		}

		let result = cryptoManager.verifyQRMessage(message)
		switch result {
			case let .success(verificationResult):
				handleMobilecoreVerificationResult(verificationResult)
			case let .failure(error):
				handleScanError(error)
		}
	}
	
	private func handleMobilecoreVerificationResult(_ verificationResult: MobilecoreVerificationResult) {
		
		switch Int64(verificationResult.status) {
			case MobilecoreVERIFICATION_FAILED_IS_NL_DCC:
				displayAlert(
					title: L.verifierResultAlertDccTitle(),
					message: L.verifierResultAlertDccMessage()
				)
				
			case MobilecoreVERIFICATION_FAILED_UNRECOGNIZED_PREFIX:
				displayAlert(
					title: L.verifierResultAlertUnknownTitle(),
					message: L.verifierResultAlertUnknownMessage()
				)
				
			case MobilecoreVERIFICATION_SUCCESS where verificationResult.details != nil:
				
				guard let details = verificationResult.details else {
					fallthrough
				}
				theCoordinator?.navigateToCheckIdentity(details)
				
			default:
				
				theCoordinator?.navigateToDeniedAccess()
		}
	}
	
	private func handleScanError(_ error: CryptoError) {
		
		let clientCode: ErrorCode.ClientCode
		switch error {
			case .keyMissing:
				clientCode = .noPublicKeys
			case .noRiskSetting:
				clientCode = .noRiskSetting
			case .noDefaultVerificationPolicy:
				clientCode = .noDefaultVerificationPolicy
			case .couldNotVerify:
				clientCode = .couldNotVerify
			default:
				clientCode = .unhandled
		}
		let errorCode = ErrorCode(flow: .scanFlow, step: .parsingQR, clientCode: clientCode)
		
		displayAlert(title: L.generalErrorTitle(), message: L.generalErrorCryptolibMessage("\(errorCode)"))
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

		theCoordinator?.navigateToScanInstruction(allowSkipInstruction: false)
	}
}

// MARK: ErrorCode.Step

extension ErrorCode.Step {
	
	static let parsingQR = ErrorCode.Step(value: "40")
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {
	
	static let noPublicKeys = ErrorCode.ClientCode(value: "090")
	static let noRiskSetting = ErrorCode.ClientCode(value: "091")
	static let noDefaultVerificationPolicy = ErrorCode.ClientCode(value: "092")
	static let couldNotVerify = ErrorCode.ClientCode(value: "093")
}
