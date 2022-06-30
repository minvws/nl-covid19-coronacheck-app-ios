/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class CheckForDigidViewModel: ListOptionsProtocol {
	
	let title = Observable(value: L.holder_noDigiD_title())
	
	let message = Observable(value: L.holder_noDigiD_message())
	
	let optionModels: Observable<[ListOptionsViewController.OptionModel]> = Observable(value: [])
	
	let bottomButton: Observable<ListOptionsViewController.OptionModel?> = Observable(value: nil)
	
	weak var coordinator: AlternativeRouteCoordinatorDelegate?
	
	// MARK: - Initializer
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: AlternativeRouteCoordinatorDelegate) {
		
		self.coordinator = coordinator
		
		optionModels.value = [
			ListOptionsViewController.OptionModel(
				title: L.holder_noDigiD_buttonTitle_requestDigiD(),
				image: I.digid(),
				action: { [weak self] in self?.coordinator?.userWishesToRequestADigiD() }
			),
			ListOptionsViewController.OptionModel(
				title: L.holder_noDigiD_buttonTitle_continueWithoutDigiD(),
				subTitle: L.holder_noDigiD_buttonSubTitle_continueWithoutDigiD(),
				action: { [weak self] in self?.coordinator?.userWishesToCheckForBSN() }
			)
		]
	}
	
	func goBack() {
		coordinator?.userWishesToEndAlternativeRoute()
	}
}
