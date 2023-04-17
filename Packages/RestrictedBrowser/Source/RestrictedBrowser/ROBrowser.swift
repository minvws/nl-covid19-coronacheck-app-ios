/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared

public protocol AllowedDomain {
	func isDomainAllowed(_ url: URL) -> Bool
	func handleUnallowedDomain(_ url: URL)
}

public class ROBrowser: AllowedDomain {
	
	private let navigationController: UINavigationController
	private let allowedDomains: [String]
	private let title: String?
	
	public init(navigationController: UINavigationController, title: String?, allowedDomains: [String]) {
		self.navigationController = navigationController
		self.title = title
		self.allowedDomains = allowedDomains
	}
	
	public func openUrl(_ url: URL) {
		
		if isDomainAllowed(url) {
			logDebug("Domain \(url.absoluteString) is allowed")
			let viewController = WebViewController(viewModel: WebViewModel(url: url, title: title, domainDecider: self))
			navigationController.pushViewController(viewController, animated: true)
		} else {
			logDebug("Domain \(url.absoluteString) is NOT allowed")
			handleUnallowedDomain(url)
		}
	}
	
	public func isDomainAllowed(_ url: URL) -> Bool {
		
		guard let host = url.host, allowedDomains.isNotEmpty else {
			return false
		}
		return allowedDomains.contains(host)
	}
	
	public func handleUnallowedDomain(_ url: URL) {
		// Open unallowed domains in the default browser
		UIApplication.shared.open(url)
	}
}
