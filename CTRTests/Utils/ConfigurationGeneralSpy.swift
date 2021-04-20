/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ConfigurationGeneralSpy: ConfigurationGeneralProtocol {

	func getAutoCloseTime() -> TimeInterval {
		return 10
	}

	func getTestResultWarningTTL() -> Int {
		return 10
	}

	func getQRGracePeriod() -> TimeInterval {
		return 10
	}

	func getQRRefreshPeriod() -> TimeInterval {
		return 10
	}

	func getPrivacyPolicyURL() -> URL {
		return URL(string: "https:coronacheck.nl")!
	}

	func getHolderFAQURL() -> URL {
		return URL(string: "https:coronacheck.nl")!
	}

	func getVerifierFAQURL() -> URL {
		return URL(string: "https:coronacheck.nl")!
	}
}
