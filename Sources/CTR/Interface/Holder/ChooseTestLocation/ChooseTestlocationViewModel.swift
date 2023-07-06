/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI

class ChooseTestLocationViewModel: ListOptionsProtocol {
	
	let title = Observable(value: L.holderLocationTitle())
	
	let message = Observable<String?>(value: L.holderLocationMessage())
	
	let optionModels: Observable<[ListOptionsViewController.OptionModel]> = Observable(value: [])
	
	let bottomButton: Observable<ListOptionsViewController.OptionModel?> = Observable(value: nil)
	
	weak var coordinator: HolderCoordinatorDelegate?
	
	// MARK: - Initializer
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {
		
		self.coordinator = coordinator
		
		optionModels.value = [
			ListOptionsViewController.OptionModel(
				title: L.holderLocationGgdTitle(),
				type: .singleLine) { [weak self] in
					self?.coordinator?.userWishesToCreateANegativeTestQRFromGGD()
				},
			ListOptionsViewController.OptionModel(
				title: L.holderLocationOtherTitle(),
				type: .singleLine) { [weak self] in
					self?.coordinator?.userWishesToCreateANegativeTestQR()
				}
		]
		
		bottomButton.value = ListOptionsViewController.OptionModel(
			title: L.holderLocationNotest(),
			type: .singleLine) { [weak self] in
				self?.coordinator?.userWishesMoreInfoAboutGettingTested()
			}
	}
}
