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
	weak var theCoordinator: (PaperProofCoordinatorDelegate & OpenUrlProtocol & Dismissable)?
	
	var paperProofIdentifier: PaperProofIdentifierProtocol

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
		coordinator: (PaperProofCoordinatorDelegate & OpenUrlProtocol & Dismissable),
		scanner: PaperProofIdentifierProtocol = PaperProofIdentifier()
	) {
		
		self.theCoordinator = coordinator
		self.paperProofIdentifier = scanner
		
		self.title = L.holder_scanner_title()
		self.message = L.holder_scanner_message()
		self.torchLabels = [L.holderTokenscanTorchEnable(), L.holderTokenscanTorchDisable()]
		
		super.init(coordinator: coordinator)
		
//				DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//					self.parseQRMessage("HC1:NCFOXN%TSMAHN-HOWO8P6GXQ-5LC+A9EH6/NAD6ZLPLX8PQV2GK/+6N+O/:85IBMF6.UCOMIN6R%E5BD72K8+GOTJP/*PD87U15/CSREQ+GOI.PKSOAZQTXO*BPQK4QKRN95404.W7UX4IV4L*KDYPWGOH992EOXCR/24PTMQKRNPPL95OD6%28*U3C8CO8CG8C3AD:XIBEIVG395EV3EVCK09D5WCFVA+QO5VA81K0ECM8CXVDC8C90JK.A+ C/8DXEDKG0CGJ5AL5:4A93OHB+9G6X6Q3QR$P*NIV1JH7U7VAWBJ5VALZID0B9BIQMIFXK7BIWOJYHS-8BZIJ ZJ83B79U%S2IFT1R2:ZJY1B062.H36F33N2X63BSCJWTB.SYBJF0JEYI1DLZZL162ABCSQU6DQD%9AOLA2BP$Q.46P:8T6U IMU/PKEB-QQ.XM3DVJ 2Q7S++BG+KO9PO$FJ6D56LW4P1BNE*8JTBP%2R1G:WAB/VE0T%*DHB0NID*CF")
//				}
	}

	/// Parse the scanned QR-code
	/// - Parameter code: the scanned code
	func parseQRMessage(_ message: String) {
		
		switch paperProofIdentifier.identify(message) {
			case .ctb:
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
		logError("errorCode")
		
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
