/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared

class InternetRequiredViewModel: AppStatusViewModel {
	
	var title = Observable(value: L.internetRequiredTitle())
	var message = Observable(value: L.internetRequiredText())
	var actionTitle = Observable(value: L.internetRequiredButton())
	var image = Observable<UIImage?>(value: I.noInternet())
	var alert: Observable<AlertContent?> = Observable(value: nil)
	
	weak private var coordinator: AppCoordinatorDelegate?
	
	init(coordinator: AppCoordinatorDelegate) {
		
		self.coordinator = coordinator
	}
	
	func actionButtonTapped() {
		
		coordinator?.retry()
	}
}
