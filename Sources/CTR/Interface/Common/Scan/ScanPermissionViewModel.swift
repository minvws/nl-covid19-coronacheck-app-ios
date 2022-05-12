/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import AVFoundation

class ScanPermissionViewModel: Logging {

	/// The logging category
	var loggingCategory: String = "ScanPermissionViewModel"

	/// Coordination Delegate
	weak var coordinator: OpenUrlProtocol?

	// MARK: - Bindable properties

	/// show a permission warning
	@Bindable private(set) var showPermissionWarning: Bool = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: OpenUrlProtocol) {

		self.coordinator = coordinator
		checkAuthorization()
	}

	/// Check the camera permissions
	func checkAuthorization() {

		let avStatus = AVCaptureDevice.authorizationStatus(for: .video)
		if avStatus == .denied {
			logWarning("Camera permission denied.")
			showPermissionWarning = true
		}
	}

	/// Navigate to settings
	func gotoSettings() {

		if let url = URL(string: UIApplication.openSettingsURLString) {
			coordinator?.openUrl(url, inApp: false)
		}
	}
}
