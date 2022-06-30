/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class CheckForDigidViewModel: ListOptionsProtocol {
	
	let title = Observable(value: "Ik heb geen digid")
	
	let message = Observable(value: "todo")
	
	let optionModels: Observable<[ListOptionsViewController.OptionModel]> = Observable(value: [])
	
	let bottomButton: Observable<ListOptionsViewController.OptionModel?> = Observable(value: nil)
	
	weak var coordinator: NoDigiDCoordinatorDelegate?
	
	// MARK: - Initializer
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: NoDigiDCoordinatorDelegate) {
		
		self.coordinator = coordinator
		
		optionModels.value = [
			ListOptionsViewController.OptionModel(
				title: L.holderChooseqrcodetypeOptionVaccineTitle(),
				subTitle: L.holderChooseqrcodetypeOptionVaccineSubtitle()) { [weak self] in
					
//					self?.coordinator?.userWishesToCreateAVaccinationQR()
				},
			ListOptionsViewController.OptionModel(
				title: L.holderChooseqrcodetypeOptionRecoveryTitle(),
				subTitle: L.holderChooseqrcodetypeOptionRecoverySubtitle()) { [weak self] in
					
//					self?.coordinator?.userWishesToCreateARecoveryQR()
				}
		]
	}
}
