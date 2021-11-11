/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class PaperProofStartScanningViewModel: Logging {
	
	@Bindable private(set) var title: String = L.holderPaperproofStartscanningTitle()
	@Bindable private(set) var message: String = L.holderPaperproofStartscanningMessage()
	@Bindable private(set) var nextButtonTitle = L.holderPaperproofStartscanningAction()
	@Bindable private(set) var internationalTitle = L.holderPaperproofStartscanningInternational()
	@Bindable private(set) var internationalQROnly = I.internationalQROnly()

	private weak var coordinator: PaperProofCoordinatorDelegate?
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: PaperProofCoordinatorDelegate) {
		
		self.coordinator = coordinator
	}
	
	func userTappedNextButton() {
		
		coordinator?.userWishesToScanCertificate()
	}

	func userTappedInternationalButton() {

		coordinator?.userWishesMoreInformationOnInternationalQROnly()
	}
}
