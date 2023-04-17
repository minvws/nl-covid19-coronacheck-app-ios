/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

class WebViewModel {
	
	var title: Observable<String?>
	var url: Observable<URL>
	private var decider: AllowedDomain
	
	init(url: URL, title: String?, domainDecider: AllowedDomain) {
		
		self.title = Observable(value: title)
		self.url = Observable(value: url)
		self.decider = domainDecider
	}
	
	func isDomainAllowed(_ url: URL) -> Bool {
		return decider.isDomainAllowed(url)
	}
	
	func handleUnallowedDomain(_ url: URL) {
		return decider.handleUnallowedDomain(url)
	}
}
