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

	/// Do we need updating? True if we do
	var needsUpdating: Bool { get }

	/// Get the consent
	/// - Returns: optional consent
	func getConsent() -> ForcedInformationConsent?

	/// Give consent
	func consentGiven()

	/// Reset the manager
	func reset()
}

class ForcedInformationManager: ForcedInformationManaging {

	// Initialize
	required init() {
		// Required by protocol
	}

	/// The onboarding data to persist
	private struct ForcedInformationData: Codable {

		/// The last seen version
		var lastSeenVersion: Int

		/// Empty crypto data
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

	/// Do we need updating? True if we do
	var needsUpdating: Bool {
		return data.lastSeenVersion < information.version
	}

	/// the forced information
	var information: ForcedInformation = ForcedInformation(
		pages: [],
		consent: ForcedInformationConsent(
			title: .newTermsTitle,
			highlight: .newTermsHighlights,
			content: .newTermsDescription,
			consentMandatory: false
		),
		version: 1
	)

	/// Get the consent
	/// - Returns: optional consent
	func getConsent() -> ForcedInformationConsent? {

		return information.consent
	}

	/// Give consent
	func consentGiven() {

		data.lastSeenVersion = information.version
	}

	/// Reset the manager
	func reset() {

		$data.clearData()
	}
}
