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
	weak var coordinator: VerifierCoordinatorDelegate?

	/// The crypto manager
	weak var cryptoManager: CryptoManaging?

	/// The proof manager
	weak var proofManager: ProofManaging?

	@UserDefaults(key: "scanInstructionShown", defaultValue: false)
	var scanInstructionShown: Bool // swiftlint:disable:this let_var_whitespace

	// MARK: - Bindable properties

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The title of the scene
	@Bindable private(set) var header: String

	/// The message of the scene
	@Bindable private(set) var message: String

	/// The title of the button
	@Bindable private(set) var primaryButtonTitle: String

	/// The title of the button
	@Bindable private(set) var showError: Bool = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	///   - proofManager: the proof manager
	init(
		coordinator: VerifierCoordinatorDelegate,
		cryptoManager: CryptoManaging,
		proofManager: ProofManaging) {

		self.coordinator = coordinator
		self.cryptoManager = cryptoManager
		self.proofManager = proofManager

		primaryButtonTitle = .verifierStartButtonTitle
		title = .verifierStartTitle
		header = .verifierStartHeader
		message = .verifierStartMessage
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

	func linkTapped() {

		coordinator?.navigateToScanInstruction(present: false)
	}

	/// Update the public keys
	private func updatePublicKeys() {

		// Fetch the public keys from the issuer
		proofManager?.fetchIssuerPublicKeys(onCompletion: nil, onError: nil)
	}
}
