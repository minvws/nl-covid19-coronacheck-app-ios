/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

struct PaperProofStartItem {

	let title: String
	let message: String
	let icon: UIImage?
}

final class PaperProofStartViewModel: Logging {
	
	@Bindable private (set) var title: String = L.holderPaperproofStartTitle()
	@Bindable private (set) var message: String = L.holderPaperproofStartMessage()
	@Bindable private (set) var items: [PaperProofStartItem]
	@Bindable private (set) var selfPrintedButtonTitle = L.holderPaperproofStartSelfprinted()
	@Bindable private (set) var nextButtonTitle = L.generalNext()
	
	private weak var coordinator: PaperProofCoordinatorDelegate?
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: PaperProofCoordinatorDelegate) {
		
		self.coordinator = coordinator
		self.items = [
			PaperProofStartItem(
				title: L.holderPaperproofStartProviderTitle(),
				message: L.holderPaperproofStartProviderMessage(),
				icon: I.healthProvider()
			),
			PaperProofStartItem(
				title: L.holderPaperproofStartMailTitle(),
				message: L.holderPaperproofStartMailMessage(),
				icon: I.mail()
			)
		]
	}
	
	/// The user tapped the primary button
	func userTappedNextButton() {
		
		coordinator?.userWishesToEnterToken()
	}

	func userTappedSelfPrintedButton() {

		coordinator?.userWishesMoreInformationOnSelfPrintedProof()
	}
}
