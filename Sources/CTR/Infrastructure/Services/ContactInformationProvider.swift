/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

protocol ContactInformationProtocol {
	
	var phoneNumberLink: String { get }
}

struct ContactInformationProvider: ContactInformationProtocol {
	
	var phoneNumberLink: String
	
	init() {
		phoneNumberLink = "<a href=\"tel: 0800-1421\">0800-1421</a>"
	}
}
