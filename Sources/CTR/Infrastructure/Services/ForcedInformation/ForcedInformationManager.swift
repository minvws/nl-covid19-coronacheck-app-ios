/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ForcedInformationManaging {

	// Initialize
	init(secureUserSettings: SecureUserSettingsProtocol)
	
	/// The source of all the forced information. This needs to be updated if new consent or pages are required.
	var factory: ForcedInformationFactory? { get set }

	/// Do we need show any updates? True if we do
	var needsUpdating: Bool { get }
	
	/// Get the update page
	/// - Returns: optional page
	func getUpdatePage() -> ForcedInformationPage?

	/// Get the consent
	/// - Returns: optional consent
	func getConsent() -> ForcedInformationConsent?

	/// Give consent
	func consentGiven()
}

class ForcedInformationManager: ForcedInformationManaging {

	/// The forced information data to persist
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
	var factory: ForcedInformationFactory?

	/// Do we need show any updates? True if we do
	var needsUpdating: Bool {
		guard let currentVersion = factory?.information.version else {
			return false
		}
		return forcedInformationData.lastSeenVersion < currentVersion
	}
	
	func getUpdatePage() -> ForcedInformationPage? {

		return factory?.information.pages.first
	}

	/// Is there any consent that needs to be displayed?
	/// - Returns: optional consent
	func getConsent() -> ForcedInformationConsent? {

		return factory?.information.consent
	}

	/// User has given consent, update the version
	func consentGiven() {

		guard let currentVersion = factory?.information.version else { return }
		forcedInformationData.lastSeenVersion = currentVersion
	}
}
