/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class UpgradeEUVaccinationViewModel: Logging {

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var primaryButtonTitle: String
	@Bindable private(set) var isLoading: Bool = false

	private var backbuttonAction: () -> Void
	
	init(backAction: @escaping () -> Void) {
		self.title = L.holderUpgradeeuvaccinationTitle()
		self.message = L.holderUpgradeeuvaccinationMessage()
		self.primaryButtonTitle = L.holderUpgradeeuvaccinationButton()
		self.backbuttonAction = backAction
	}

	func primaryButtonTapped() {
		isLoading = true

		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			self.isLoading = false
		}
	}

	func backButtonTapped() {
		backbuttonAction()
	}

	private func load() {
		
	}

}
