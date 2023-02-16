/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Models

public protocol NewFeaturesManaging {

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

public class NewFeaturesManager: NewFeaturesManaging {

	/// The new feature  information data to persist
	public struct ForcedInformationData: Codable {

		/// The last seen / accepted version by the user
		public var lastSeenVersion: Int

		/// The default empty data, version equals 0
		public static var empty: ForcedInformationData {
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

	public required init(secureUserSettings: SecureUserSettingsProtocol) {
		self.secureUserSettings = secureUserSettings
	}
		
	/// The source of all the forced information. This needs to be updated if new consent or pages are required.
	public var factory: NewFeaturesFactory?

	/// Do we need show any updates? True if we do
	public var needsUpdating: Bool {
		guard let currentVersion = factory?.information.version else {
			return false
		}
		return forcedInformationData.lastSeenVersion < currentVersion
	}
	
	public func pagedAnnouncementItems() -> [PagedAnnoucementItem]? {

		return factory?.information.pages
	}

	/// User has seen the intro for the new feature, update the version
	public func userHasViewedNewFeatureIntro() {

		guard let currentVersion = factory?.information.version else { return }
		forcedInformationData.lastSeenVersion = currentVersion
	}

	/// Reset the manager, clear all the data
	public func wipePersistedData() {

		secureUserSettings.forcedInformationData = SecureUserSettings.Defaults.forcedInformationData
	}
}
