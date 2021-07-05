/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseTestLocationViewModel: Logging {

	// MARK: - Bindable Strings

	@Bindable private(set) var title: String = L.holderLocationTitle()
	@Bindable private(set) var message: String = L.holderLocationMessage()
	@Bindable private(set) var buttonModels: [ChooseTestLocationViewController.ButtonModel] = []
	@Bindable private(set) var bottomButton: ChooseTestLocationViewController.BottomButtonModel?

	// MARK: - Private:

	private weak var coordinator: HolderCoordinatorDelegate?

	// MARK: - Initializer

	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator

		bottomButton = ChooseTestLocationViewController.BottomButtonModel(
			title: L.holderLocationNotest()) { [weak self] in
			self?.coordinator?.userHasNotBeenTested()
		}

		buttonModels = [
			.init(
				title: L.holderLocationGgdTitle(),
				subtitle: L.holderLocationGgdSubtitle()) { [weak self] in

				self?.coordinator?.userWishesToCreateANegativeTestQRFromGGD()
			},
			.init(
				title: L.holderLocationOtherTitle(),
				subtitle: nil) { [weak self] in

				self?.coordinator?.userWishesToCreateANegativeTestQR()
			}
		]

	}
}
