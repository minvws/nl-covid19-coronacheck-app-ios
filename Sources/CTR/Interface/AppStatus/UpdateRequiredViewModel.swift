/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

class UpdateRequiredViewModel: AppStatusViewModel {
	
	var title: Observable<String>
	var message: Observable<String>
	var actionTitle: Observable<String>
	var image = Observable<UIImage?>(value: I.updateRequired())
	var alert: Observable<AlertContent?> = Observable(value: nil)
	
	weak private var coordinator: AppCoordinatorDelegate?
	private var flavor: AppFlavor
	
	private var updateURL: URL?
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - appStoreUrl: the store url
	///   - flavor: the app flavor (holder of verifier)
	init(coordinator: AppCoordinatorDelegate, appStoreUrl: URL?, flavor: AppFlavor) {
		
		title = Observable(value: flavor == .holder ? L.holder_updateApp_title() : L.verifier_updateApp_title())
		message = Observable(value: flavor == .holder ? L.holder_updateApp_content() : L.verifier_updateApp_content())
		actionTitle = Observable(value: flavor == .holder ? L.holder_updateApp_button() : L.verifier_updateApp_button())
		
		self.coordinator = coordinator
		self.updateURL = appStoreUrl
		self.flavor = flavor
	}
	
	func actionButtonTapped() {
		
		guard let url = updateURL else {
			alert.value = AlertContent(
				title: L.generalErrorTitle(),
				subTitle: flavor == .holder ? L.holder_updateApp_errorMessage() : L.verifier_updateApp_errorMessage(),
				okAction: AlertContent.Action.okay
			)
			return
		}
		coordinator?.openUrl(url, completionHandler: nil)
	}
}
