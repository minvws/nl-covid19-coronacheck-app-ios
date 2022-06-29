/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseProofTypeViewModel: ListOptionsViewModel {
	
	// MARK: - Initializer
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	override init(coordinator: HolderCoordinatorDelegate) {
		
		super.init(coordinator: coordinator)
		
		setTitle(L.holderChooseqrcodetypeTitle())
		setMessage(L.holderChooseqrcodetypeMessage())
		
		setOptions([
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
		])
	}
}
