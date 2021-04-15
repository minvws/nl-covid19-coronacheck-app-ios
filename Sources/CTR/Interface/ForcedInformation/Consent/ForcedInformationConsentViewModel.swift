/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class ForcedInformationConsentViewModel {

	// MARK: - Bindable variables

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The highlights of the scene
	@Bindable private(set) var highlights: String

	/// The content of the scene
	@Bindable private(set) var content: String

	/// The title of the primary action
	@Bindable private(set) var primaryActionTitle: String

	/// The title of the secondary action
	@Bindable private(set) var secondaryActionTitle: String?

	/// The title of the eror
	@Bindable private(set) var errorTitle: String = .newTermsErrorTitle

	/// The message of the eror
	@Bindable private(set) var errorMessage: String = .newTermsErrorMessage

	/// Show the error dialog?
	@Bindable private(set) var showErrorDialog: Bool = false

	/// Use the secondary button?
	@Bindable private(set) var useSecondaryButton: Bool = false

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

		if consent.consentMandatory {
			primaryActionTitle = .newTermsAgree
			secondaryActionTitle = .newTermsDisagree
			useSecondaryButton = true
		} else {
			primaryActionTitle = .next
			secondaryActionTitle = nil
			useSecondaryButton = false
		}
	}

	// MARK: - Actions

	/// The user tapped the primary button
	func primaryButtonTapped() {
		
		// Notifify coordinator delegate
		if consent.consentMandatory {
			coordinator?.didFinishConsent(ForcedInformationResult.consentAgreed)
		} else {
			coordinator?.didFinishConsent(ForcedInformationResult.consentViewed)
		}
	}

	/// The user tapped the secondary button
	func secondaryButtonTapped() {

		// Show Error
		errorTitle = .newTermsErrorTitle
		errorMessage = .newTermsErrorMessage
		showErrorDialog = true
	}
}
