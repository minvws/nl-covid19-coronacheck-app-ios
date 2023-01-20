/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

protocol ContactInformationProviderProtocol {
	
	var phoneNumberLink: String { get }
}

struct ContactInformationProvider: ContactInformationProviderProtocol {
	
	var phoneNumberLink: String
	
	init() {
		phoneNumberLink = "<a href=\"tel: 0800-1421\">0800-1421</a>"
	}
}
