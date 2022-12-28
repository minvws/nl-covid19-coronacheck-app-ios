/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

class HelpdeskViewModel {
	
	@Bindable private(set) var appVersion: String
	@Bindable private(set) var configVersion: String?
	
	private let urlHandler: (URL) -> Void
	
	init(flavor: AppFlavor, versionSupplier: AppVersionSupplierProtocol, urlHandler: @escaping (URL) -> Void) {
	
		appVersion = flavor == .holder
			? L.holderLaunchVersion(versionSupplier.getCurrentVersion(), versionSupplier.getCurrentBuild())
			: L.verifierLaunchVersion(versionSupplier.getCurrentVersion(), versionSupplier.getCurrentBuild())

		configVersion = {
			guard let timestamp = Current.userSettings.configFetchedTimestamp,
				  let hash = Current.userSettings.configFetchedHash
			else { return nil }

			let dateString = DateFormatter.Format.numericDateWithTime.string(from: Date(timeIntervalSince1970: timestamp))

			return L.generalMenuConfigVersion(String(hash.prefix(7)), dateString)
		}()
		
		self.urlHandler = urlHandler
	}
	
	func userDidTapURL(url: URL) {
		urlHandler(url)
	}
}
