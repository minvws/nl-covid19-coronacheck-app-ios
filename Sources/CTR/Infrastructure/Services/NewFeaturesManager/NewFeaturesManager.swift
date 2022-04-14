/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol NewFeaturesManaging {

	/// The source of all the new feature information. This needs to be updated if new consent or pages are required.
	var factory: NewFeaturesFactory? { get set }

	/// Do we need show any updates? True if we do
	var needsUpdating: Bool { get }
	
	/// Get a new feature item
	/// - Returns: optional item
	func pagedAnnouncementItems() -> [PagedAnnoucementItem]?

	/// User has seen the intro for the new feature, update the version
	func userHasViewedNewFeatureIntro()

	/// Reset the manager
	func wipePersistedData()
}

class NewFeaturesManager: NewFeaturesManaging {

	/// The new feature  information data to persist
	struct ForcedInformationData: Codable {

		/// The last seen / accepted version by the user
		var lastSeenVersion: Int

		/// The default empty data, version equals 0
		static var empty: ForcedInformationData {
			return ForcedInformationData(lastSeenVersion: 0)
		}
	}

	private var forcedInformationData: ForcedInformationData {
		get { secureUserSettings.forcedInformationData }
		set { secureUserSettings.forcedInformationData = newValue }
	}

	// MARK: - Dependencies
	
	private let secureUserSettings: SecureUserSettingsProtocol
	
	// MARK: - ForcedInformationManaging

	required init(secureUserSettings: SecureUserSettingsProtocol) {
		self.secureUserSettings = secureUserSettings
	}
		
	/// The source of all the forced information. This needs to be updated if new consent or pages are required.
	var factory: NewFeaturesFactory?

	/// Do we need show any updates? True if we do
	var needsUpdating: Bool {
		guard let currentVersion = factory?.information.version else {
			return false
		}
		return forcedInformationData.lastSeenVersion < currentVersion
	}
	
	func pagedAnnouncementItems() -> [PagedAnnoucementItem]? {

		return factory?.information.pages
	}

	/// User has seen the intro for the new feature, update the version
	func userHasViewedNewFeatureIntro() {

		guard let currentVersion = factory?.information.version else { return }
		forcedInformationData.lastSeenVersion = currentVersion
	}

	/// Reset the manager, clear all the data
	func wipePersistedData() {

		secureUserSettings.forcedInformationData = SecureUserSettings.Defaults.forcedInformationData
	}
}
