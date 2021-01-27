/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// Protocol for app version information
protocol AppVersionInformation {

	/// The minimum required version
	var minimumVersion: String { get }

	/// The message for the minium required version
	var minimumVersionMessage: String? { get }

	/// The url to the appStore
	var appStoreURL: URL? { get }
}

struct RemoteConfiguration: AppVersionInformation, Codable {

	/// The minimum required version
	var minimumVersion: String

	/// The message for the minium required version
	var minimumVersionMessage: String?

	/// The url to the appStore
	var appStoreURL: URL?

	/// Key mapping
	enum CodingKeys: String, CodingKey {
		case minimumVersion = "iosMinimumVersion"
		case minimumVersionMessage = "iosMinimumVersionMessage"
		case appStoreURL = "iosAppStoreURL"
	}

	/// Initializer
	/// - Parameter decoder: the decoder
	/// - Throws: decoder error
	init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)

		minimumVersion = try container.decode(String.self, forKey: .minimumVersion)
		minimumVersionMessage = try? container.decode(String?.self, forKey: .minimumVersionMessage)

		if let appStoreURLString = try? container.decode(String?.self, forKey: .appStoreURL) {
			appStoreURL = URL(string: appStoreURLString)
		} else {
			appStoreURL = nil
		}
	}
}

/// Should the app be updated?
enum UpdateState {

	/// The app should be updated
	case updateRequired(AppVersionInformation)

	/// The app is fine.
	case noActionNeeded
}
