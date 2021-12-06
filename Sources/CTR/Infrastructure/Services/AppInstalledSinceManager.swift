/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol AppInstalledSinceManaging {

	var usable: Date { get }

	init(documentDirectoryCreationDate: Date?)

	func update(serverHeaderDate: String, ageHeader: String?)

}

final class AppInstalledSinceManager: AppInstalledSinceManaging {
	
	private struct Constants {
		static let keychainService: String = {
			guard !ProcessInfo.processInfo.isTesting else { return UUID().uuidString }
			return "AppInstalledSinceManager\(Configuration().getEnvironment())"
		}()
	}
	
	@Keychain(name: "appInstalledDateFromServer", service: Constants.keychainService, clearOnReinstall: true)
	private var appInstalledDateFromServer: Date? = nil // swiftlint:disable:this let_var_whitespace redundant_optional_initialization
	
	private lazy var serverHeaderDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_GB") // because the server date contains day name
		dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
		return dateFormatter
	}()
	
	var usable: Date {
		// TODO: allow Date()?
		return appInstalledDateFromServer ?? documentsDirectoryCreationDate ?? Date()
	}
	
	// MARK: - Init
	
	let documentsDirectoryCreationDate: Date?
	
	init(documentDirectoryCreationDate: Date? = AppInstalledSinceManager.documentsDirectoryCreationDate()) {
		self.documentsDirectoryCreationDate = documentDirectoryCreationDate
	}
	
	/// Update using the Server Response Header string
	/// e.g. "Sat, 07 Aug 2021 12:12:57 GMT"
	func update(serverHeaderDate: String, ageHeader: String?) {
		guard var serverDate = serverHeaderDateFormatter.date(from: serverHeaderDate)
		else { return }

		appInstalledDateFromServer = serverDate
		if let ageHeader = ageHeader {
			
			// CDN has a stale Date, but adds an Age field in seconds.
			let age = TimeInterval(ageHeader) ?? 0
			serverDate = serverDate.addingTimeInterval(age)
		}
	}
	
	// MARK: - Static functions
	
	private static func documentsDirectoryCreationDate() -> Date? {
		guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last,
			  let attributes = try? FileManager.default.attributesOfItem(atPath: documentsURL.path)
		else { return nil }
		return attributes[.creationDate] as? Date
	}
}
