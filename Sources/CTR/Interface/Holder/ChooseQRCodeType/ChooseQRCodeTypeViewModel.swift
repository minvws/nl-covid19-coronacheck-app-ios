//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseQRCodeTypeViewModel: Logging {

	struct ButtonModel {
		let title: String
		let subtitle: String
		let action: () -> Void
	}

	// MARK: - Bindable Strings

	/// The navbar title
	@Bindable private(set) var title: String = .holderChooseQRCodeTypeTitle

	/// The description label underneath the navbar title
	@Bindable private(set) var message: String = .holderChooseQRCodeTypeMessage
	private weak var coordinator: HolderCoordinatorDelegate?

	@Bindable private(set) var buttonModels: [ButtonModel] = []

	// MARK: - Private State:

	// MARK: - Initializer

	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator

		buttonModels = [
			ButtonModel(
				title: .holderChooseQRCodeTypeOptionNegativeTestTitle,
				subtitle: .holderChooseQRCodeTypeOptionNegativeTestSubtitle) { [weak self] in

				self?.coordinator?.userWishesToCreateANegativeTestQR()
			},
			ButtonModel(
				title: .holderChooseQRCodeTypeOptionVaccineTitle,
				subtitle: .holderChooseQRCodeTypeOptionVaccineSubtitle) { [weak self] in

				self?.coordinator?.userWishesToCreateAVaccinationQR()
			}
		]
	}
}
