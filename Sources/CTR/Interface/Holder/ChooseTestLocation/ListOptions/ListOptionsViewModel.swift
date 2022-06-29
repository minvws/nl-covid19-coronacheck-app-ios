/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ListOptionsViewModel {

	// MARK: - Bindable Strings

	@Bindable private(set) var title: String = L.holderLocationTitle()
	@Bindable private(set) var message: String = L.holderLocationMessage()
	@Bindable private(set) var buttonModels: [ListOptionsViewController.OptionModel] = []
	@Bindable private(set) var bottomButton: ListOptionsViewController.OptionModel?
	
	// MARK: - Private:
	
	private weak var coordinator: HolderCoordinatorDelegate?
	
	// MARK: - Initializer
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {
		
		self.coordinator = coordinator
		
		bottomButton = ListOptionsViewController.OptionModel(
			title: L.holderLocationNotest()) { [weak self] in
				self?.coordinator?.userWishesMoreInfoAboutGettingTested()
			}
		
		buttonModels = [
			ListOptionsViewController.OptionModel(
				title: L.holderLocationGgdTitle()) { [weak self] in
					self?.coordinator?.userWishesToCreateANegativeTestQRFromGGD()
				},
			ListOptionsViewController.OptionModel(
				title: L.holderLocationOtherTitle()) { [weak self] in
					self?.coordinator?.userWishesToCreateANegativeTestQR()
				}
		]
	}
}
