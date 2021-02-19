/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanInstructionsViewModel: Logging {
	
	/// The logging category
	var loggingCategory: String = "ScanInstructionsViewModel"
	
	/// Coordination Delegate
	weak var coordinator: VerifierCoordinator?
	
	// MARK: - Bindable properties
	
	/// The title of the scene
	@Bindable private(set) var title: String
	
	/// The message of the scene
	@Bindable private(set) var content: [(title: String, text: String, image: UIImage?)]
	
	/// Initialzier
	/// - Parameters:
	///   - coordinator: the dismissable delegae
	///   - attributes: the decrypted attributes
	init(coordinator: VerifierCoordinator) {
		
		self.coordinator = coordinator
		self.title = .verifierScanInstructionsTitle
		self.content = [
			(
				title: .verifierScanInstructionsDistanceTitle,
				text: .verifierScanInstructionsDistanceText,
				image: nil
			),
			(
				title: .verifierScanInstructionsScanTitle,
				text: .verifierScanInstructionsScanText,
				image: nil
			),
			(
				title: .verifierScanInstructionsAccessTitle,
				text: .verifierScanInstructionsAccessText,
				image: .greenScreen
			),
			(
				title: .verifierScanInstructionsDeniedTitle,
				text: .verifierScanInstructionsDeniedText,
				image: .redScreen
			)
		]
	}
}
