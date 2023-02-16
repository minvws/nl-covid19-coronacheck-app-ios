/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public protocol AppInstalledSinceManaging: AnyObject {

	var firstUseDate: Date? { get }
	
	func update(serverHeaderDate: String, ageHeader: String?)

	func update(dateProvider: DocumentsDirectoryCreationDateProtocol)

	func wipePersistedData()
}

public final class AppInstalledSinceManager: AppInstalledSinceManaging {
	
	private var appInstalledDate: Date? {
		get { secureUserSettings.appInstalledDate }
		set { secureUserSettings.appInstalledDate = newValue }
	}
	
	public var firstUseDate: Date? {
		return appInstalledDate
	}
	
	private let secureUserSettings: SecureUserSettingsProtocol
	
	// MARK: - Init

	public required init(secureUserSettings: SecureUserSettingsProtocol) {
		self.secureUserSettings = secureUserSettings
	}
 
	/// Update using the Server Response Header string
	/// e.g. "Sat, 07 Aug 2021 12:12:57 GMT"
	public func update(serverHeaderDate: String, ageHeader: String?) {

		// it can only be set once
		guard appInstalledDate == nil else { return }

		guard var serverDate = DateFormatter.Header.serverDate.date(from: serverHeaderDate) else { return }

		if let ageHeader {
			
			// CDN has a stale Date, but adds an Age field in seconds.
			let age = TimeInterval(ageHeader) ?? 0
			serverDate = serverDate.addingTimeInterval(age)
		}
		appInstalledDate = serverDate
	}

	public func update(dateProvider: DocumentsDirectoryCreationDateProtocol) {

		// it can only be set once
		guard appInstalledDate == nil else { return }

		if let date = dateProvider.getDocumentsDirectoryCreationDate() {
			appInstalledDate = date
		}
	}

	public func wipePersistedData() {
		appInstalledDate = nil
	}
}

public protocol DocumentsDirectoryCreationDateProtocol {

	func getDocumentsDirectoryCreationDate() -> Date?
}

extension FileManager: DocumentsDirectoryCreationDateProtocol {

	public func getDocumentsDirectoryCreationDate() -> Date? {
		guard let documentsURL = urls(for: .documentDirectory, in: .userDomainMask).last,
			  let attributes = try? attributesOfItem(atPath: documentsURL.path)
		else { return nil }
		return attributes[.creationDate] as? Date
	}
}
