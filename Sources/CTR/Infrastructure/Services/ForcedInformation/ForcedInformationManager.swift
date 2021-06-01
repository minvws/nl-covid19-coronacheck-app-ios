/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ForcedInformationManaging {

	// Initialize
	init()

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

	/// Reset the manager
	func reset()
}

class ForcedInformationManager: ForcedInformationManaging {

	/// The forced information data to persist
	private struct ForcedInformationData: Codable {

		/// The last seen / accepted version by the user
		var lastSeenVersion: Int

		/// The default empty data, version equals 0
		static var empty: ForcedInformationData {
			return ForcedInformationData(lastSeenVersion: 0)
		}
	}

	private struct Constants {

		/// The key chain service
		static let keychainService = "ForcedInformationManager\(Configuration().getEnvironment())\(ProcessInfo.processInfo.isTesting ? "Test" : "")"
	}

	// keychained stored data
	@Keychain(name: "data", service: Constants.keychainService, clearOnReinstall: true)
	private var data: ForcedInformationData = .empty

	/// The source of all the forced information. This needs to be updated if new consent or pages are required.
	private var information: ForcedInformation = ForcedInformation(
		pages: [ForcedInformationPage(
			image: .onboardingSafely,
			tagline: .holderUpdatePageTagline,
			title: .holderUpdatePageTitle,
			content: .holderUpdatePageContent
		)],
		consent: nil,
		version: 2
	)

	// MARK: - ForcedInformationManaging

	// Initialize
	required init() {
		// Required by protocol
	}

	/// Do we need show any updates? True if we do
	var needsUpdating: Bool {
		return data.lastSeenVersion < information.version
	}
	
	func getUpdatePage() -> ForcedInformationPage? {
		
		return information.pages.first
	}

	/// Is there any consent that needs to be displayed?
	/// - Returns: optional consent
	func getConsent() -> ForcedInformationConsent? {

		return information.consent
	}

	/// User has given consent, update the version
	func consentGiven() {

		data.lastSeenVersion = information.version
	}

	/// Reset the manager, clear all the data
	func reset() {

		$data.clearData()
	}
}
