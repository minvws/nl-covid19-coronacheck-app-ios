/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseProofTypeViewModel {

	// MARK: - Bindable Strings

	@Bindable private(set) var title: String = L.holderChooseqrcodetypeTitle()
	@Bindable private(set) var message: String = L.holderChooseqrcodetypeMessage()
	@Bindable private(set) var buttonModels: [ChooseProofTypeViewController.ButtonModel] = []

	// MARK: - Private State:
	private weak var coordinator: HolderCoordinatorDelegate?

	// MARK: - Initializer

	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator

		buttonModels = [
			ChooseProofTypeViewController.ButtonModel(
				title: L.holderChooseqrcodetypeOptionVaccineTitle(),
				subtitle: L.holderChooseqrcodetypeOptionVaccineSubtitle()) { [weak self] in

				self?.coordinator?.userWishesToCreateAVaccinationQR()
			},
			ChooseProofTypeViewController.ButtonModel(
				title: L.holderChooseqrcodetypeOptionRecoveryTitle(),
				subtitle: L.holderChooseqrcodetypeOptionRecoverySubtitle()) { [weak self] in

				self?.coordinator?.userWishesToCreateARecoveryQR()
			},
			ChooseProofTypeViewController.ButtonModel(
				title: L.holderChooseqrcodetypeOptionNegativetestTitle(),
				subtitle: L.holderChooseqrcodetypeOptionNegativetestSubtitle()) { [weak self] in

				self?.coordinator?.userWishesToChooseTestLocation()
			}
		]
	}
}
