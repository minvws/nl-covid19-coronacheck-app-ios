/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI

class MigrationTransferOptionsViewModel: ListOptionsProtocol {
	
	let title = Observable(value: L.holder_startMigration_title())
	
	let message = Observable<String?>(value: L.holder_startMigration_message())
	
	let optionModels: Observable<[ListOptionsViewController.OptionModel]> = Observable(value: [])
	
	let bottomButton: Observable<ListOptionsViewController.OptionModel?> = Observable(value: nil)

	init(_ coordinator: MigrationCoordinatorDelegate) {
		
		optionModels.value = [
			ListOptionsViewController.OptionModel(
				title: L.holder_startMigration_option_toOtherDevice_title(),
				image: I.icon_menu_export(),
				type: .singleWithImage,
				action: { [weak coordinator] in coordinator?.userWishesToSeeToOtherDeviceInstructions() }
			),
			ListOptionsViewController.OptionModel(
				title: L.holder_startMigration_option_toThisDevice_title(),
				image: I.icon_menu_import(),
				type: .singleWithImage,
				action: { [weak coordinator] in coordinator?.userWishesToSeeToThisDeviceInstructions() }
			)
		]
	}
}
