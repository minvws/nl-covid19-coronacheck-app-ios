/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum VerifierStartResult {

	case userTappedProceedToScan

	case userTappedProceedToScanInstructions
}

class VerifierStartViewModel: Logging {

	var loggingCategory: String = "VerifierStartViewModel"

	weak private var coordinator: VerifierCoordinatorDelegate?
	weak private var cryptoManager: CryptoManaging? = Services.cryptoManager
	weak private var cryptoLibUtility: CryptoLibUtilityProtocol? = Services.cryptoLibUtility
	private var userSettings: UserSettingsProtocol
	private let clockDeviationManager: ClockDeviationManaging = Services.clockDeviationManager
	private var clockDeviationObserverToken: ClockDeviationManager.ObserverToken?

	// MARK: - Bindable properties

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The title of the scene
	@Bindable private(set) var header: String

	/// The message of the scene
	@Bindable private(set) var message: String

	/// The title of the button
	@Bindable private(set) var primaryButtonTitle: String

	/// The title of the showInstructions button
	@Bindable private(set) var showInstructionsTitle: String

	@Bindable private(set) var showError: Bool = false

	@Bindable private(set) var shouldShowClockDeviationWarning = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - userSettings: the user managed settings
	init(
		coordinator: VerifierCoordinatorDelegate,
		userSettings: UserSettingsProtocol = UserSettings()) {

		self.coordinator = coordinator
		self.userSettings = userSettings

		primaryButtonTitle = L.verifierStartButtonTitle()
		title = L.verifierStartTitle()
		header = L.verifierStartHeader()
		message = L.verifierStartMessage()
		showInstructionsTitle = L.verifierStartButtonShowinstructions()
		shouldShowClockDeviationWarning = clockDeviationManager.hasSignificantDeviation ?? false

		clockDeviationObserverToken = clockDeviationManager.appendDeviationChangeObserver { [weak self] hasClockDeviation in
			self?.shouldShowClockDeviationWarning = hasClockDeviation
		}
	}
	deinit {
		clockDeviationObserverToken.map(clockDeviationManager.removeDeviationChangeObserver)
	}

	func primaryButtonTapped() {

		if userSettings.scanInstructionShown {

			if let crypto = cryptoManager, crypto.hasPublicKeys() {
				coordinator?.didFinish(.userTappedProceedToScan)
			} else {
				updatePublicKeys()
				showError = true
			}
		} else {
			// Show the scan instructions the first time no matter what link was tapped
			coordinator?.didFinish(.userTappedProceedToScanInstructions)
		}
	}

	func showInstructionsButtonTapped() {
		coordinator?.didFinish(.userTappedProceedToScanInstructions)
	}

	func userDidTapClockDeviationWarningReadMore() {
		coordinator?.userWishesMoreInfoAboutClockDeviation()
	}

	/// Update the public keys
	private func updatePublicKeys() {

		// Fetch the public keys from the issuer
		cryptoLibUtility?.update(isAppFirstLaunch: false, immediateCallbackIfWithinTTL: nil, completion: nil)
	}
}
