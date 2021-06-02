/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseQRCodeTypeViewModel: Logging {

	// MARK: - Bindable Strings

	@Bindable private(set) var title: String = .holderChooseQRCodeTypeTitle
	@Bindable private(set) var message: String
	@Bindable private(set) var buttonModels: [ChooseQRCodeTypeViewController.ButtonModel] = []

	// MARK: - Private State:
	private weak var coordinator: HolderCoordinatorDelegate?

	// MARK: - Initializer

	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator

		message = .holderChooseQRCodeTypeMessage(testHoursValidity: 40, vaccineDaysValidity: 365)
		
		buttonModels = [
			.init(
				title: .holderChooseQRCodeTypeOptionNegativeTestTitle,
				subtitle: .holderChooseQRCodeTypeOptionNegativeTestSubtitle) { [weak self] in

				self?.coordinator?.userWishesToChooseLocation()
			},
			.init(
				title: .holderChooseQRCodeTypeOptionVaccineTitle,
				subtitle: .holderChooseQRCodeTypeOptionVaccineSubtitle) { [weak self] in

				self?.coordinator?.userWishesToCreateAVaccinationQR()
			}
		]
	}
}
