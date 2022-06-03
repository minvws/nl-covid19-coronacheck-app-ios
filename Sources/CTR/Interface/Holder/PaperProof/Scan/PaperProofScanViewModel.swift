/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PaperProofScanViewModel: ScanPermissionViewModel {
	
	/// The crypto manager
	weak var cryptoManager: CryptoManaging? = Current.cryptoManager

	/// Coordination Delegate
	weak var theCoordinator: (PaperProofCoordinatorDelegate & OpenUrlProtocol & Dismissable)?
	
	var paperProofIdentifier: PaperProofIdentifierProtocol

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The message of the scene
	@Bindable private(set) var message: String

	/// The accessibility labels for the torch
	@Bindable private(set) var torchLabels: [String]

	@Bindable private(set) var shouldResumeScanning: Bool?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	init(
		coordinator: (PaperProofCoordinatorDelegate & OpenUrlProtocol & Dismissable),
		scanner: PaperProofIdentifierProtocol = PaperProofIdentifier()
	) {
		
		self.theCoordinator = coordinator
		self.paperProofIdentifier = scanner
		
		self.title = L.holder_scanner_title()
		self.message = L.holder_scanner_message()
		self.torchLabels = [L.holderTokenscanTorchEnable(), L.holderTokenscanTorchDisable()]
		
		super.init(coordinator: coordinator)
	}

	/// Parse the scanned QR-code
	/// - Parameter code: the scanned code
	func parseQRMessage(_ message: String) {
		
		switch paperProofIdentifier.identify(message) {
			case .hasDomesticPrefix:
				displayContent(
					L.holder_scanner_error_title_ctb(),
					body: L.holder_scanner_error_message_ctb()
				)
				
			case let .dutchDCC(dcc: dcc):
				theCoordinator?.userDidScanDCC(dcc)
				theCoordinator?.userWishesToEnterToken()
				
			case let .foreignDCC(dcc: dcc):
				theCoordinator?.userDidScanDCC(dcc)
				if let wrapper = Current.couplingManager.convert(dcc, couplingCode: nil) {
					let remoteEvent = RemoteEvent(wrapper: wrapper, signedResponse: nil)
					theCoordinator?.userWishesToSeeScannedEvent(remoteEvent)
				} else {
					displayConvertError()
				}
				
			case .unknown:
				displayContent(
					L.holder_scanner_error_title_unknown(),
					body: L.holder_scanner_error_message_unknown()
				)
		}
	}
	
	private func displayConvertError() {
		
		let errorCode = ErrorCode(flow: .paperproof, step: .scan, clientCode: .failedToConvertDCCToV3Event)
		Current.logHandler.logError("displayConvertError: \(errorCode)")
		
		theCoordinator?.displayError(
			content: Content(
				title: L.holderErrorstateTitle(),
				body: L.holderErrorstateClientMessage("\(errorCode)"),
				primaryActionTitle: L.general_toMyOverview(),
				primaryAction: {[weak self] in
					self?.theCoordinator?.userWantsToGoBackToDashboard()
				},
				secondaryActionTitle: L.holderErrorstateMalfunctionsTitle(),
				secondaryAction: { [weak self] in
					guard let url = URL(string: L.holderErrorstateMalfunctionsUrl()) else { return }
					self?.theCoordinator?.openUrl(url, inApp: true)
				}
			),
			backAction: { [weak self] in
				self?.theCoordinator?.dismiss()
			}
		)
		
	}
	
	private func displayContent(_ title: String, body: String) {
		
		theCoordinator?.displayError(
			content: Content(
				title: title,
				body: body,
				primaryActionTitle: L.holder_scanner_error_action(),
				primaryAction: {[weak self] in
					self?.theCoordinator?.dismiss()
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			),
			backAction: { [weak self] in
				self?.theCoordinator?.dismiss()
			}
		)
	}
}
