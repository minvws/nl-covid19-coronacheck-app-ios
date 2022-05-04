/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol AppInstalledSinceManaging: AnyObject {

	var firstUseDate: Date? { get }
	
	func update(serverHeaderDate: String, ageHeader: String?)

	func update(dateProvider: DocumentsDirectoryCreationDateProtocol)

	func wipePersistedData()
}

final class AppInstalledSinceManager: AppInstalledSinceManaging {
	
	private var appInstalledDate: Date? {
		get { secureUserSettings.appInstalledDate }
		set { secureUserSettings.appInstalledDate = newValue }
	}
	
	var firstUseDate: Date? {
		return appInstalledDate
	}
	
	private let secureUserSettings: SecureUserSettingsProtocol
	
	// MARK: - Init

	required init(secureUserSettings: SecureUserSettingsProtocol) {
		self.secureUserSettings = secureUserSettings
	}
 
	/// Update using the Server Response Header string
	/// e.g. "Sat, 07 Aug 2021 12:12:57 GMT"
	func update(serverHeaderDate: String, ageHeader: String?) {

		// it can only be set once
		guard appInstalledDate == nil else { return }

		guard var serverDate = DateFormatter.Header.dateFormatter.date(from: serverHeaderDate) else { return }

		if let ageHeader = ageHeader {
			
			// CDN has a stale Date, but adds an Age field in seconds.
			let age = TimeInterval(ageHeader) ?? 0
			serverDate = serverDate.addingTimeInterval(age)
		}
		appInstalledDate = serverDate
	}

	func update(dateProvider: DocumentsDirectoryCreationDateProtocol) {

		// it can only be set once
		guard appInstalledDate == nil else { return }

		if let date = dateProvider.getDocumentsDirectoryCreationDate() {
			appInstalledDate = date
		}
	}

	func wipePersistedData() {
		appInstalledDate = nil
	}
}

protocol DocumentsDirectoryCreationDateProtocol {

	func getDocumentsDirectoryCreationDate() -> Date?
}

extension FileManager: DocumentsDirectoryCreationDateProtocol {

	func getDocumentsDirectoryCreationDate() -> Date? {
		guard let documentsURL = urls(for: .documentDirectory, in: .userDomainMask).last,
			  let attributes = try? attributesOfItem(atPath: documentsURL.path)
		else { return nil }
		return attributes[.creationDate] as? Date
	}
}
