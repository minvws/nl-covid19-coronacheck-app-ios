/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenScanViewModel: Logging {

	var loggingCategory: String = "TokenScanViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The message of the scene
	@Bindable private(set) var message: String

	/// Start scanning
	@Bindable private(set) var startScanning: Bool = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator
		self.title = .holderTokenScanTitle
		self.message = .holderTokenScanMessage
	}

	func parseCode(_ code: String) {

		do {
			let object = try JSONDecoder().decode(RequestToken.self, from: Data(code.utf8))
			self.logDebug("Response Object: \(object)")
			coordinator?.navigateToTokenEntry(object)
		} catch {
			self.logError("error: \(error)")
			self.startScanning = true
		}
	}
}
