/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class PaperProofStartScanningViewModel {
	
	@Bindable private(set) var title: String = L.holder_paperproof_startscanning_title()
	@Bindable private(set) var message: String = L.holder_paperproof_startscanning_body()
	@Bindable private(set) var nextButtonTitle = L.holder_paperproof_startscanning_button_startScanning()
	@Bindable private(set) var secondaryButtonTitle = L.holder_paperproof_startscanning_button_whichProofs()
	@Bindable private(set) var internationalQROnly = I.scannableQRs()

	private weak var coordinator: PaperProofCoordinatorDelegate?
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: PaperProofCoordinatorDelegate) {
		
		self.coordinator = coordinator
	}
	
	func backButtonTapped() {
		
		coordinator?.userWishesToCancelPaperProofFlow()
	}
	
	func backSwipe() {
		
		coordinator?.userWishesToCancelPaperProofFlow()
	}
	
	func userTappedNextButton() {
		
		coordinator?.userWishesToScanCertificate()
	}

	func userTappedSecondaryButton() {

		coordinator?.userWishesMoreInformationOnWhichProofsCanBeUsed()
	}
}
