/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenScanViewModel: ScanPermissionViewModel {

	/// Coordination Delegate
	weak var theCoordinator: (HolderCoordinatorDelegate & OpenUrlProtocol)?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The message of the scene
	@Bindable private(set) var message: String

	/// The error title of the scene
	@Bindable private(set) var errorTitle: String

	/// The error message of the scene
	@Bindable private(set) var errorMessage: String

	/// Show the error?
	@Bindable private(set) var showError: Bool

	/// The accessibility labels for the torch
	@Bindable private(set) var torchLabels: [String]

	/// Start scanning
	@Bindable private(set) var startScanning: Bool = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol)) {

		self.theCoordinator = coordinator
		self.title = .holderTokenScanTitle
		self.message = .holderTokenScanMessage
		self.torchLabels = [.holderTokenScanTorchEnable, .holderTokenScanTorchDisable]
		self.errorTitle = .holderTokenScanErrorTitle
		self.errorMessage = .holderTokenScanErrorMessage
		self.showError = false
		super.init(coordinator: coordinator)
	}

	/// Parse the scanned QR-code
	/// - Parameter code: the scanned code
	func parseCode(_ code: String) {

		do {
			let object = try JSONDecoder().decode(RequestToken.self, from: Data(code.utf8))
			self.logDebug("Response Object: \(object)")
			theCoordinator?.userDidScanRequestToken(requestToken: object)
		} catch {
			self.logError("Token Scan Error: \(error)")
			self.showError = true
			self.startScanning = true
		}
	}
}
