/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class CheckForBSNViewModel: ListOptionsProtocol {
	
	let title = Observable(value: L.holder_checkForBSN_title())
	
	let message = Observable<String?>(value: L.holder_checkForBSN_message())
	
	let optionModels: Observable<[ListOptionsViewController.OptionModel]> = Observable(value: [])
	
	let bottomButton: Observable<ListOptionsViewController.OptionModel?> = Observable(value: nil)
	
	weak var coordinator: AlternativeRouteCoordinatorDelegate?
	
	// MARK: - Initializer
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: AlternativeRouteCoordinatorDelegate) {
		
		self.coordinator = coordinator
		
		optionModels.value = [
			ListOptionsViewController.OptionModel(
				title: L.holder_checkForBSN_buttonTitle_doesHaveBSN(),
				subTitle: L.holder_checkForBSN_buttonSubTitle_doesHaveBSN(),
				action: { [weak self] in self?.coordinator?.userWishesToContactHelpDeksWithBSN() }
			),
			ListOptionsViewController.OptionModel(
				title: L.holder_checkForBSN_buttonTitle_doesNotHaveBSN(),
				subTitle: L.holder_checkForBSN_buttonSubTitle_doesNotHaveBSN(),
				action: { [weak self] in self?.coordinator?.userHasNoBSN() }
			)
		]
	}
}
