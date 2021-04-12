/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class ForcedInformationViewModel {

	// MARK: - Content variables

	/// The title of the scene
	private(set) var title: String

	/// The highlights of the scene
	private(set) var highlights: String

	/// The content of the scene
	private(set) var content: String

	/// The title of the primary action
	private(set) var primaryActionTitle: String

	/// The title of the secondary action
	private(set) var secondaryActionTitle: String?

	/// The title of the eror
	private(set) var errortitle: String = .newTermsErrorTitle

	/// The message of the eror
	private(set) var errorMessage: String = .newTermsErrorMessage

	// MARK: - Bindable variables

	/// Show the error dialog?
	@Bindable private(set) var showErrorDialog: Bool = false

	/// Enable the secondary button?
	@Bindable private(set) var enableSecondaryButton: Bool = false

	// MARK: - Private variables

	/// The forced information consent
	private var consent: ForcedInformationConsent

	/// Coordination Delegate
	weak private var coordinator: ForcedInformationCoordinatorDelegate?

	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - consent: the consent
	init(_ coordinator: ForcedInformationCoordinatorDelegate, forcedInformationConsent: ForcedInformationConsent) {

		self.coordinator = coordinator
		self.consent = forcedInformationConsent

		// Content
		self.title = consent.title
		self.highlights = consent.highlight
		self.content = consent.content

		if consent.mustGiveConsent {
			primaryActionTitle = .newTermsAgree
			secondaryActionTitle = .newTermsDisagree
			enableSecondaryButton = true
		} else {
			primaryActionTitle = .next
			secondaryActionTitle = nil
			enableSecondaryButton = false
		}
	}

	/// The user tapped the primary button
	func primaryButtonTapped() {

		if consent.mustGiveConsent {
			coordinator?.didFinishConsent(ForcedInformationResult.consentAgreed)
		} else {
			coordinator?.didFinishConsent(ForcedInformationResult.consentViewed)
		}
	}

	/// The user tapped the secondary button
	func secondaryButtonTapped() {

		coordinator?.didFinishConsent(ForcedInformationResult.consentNotAgreed)
		showErrorDialog = true
	}
}
