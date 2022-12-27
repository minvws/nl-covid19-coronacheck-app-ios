/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The Application flavor, used to determine if we are the CoronaCheck or the CoronaCheck Scanner app.
public enum AppFlavor: String {
	
	/// We are the CoronaCheck app (holder of the QRs)
	case holder
	
	/// We are the CoronaCheck Scanner app (verifing the QRs)
	case verifier
	
	/// The flavor of the app, defaults to holder
	public static var flavor: AppFlavor {
		
		if let value = Bundle.main.infoDictionary?["APP_FLAVOR"] as? String,
		   let fls = AppFlavor(rawValue: value ) {
			return fls
		}
		return .holder
	}
}
