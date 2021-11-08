/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class PaperProofStartScanningViewModel: Logging {
	
	@Bindable private(set) var title: String = L.holderPapercertificateAboutscanTitle()
	@Bindable private(set) var message: String = L.holderPapercertificateAboutscanMessage()
	@Bindable private(set) var primaryButtonTitle = L.holderScannerTitle()
	
	private weak var coordinator: PaperCertificateCoordinatorDelegate?
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: PaperCertificateCoordinatorDelegate) {
		
		self.coordinator = coordinator
	}
	
	/// The user tapped the primary button
	func primaryButtonTapped() {
		
		coordinator?.userWishesToScanCertificate()
	}
}
