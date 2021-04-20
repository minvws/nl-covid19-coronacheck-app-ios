/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum ScanInstructionsResult {

	// The user has read the scan instructions and pressed next
	case scanInstructionsCompleted
}

class ScanInstructionsViewModel: Logging {

	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol)?
	
	// MARK: - Bindable properties
	
	/// The title of the scene
	@Bindable private(set) var title: String
	
	/// The content of the scene
	@Bindable private(set) var content: [(title: String, text: String, image: UIImage?)]

	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - coordinator: the verifier coordinator delegate
	///   - maxValidity: The max time in hours that a test result / test proof is valid
	init(
		coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol),
		maxValidity: String) {
		
		self.coordinator = coordinator
		self.title = .verifierScanInstructionsTitle
		self.content = [
			(
				title: .verifierScanInstructionsDistanceTitle,
				text: .verifierScanInstructionsDistanceText,
				image: nil
			), (
				title: .verifierScanInstructionsScanTitle,
				text: .verifierScanInstructionsScanText,
				image: nil
			), (
				title: .verifierScanInstructionsAccessTitle,
				text: .verifierScanInstructionsAccessText,
				image: .greenScreen
			), (
				title: .verifierScanInstructionsDeniedTitle,
				text: String(format: .verifierScanInstructionsDeniedText, maxValidity),
				image: .redScreen
			)
		]
	}

	// MARK: - User Interaction

	func primaryButtonTapped() {

		coordinator?.didFinish(.scanInstructionsCompleted)
	}

	func linkTapped(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}
}
