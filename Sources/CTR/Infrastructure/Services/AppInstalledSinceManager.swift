/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol AppInstalledSinceManaging: AnyObject {

	var firstUseDate: Date? { get }

	init()

	func update(serverHeaderDate: String, ageHeader: String?)

	func update(documentsDirectoryCreationDate: Date?)

	func getDocumentsDirectoryCreationDate() -> Date?

	func reset()
}

final class AppInstalledSinceManager: AppInstalledSinceManaging {
	
	private struct Constants {
		static let keychainService: String = {
			guard !ProcessInfo.processInfo.isTesting else { return UUID().uuidString }
			return "AppInstalledSinceManager\(Configuration().getEnvironment())"
		}()
	}
	
	@Keychain(name: "appInstalledDate", service: Constants.keychainService, clearOnReinstall: true)
	private var appInstalledDate: Date? = nil // swiftlint:disable:this let_var_whitespace redundant_optional_initialization
	
	private lazy var serverHeaderDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_GB") // because the server date contains day name
		dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
		return dateFormatter
	}()
	
	var firstUseDate: Date? {
		return appInstalledDate
	}
	
	// MARK: - Init

	required init() {
		// Required by Protocol
	}
	
	/// Update using the Server Response Header string
	/// e.g. "Sat, 07 Aug 2021 12:12:57 GMT"
	func update(serverHeaderDate: String, ageHeader: String?) {

		guard var serverDate = serverHeaderDateFormatter.date(from: serverHeaderDate) else { return }

		if let ageHeader = ageHeader {
			
			// CDN has a stale Date, but adds an Age field in seconds.
			let age = TimeInterval(ageHeader) ?? 0
			serverDate = serverDate.addingTimeInterval(age)
		}
		appInstalledDate = serverDate
	}

	func update(documentsDirectoryCreationDate: Date?) {

		if let date = documentsDirectoryCreationDate {
			appInstalledDate = date
		}
	}

	func getDocumentsDirectoryCreationDate() -> Date? {
		guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last,
			  let attributes = try? FileManager.default.attributesOfItem(atPath: documentsURL.path)
		else { return nil }
		return attributes[.creationDate] as? Date
	}

	func reset() {
		appInstalledDate = nil
	}
}
