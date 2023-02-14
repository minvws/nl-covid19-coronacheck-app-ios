/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Managers
import Managers

class HelpdeskViewModel {
	
	@Bindable private(set) var appVersion: String
	@Bindable private(set) var configVersion: String?
	@Bindable private(set) var messageLine1: String
	@Bindable private(set) var messageLine2: String
	@Bindable private(set) var messageLine3: String
	
	private let urlHandler: (URL) -> Void
	
	init(flavor: AppFlavor, versionSupplier: AppVersionSupplierProtocol, urlHandler: @escaping (URL) -> Void) {
	
		appVersion = L.holder_helpdesk_appVersion_value(versionSupplier.getCurrentVersion(), versionSupplier.getCurrentBuild())
		
		configVersion = {
			guard let timestamp = Current.userSettings.configFetchedTimestamp,
				  let hash = Current.userSettings.configFetchedHash
			else { return nil }

			let dateString = DateFormatter.Format.numericDateWithTime.string(from: Date(timeIntervalSince1970: timestamp))

			return L.holder_helpdesk_configuration_value(String(hash.prefix(7)), dateString)
		}()
		
		self.urlHandler = urlHandler
		
		// Dynamic Contact Information
		messageLine1 = L.holder_helpdesk_contact_message_line1(Current.contactInformationProvider.phoneNumberLink)
		messageLine2 = L.holder_helpdesk_contact_message_line2(Current.contactInformationProvider.phoneNumberAbroadLink)
		messageLine3 = L.holder_helpdesk_contact_message_line3(
			Current.contactInformationProvider.openingDays,
			Current.contactInformationProvider.startHour,
			Current.contactInformationProvider.endHour
		)
	}
	
	func userDidTapURL(url: URL) {
		urlHandler(url)
	}
}
