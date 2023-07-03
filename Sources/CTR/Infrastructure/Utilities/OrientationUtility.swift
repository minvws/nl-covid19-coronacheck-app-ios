/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

// See https://stackoverflow.com/a/41811798/443270
struct OrientationUtility {

	static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

		(UIApplication.shared.delegate as? AppDelegate)?.orientationLock = orientation
	}
	
	static func unlockOrientation() {
		(UIApplication.shared.delegate as? AppDelegate)?.orientationLock = .all
	}

	/// Lock the orientation and rotate
	/// - Parameters:
	///   - orientation: the orientation mask to lock to
	///   - rotateOrientation: the orientation to rotate to
	static func lockOrientation(
		_ orientation: UIInterfaceOrientationMask,
		andRotateTo rotateOrientation: UIInterfaceOrientation) {

		self.lockOrientation(orientation)

		UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
		UINavigationController.attemptRotationToDeviceOrientation()
	}
}
