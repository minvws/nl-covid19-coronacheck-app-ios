/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseQRCodeTypeViewModel: Logging {

	// MARK: - Bindable Strings

	@Bindable private(set) var title: String = L.holderChooseqrcodetypeTitle()
	@Bindable private(set) var message: String = L.holderChooseqrcodetypeMessage()
	@Bindable private(set) var buttonModels: [ChooseQRCodeTypeViewController.ButtonModel] = []

	// MARK: - Private State:
	private weak var coordinator: HolderCoordinatorDelegate?

	// MARK: - Initializer

	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator

		buttonModels = [
			ChooseQRCodeTypeViewController.ButtonModel(
				title: L.holderChooseqrcodetypeOptionVaccineTitle(),
				subtitle: L.holderChooseqrcodetypeOptionVaccineSubtitle()) { [weak self] in

				self?.coordinator?.userWishesToCreateAVaccinationQR()
			},
			ChooseQRCodeTypeViewController.ButtonModel(
				title: L.holderChooseqrcodetypeOptionRecoveryTitle(),
				subtitle: L.holderChooseqrcodetypeOptionRecoverySubtitle()) { [weak self] in

				self?.coordinator?.userWishesToCreateARecoveryQR()
			},
			ChooseQRCodeTypeViewController.ButtonModel(
				title: L.holderChooseqrcodetypeOptionNegativetestTitle(),
				subtitle: L.holderChooseqrcodetypeOptionNegativetestSubtitle()) { [weak self] in

				self?.coordinator?.userWishesToChooseLocation()
			}
		]
	}
}
