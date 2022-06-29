/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseProofTypeViewModel: ListOptionsProtocol {
	
	var title: Observable<String?> = Observable(value: L.holderChooseqrcodetypeTitle())
	
	var message: Observable<String?> = Observable(value: L.holderChooseqrcodetypeMessage())
	
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
					title: L.holderChooseqrcodetypeOptionVaccineTitle(),
					subTitle: L.holderChooseqrcodetypeOptionVaccineSubtitle()) { [weak self] in
						
						self?.coordinator?.userWishesToCreateAVaccinationQR()
					},
				ListOptionsViewController.OptionModel(
					title: L.holderChooseqrcodetypeOptionRecoveryTitle(),
					subTitle: L.holderChooseqrcodetypeOptionRecoverySubtitle()) { [weak self] in
						
						self?.coordinator?.userWishesToCreateARecoveryQR()
					},
				ListOptionsViewController.OptionModel(
					title: L.holderChooseqrcodetypeOptionNegativetestTitle(),
					subTitle: L.holderChooseqrcodetypeOptionNegativetestSubtitle()) { [weak self] in
						
						self?.coordinator?.userWishesToChooseTestLocation()
					}
			]
		)
	}
}
