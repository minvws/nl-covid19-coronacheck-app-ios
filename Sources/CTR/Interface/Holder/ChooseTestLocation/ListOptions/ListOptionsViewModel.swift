/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ListOptionsViewModel {

	// MARK: - Bindable Strings

	@Bindable private(set) var title: String?
	@Bindable private(set) var message: String?
	@Bindable private(set) var optionModels: [ListOptionsViewController.OptionModel] = []
	@Bindable private(set) var bottomButton: ListOptionsViewController.OptionModel?
	
	// MARK: - Private:
	
	weak var coordinator: HolderCoordinatorDelegate?
	
	// MARK: - Initializer
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {
		
		self.coordinator = coordinator
	}
	
	func setTitle(_ title: String?) {
		self.title = title
	}
	
	func setMessage(_ message: String?) {
		self.message = message
	}
	
	func setOptions(_ options: [ListOptionsViewController.OptionModel]) {
		self.optionModels = options
	}
	
	func setButton(_ button: ListOptionsViewController.OptionModel) {
		self.bottomButton = button
	}
}
