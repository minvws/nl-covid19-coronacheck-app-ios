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

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: VerifierCoordinator) {

		self.coordinator = coordinator

		primaryButtonTitle = .verifierStartButtonTitle
		title = .verifierStartTitle
		header = .verifierStartHeader
		message = .verifierStartMessage
		linkedMessage = .verifierStartLinkedMessage
	}

	func primaryButtonTapped() {

		if scanInstructionShown {
			coordinator?.navigateToScan()
		} else {

			scanInstructionShown = true
			coordinator?.navigateToScanInstruction(present: true)
		}
	}

	func linkTapped(_ viewController: UIViewController) {

		coordinator?.navigateToScanInstruction(present: false)
	}
}
