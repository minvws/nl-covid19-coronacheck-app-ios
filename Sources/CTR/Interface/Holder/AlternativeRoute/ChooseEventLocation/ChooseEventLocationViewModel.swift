/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseEventLocationViewModel: ListOptionsProtocol {
	
	let title = Observable<String>(value: "")
	
	let message = Observable<String?>(value: nil)
	
	let optionModels: Observable<[ListOptionsViewController.OptionModel]> = Observable(value: [])
	
	let bottomButton: Observable<ListOptionsViewController.OptionModel?> = Observable(value: nil)
	
	weak var coordinator: AlternativeRouteCoordinatorDelegate?
	
	// MARK: - Initializer
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: AlternativeRouteCoordinatorDelegate, eventMode: EventMode) {
		
		self.coordinator = coordinator
		
		title.value = L.holder_chooseEventLocation_title(eventMode == .vaccination ? L.holder_contactProviderHelpdesk_vaccinated() : L.holder_contactProviderHelpdesk_tested())
		
		optionModels.value = [
			ListOptionsViewController.OptionModel(
				title: L.holder_chooseEventLocation_buttonTitle_GGD(),
				subTitle: L.holder_chooseEventLocation_buttonSubTitle_GGD(),
				action: { [weak self] in self?.coordinator?.userWishedToGoToGGDPortal() }
			),
			ListOptionsViewController.OptionModel(
				title: L.holder_chooseEventLocation_buttonTitle_other(),
				subTitle: L.holder_chooseEventLocation_buttonSubTitle_other(),
				action: { [weak self] in self?.coordinator?.userWishesToContactHelpDeksWithoutBSN() }
			)
		]
	}
}
