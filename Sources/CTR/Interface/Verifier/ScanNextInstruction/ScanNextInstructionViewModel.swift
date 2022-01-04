/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

enum ScanNext {
	case test
	case vaccinationOrRecovery
}

final class ScanNextInstructionViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: VerifierCoordinatorDelegate?
	
	@Bindable private(set) var subtitle = L.verifier_scannextinstruction_subtitle()
	@Bindable private(set) var title: String
	@Bindable private(set) var header: String
	@Bindable private(set) var primaryTitle: String
	@Bindable private(set) var secondaryTitle: String
	
	init(
		coordinator: VerifierCoordinatorDelegate,
		scanNext: ScanNext
	) {
		
		self.coordinator = coordinator
		
		switch scanNext {
			case .test:
				title = L.verifier_scannextinstruction_title_test()
				header = L.verifier_scannextinstruction_header_test()
				primaryTitle = L.verifier_scannextinstruction_button_scan_next_test()
				secondaryTitle = L.verifier_scannextinstruction_button_deny_access_test()
			case .vaccinationOrRecovery:
				title = L.verifier_scannextinstruction_title_supplemental()
				header = L.verifier_scannextinstruction_header_supplemental()
				primaryTitle = L.verifier_scannextinstruction_button_scan_next_supplemental()
				secondaryTitle = L.verifier_scannextinstruction_button_deny_access_supplemental()
		}
	}
	
	func scanNextQR() {
		
		coordinator?.navigateToScan()
	}
	
	func denyAccess() {
		
		coordinator?.navigateToDeniedAccess()
	}
}
