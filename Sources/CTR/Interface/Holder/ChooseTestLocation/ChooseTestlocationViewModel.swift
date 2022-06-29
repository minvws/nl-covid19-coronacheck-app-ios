/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseTestLocationViewModel: ListOptionsProtocol {
	
	var title: Observable<String?> = Observable(value: L.holderLocationTitle())
	
	var message: Observable<String?> = Observable(value: L.holderLocationMessage())
	
	var optionModels: Observable<[ListOptionsViewController.OptionModel]> = Observable(value: [] )
	
	var bottomButton: Observable<ListOptionsViewController.OptionModel?> = Observable(value: nil)
	
	weak var coordinator: HolderCoordinatorDelegate?
	
	// MARK: - Initializer
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {
		
		self.coordinator = coordinator
		
		optionModels = Observable(
			value: [
				ListOptionsViewController.OptionModel(
					title: L.holderLocationGgdTitle()) { [weak self] in
						self?.coordinator?.userWishesToCreateANegativeTestQRFromGGD()
					},
				ListOptionsViewController.OptionModel(
					title: L.holderLocationOtherTitle()) { [weak self] in
						self?.coordinator?.userWishesToCreateANegativeTestQR()
					}
			]
		)
		
		bottomButton = Observable(
			value: ListOptionsViewController.OptionModel(
				title: L.holderLocationNotest()) { [weak self] in
					self?.coordinator?.userWishesMoreInfoAboutGettingTested()
				}
		)
	}
}
