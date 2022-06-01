/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import LocalAuthentication

protocol DeviceAuthenticationProtocol: AnyObject {

	/// Does this device have an authentication policy set? (biometrics, touch, passcode)
	/// - Returns: True if it does
	func hasAuthenticationPolicy() -> Bool
}

class DeviceAuthenticationDetector: DeviceAuthenticationProtocol {

	let context: LAContext!
	private let logHandler: Logging?

	required init(logHandler: Logging? = nil) {

		context = LAContext()
		self.logHandler = logHandler
	}

	/// Does this device have an authentication policy set? (biometrics, touch, passcode)
	/// - Returns: True if it does
	func hasAuthenticationPolicy() -> Bool {

		var error: NSError?
		let deviceOwnerAuthentication = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
		if let error = error {
			logHandler?.logError("Error checking LocalAuthentication status: \(error)")
		}
		logHandler?.logVerbose("LocalAuthentication status: \(deviceOwnerAuthentication)")
		return deviceOwnerAuthentication
	}
}
