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

typealias ScanInstructions = (title: String, text: String, image: UIImage?, imageDescription: String?)

class ScanInstructionsViewModel: Logging {

	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol)?
	
	// MARK: - Bindable properties
	
	/// The title of the scene
	@Bindable private(set) var title: String
	
	/// The content of the scene
    @Bindable private(set) var content: [ScanInstructions]
    
	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - coordinator: the verifier coordinator delegate
	init(coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol)) {
		
		self.coordinator = coordinator
		self.title = .verifierScanInstructionsTitle
		self.content = [
			(
				title: .verifierScanInstructionsDistanceTitle,
				text: .verifierScanInstructionsDistanceText,
				image: nil,
                imageDescription: nil
			), (
				title: .verifierScanInstructionsScanTitle,
				text: .verifierScanInstructionsScanText,
				image: nil,
                imageDescription: nil
			), (
				title: .verifierScanInstructionsAccessTitle,
				text: .verifierScanInstructionsAccessText,
				image: .greenScreen,
                imageDescription: .verifierScanInstructionsAccessImage
			), (
				title: .verifierScanInstructionsDeniedTitle,
				text: .verifierScanInstructionsDeniedText,
				image: .redScreen,
                imageDescription: .verifierScanInstructionsDeniedImage
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
