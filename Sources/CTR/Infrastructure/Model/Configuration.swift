/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation

public final class Configuration {
	
	public enum Release: String {
		case production
		case acceptance = "acc"
		case development = "dev"
	}
	
	public func getRelease() -> Release {

		guard let networkConfigurationValue = Bundle.main.infoDictionary?["NETWORK_CONFIGURATION"] as? String else { return .development }
		guard let release = Release(rawValue: networkConfigurationValue.lowercased()) else { return .development }
		return release
	}
}
