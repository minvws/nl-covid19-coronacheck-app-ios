/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierStartViewModel: Logging {

	/// The logging category
	var loggingCategory: String = "VerifierStartViewModel"

	/// Coordination Delegate
	weak var coordinator: (VerifierCoordinatorDelegate & Dismissable)?

	/// The crypto manager
	weak var cryptoManager: CryptoManaging?

	@UserDefaults(key: "scanInstructionShown", defaultValue: false)
	private var scanInstructionShown: Bool // swiftlint:disable:this let_var_whitespace

	// MARK: - Bindable properties

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The title of the scene
	@Bindable private(set) var header: String

	/// The message of the scene
	@Bindable private(set) var message: String

	/// The linked message of the scene
	@Bindable private(set) var linkedMessage: String

	/// The title of the button
	@Bindable private(set) var primaryButtonTitle: String

	/// The title of the button
	@Bindable private(set) var showError: Bool = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	init(coordinator: VerifierCoordinator, cryptoManager: CryptoManaging) {

		self.coordinator = coordinator
		self.cryptoManager = cryptoManager

		primaryButtonTitle = .verifierStartButtonTitle
		title = .verifierStartTitle
		header = .verifierStartHeader
		message = .verifierStartMessage
		linkedMessage = .verifierStartLinkedMessage
	}

	func primaryButtonTapped() {

		if scanInstructionShown {

			if let crypto = cryptoManager, crypto.hasPublicKeys() {
				coordinator?.navigateToScan()
			} else {
				updatePublicKeys()
				showError = true
			}
		} else {

			scanInstructionShown = true
			coordinator?.navigateToScanInstruction(present: true)
		}
	}

	func linkTapped(_ viewController: UIViewController) {

		coordinator?.navigateToScanInstruction(present: false)
	}

	/// The remote config manager
	var remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager

	/// The proof manager
	var proofManager: ProofManaging = Services.proofManager

	func updatePublicKeys() {

		// Fetch the public keys from the issuer
		let ttl = TimeInterval(remoteConfigManager.getConfiguration().configTTL)
		proofManager.fetchIssuerPublicKeys(ttl: ttl, oncompletion: nil, onError: nil)
	}
}
